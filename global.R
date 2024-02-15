library(shiny)
library(readxl)
library(maps)
library(sf)
library(tidyverse)
library(rvest)
library(dplyr)
library(magrittr)


boundaries <- st_read("AESO-Planning-Areas-2020-06-23/AESO_Planning_Areas.shp")


Master_Location <- read_excel("Master-Location.xlsx")

colNames <- Master_Location %>% 
  slice(6) %>%
  unlist(use.names = FALSE)

colnames(Master_Location) <- colNames

Master_Location <- Master_Location %>% 
  slice(-1:-6)


bound_cols <- rainbow(nrow(boundaries))


ab.city <- maps::canada.cities %>% 
  dplyr::filter(country.etc == "AB") %>% 
  dplyr::mutate(name = stringr::str_replace(name, 
                                            pattern = " AB", 
                                            replacement = ""))
locations <- merge(ab.city, 
                   Master_Location, 
                   by.x = "name", 
                   by.y = "Area Name")

locations$jittered_lng <- jitter(locations$long)
locations$jittered_lat <- jitter(locations$lat)

#function is pretty crummu, will rewrite a better one at some point
scrapeGen <- function(aesoDashSource ){
  
  AESOsimpleTable <- function(table, subtype) {
    summary <- aesoDashSource %>% 
      html_elements(css = "table") %>% 
      .[table] %>% 
      html_table() %>% 
      .[[1]] 
    
    dateMST <- aesoDashSource %>% 
      html_elements(css = "table") %>% 
      .[5] %>% 
      html_text() %>% 
      .[[1]]
    
    dateMST <- str_extract(dateMST[1], "\\w{3} \\d{2}, \\d{4} \\d{2}:\\d{2}") %>% 
      str_replace(",", "") %>% 
      mdy_hm(tz = "America/Denver")
    
    colNames <- c("ASSET", "MC", "TNG", "DCR")
    
    type <- colnames(summary)
    colnames(summary) <- colNames
    
    summary <- summary %>% 
      mutate(type = type[[1]]) %>% 
      # no applicable subtype; placeholder
      mutate(subtype = subtype) %>% 
      # redudant first row
      filter(!ASSET %in% c("ASSET", "GROUP")) %>% 
      mutate(date = dateMST)
    
    return(summary)
  }
  
  # gas table
  gas <- aesoDashSource %>% 
    html_elements(css = "table") %>% 
    .[11] %>% 
    html_table() %>% 
    .[[1]] 
  
  # defining col names to be utilized
  colNames <- c("ASSET", "MC", "TNG", "DCR")
  
  # taking existing col names for type column
  type <- colnames(gas)
  
  # overwritting col names with def list
  colnames(gas) <- colNames
  
  
  dateMST <- aesoDashSource %>% 
    html_elements(css = "table") %>% 
    .[5] %>% 
    html_text() %>% 
    .[[1]]
  
  dateMST <- str_extract(dateMST[1], "\\w{3} \\d{2}, \\d{4} \\d{2}:\\d{2}") %>% 
    str_replace(",", "") %>% 
    mdy_hm(tz = "America/Denver")
  
  
  gas <- gas %>% 
    #adding type, per original column names at import
    mutate(type = type[[1]]) %>% 
    # finding divisional row, and where present, using them to define subtype
    mutate(subtype = case_when(
      ASSET %in% c("Simple Cycle", "Cogeneration", "Combined Cycle", "Gas Fired Steam") ~ ASSET)) %>% 
    # fill remainder of subtype until new subtype
    fill(subtype, .direction = c("down")) %>% 
    # removing divsional rows (now that they are in column subtype)
    filter(!ASSET %in% 
             c("Simple Cycle", "Cogeneration", "Combined Cycle", "Gas Fired Steam", "ASSET")) %>% 
    mutate(date = dateMST)
  
  hydro <- AESOsimpleTable(13, "hydro")
  
  energyStor <- AESOsimpleTable(14, "energy storage")
  
  solar <- AESOsimpleTable(15, "solar")
  
  wind <- AESOsimpleTable(16, "wind")
  
  bioAndOther <- AESOsimpleTable(18, "biomass and other")
  
  duel <- AESOsimpleTable(19, "duel fuel")
  
  coal <- AESOsimpleTable(20, "coal")
  
  generationBySource <- rbind(gas, hydro, energyStor, solar, wind, bioAndOther, duel, coal)
  
  return(generationBySource)
}


generationBySource <- scrapeGen(read_html('http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet'))
