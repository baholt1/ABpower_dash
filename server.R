library(shiny)
library(maps)
library(ggplot2)
library(sf)

# Define server logic
server <- function(input, output) {
  
  # Function to create Alberta map
  output$alberta_map <- renderLeaflet({
    path <- "C:/Users/holtb/OneDrive/Documents/UAlberta 2023-2024 Year 4/Winter 2024/FIN 488 FINTECH3/ABpower_dash/AESO-Planning-Areas-2020-06-23"
    
    boundaries <- sf::st_read(dsn = path)
    
    bound_cols <- rainbow(nrow(boundaries))
    
    ab.city <- canada.cities %>% 
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

    
    map <- leaflet() %>%
        addTiles() %>%
        addCircleMarkers(data = locations,
                         lng = ~jittered_lng,
                         lat = ~jittered_lat,
                         popup =  ~locations$`Facility Name`,
                         radius = 5,
                         color = "red") %>%
        addPolygons(data = boundaries,
                    fillColor = bound_cols,
                    fillOpacity = 0.1,
                    color = "black",
                    stroke = T,
                    weight = 1,
                    popup = ~boundaries$NAME)
    
    return(map)
  })
}

