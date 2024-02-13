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
    
    map <- leaflet() %>%
      addTiles() %>%
      addCircleMarkers(data = ab.city, 
                       lng = ~long, 
                       lat = ~lat, 
                       popup = ~name,
                       radius = 5,
                       color = "red")
    
    return(map)
  })
}

