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

    
    map <- leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = locations, 
                       lng = ~long, 
                       lat = ~lat, 
                       popup = ~locations$`Facility Name`,
                       radius = 5,
                       color = "red")
    
    return(map)
  })
}

