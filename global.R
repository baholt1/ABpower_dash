library(shiny)
library(leaflet)
library(readxl)

Master_Location <- read_excel("Master-Location.xlsx", 
                              skip = 6)
dplyr::right_join(Master_Location, generationBySource, by = "ASSET")


merge(Master_Location, generationBySource)
