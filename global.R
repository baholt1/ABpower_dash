library(shiny)
library(tidyverse)
library(readxl)
library(maps)
library(sf)
library(rvest)
library(grDevices)



boundaries_1 <- st_read("AESO-Planning-Areas-2020-06-23/AESO_Planning_Areas.shp") 

boundaries <- sf::st_as_sf(boundaries_1, coords = c("long", "lat"), crs = "+proj=longlat +datum=NAD83 +no_defs") %>% 
  sf::st_transform( crs = "+proj=longlat +datum=WGS84") %>% 
  mutate(Area_ID = as.numeric(Area_ID)) 


#gen file with comprehensive area-asset mapping 
genFile <- read_csv("CSD Generation (Hourly) - 2024-01 2.csv") %>% 
  dplyr::transmute(assetID = `Asset Short Name`, Area_ID = `Planning Area`, region = Region) %>% 
  dplyr::group_by(assetID) %>% 
  dplyr::slice(1)


Master_Location <- read_excel("Master-Location.xlsx")

colNames <- Master_Location %>% 
  dplyr::slice(6) %>%
  unlist(use.names = FALSE)

colnames(Master_Location) <- colNames

Master_Location <- Master_Location %>% 
  dplyr::slice(-1:-6)


bound_cols <- grDevices::rainbow(nrow(boundaries))


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
      rvest::html_elements(css = "table") %>% 
      .[5] %>% 
      rvest::html_text() %>% 
      .[[1]]
    
    dateMST <- stringr::str_extract(dateMST[1], "\\w{3} \\d{2}, \\d{4} \\d{2}:\\d{2}") %>% 
      stringr::str_replace(",", "") %>% 
      lubridate::mdy_hm(tz = "America/Denver")
    
    colNames <- c("ASSET", "MC", "TNG", "DCR")
    
    type <- colnames(summary)
    colnames(summary) <- colNames
    
    summary <- summary %>% 
      dplyr::mutate(type = type[[1]]) %>% 
      # no applicable subtype; placeholder
      dplyr::mutate(subtype = subtype) %>% 
      # redudant first row
      dplyr::filter(!ASSET %in% c("ASSET", "GROUP")) %>% 
      dplyr::mutate(date = dateMST)
    
    return(summary)
  }
  
  # gas table
  gas <- aesoDashSource %>% 
    rvest::html_elements(css = "table") %>% 
    .[11] %>% 
    rvest::html_table() %>% 
    .[[1]] 
  
  # defining col names to be utilized
  colNames <- c("ASSET", "MC", "TNG", "DCR")
  
  # taking existing col names for type column
  type <- colnames(gas)
  
  # overwritting col names with def list
  colnames(gas) <- colNames
  
  
  dateMST <- aesoDashSource %>% 
    rvest::html_elements(css = "table") %>% 
    .[5] %>% 
    rvest::html_text() %>% 
    .[[1]]
  
  dateMST <- stringr::str_extract(dateMST[1], "\\w{3} \\d{2}, \\d{4} \\d{2}:\\d{2}") %>% 
    stringr::str_replace(",", "") %>% 
    lubridate::mdy_hm(tz = "America/Denver")
  
  
  gas <- gas %>% 
    #adding type, per original column names at import
    dplyr::mutate(type = type[[1]]) %>% 
    # finding divisional row, and where present, using them to define subtype
    dplyr::mutate(subtype = case_when(
      ASSET %in% c("Simple Cycle", "Cogeneration", "Combined Cycle", "Gas Fired Steam") ~ ASSET)) %>% 
    # fill remainder of subtype until new subtype
    tidyr::fill(subtype, .direction = c("down")) %>% 
    # removing divsional rows (now that they are in column subtype)
    dplyr::filter(!ASSET %in% 
             c("Simple Cycle", "Cogeneration", "Combined Cycle", "Gas Fired Steam", "ASSET")) %>% 
    dplyr::mutate(date = dateMST)
  
  hydro <- AESOsimpleTable(13, "hydro")
  
  energyStor <- AESOsimpleTable(14, "energy storage")
  
  solar <- AESOsimpleTable(15, "solar")
  
  wind <- AESOsimpleTable(16, "wind")
  
  bioAndOther <- AESOsimpleTable(18, "biomass and other")
  
  duel <- AESOsimpleTable(19, "duel fuel")
  
  coal <- AESOsimpleTable(20, "coal")
  
  generationBySource <- rbind(gas, hydro, energyStor, solar, wind, bioAndOther, duel, coal)
  
  generationBySource <- generationBySource %>%
    dplyr::mutate(assetID = str_extract(ASSET, "\\([A-Z0-9]{3,4}\\)")) %>%
    dplyr::mutate(assetID = str_remove_all(assetID, "[\\(\\)]"))
  
  # extracting names from shape file to append to generation file
  boundariesJoin <- data.frame(boundaries$Area_ID, boundaries$NAME) %>% 
    dplyr::rename(Area_ID = boundaries.Area_ID, 
           Area_IDName = boundaries.NAME) %>% 
    dplyr::mutate(Area_ID = as.numeric(Area_ID))
  
  #adding planning area
  generationBySource <- dplyr::left_join(generationBySource, genFile, by = 'assetID')
  
  #adding names assoc. w/ each planning area
  generationBySource <- dplyr::left_join(generationBySource, boundariesJoin, by = 'Area_ID') %>% 
    dplyr::mutate(MC = as.numeric(MC),
           TNG = as.numeric(TNG),
           DCR = as.numeric(DCR)) 
  
  return(generationBySource)
}


generationBySource <- scrapeGen(rvest::read_html('http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet'))
