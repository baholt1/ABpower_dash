library(shiny)
library(readxl)
library(maps)
library(sf)

path <- "AESO-Planning-Areas-2020-06-23"


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

locations$jittered_lng <- jitter(locations$long )
locations$jittered_lat <- jitter(locations$lat)