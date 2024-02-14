library(shiny)
library(maps)
library(ggplot2)

# Define server logic
server <- function(input, output) {
  
  # Function to create Alberta map
  output$alberta_map <- renderLeaflet({
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
                       popup = ~locations$`Facility Name`,
                       radius = 5,
                       color = "red")
    
    return(map)
  })
}

