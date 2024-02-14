library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)

# Define server logic
function(input, output, session) {
  
  type <- shiny::observe({
    shiny::updateSelectInput(session, "source", choices = unique(generationBySource$type))
  })
  
  output$ab_generation <- shiny::renderTable({
    AESOsimpleTable(8, "total") %>% 
      dplyr::rename(GENERATION = ASSET) %>% 
      dplyr::transmute(Generation = GENERATION,
                    "Maximum Capacity" = MC,
                    "Total Net Generation" = TNG,
                    "Dispatched (and Accepted) Contingency Reserve" = DCR)
    
    
  })
  
  # Function to create Alberta map
  output$alberta_map <- leaflet::renderLeaflet({
    
    leaflet::leaflet() %>%
    leaflet::addTiles() %>%
        leaflet::addPolygons(data = boundaries,
                    fillColor = ~bound_cols,
                    fillOpacity = 0.1,
                    color = "black",
                    stroke = T,
                    weight = 1,
                    popup = boundaries$REGION) %>% 
        leaflet::addCircleMarkers(data = locations,
                         lng = ~jittered_lng,
                         lat = ~jittered_lat,
                         popup =  ~locations$`Facility Name`,
                         radius = 5,
                         color = "red") 
  })
  
  # shiny::observe({
  #   req(input$map_bound)
  #   leaflet::leafletProxy("alberta_map") %>%
  #     clearShapes() %>% 
  #   addPolygons(data = boundaries,
  #               fillColor = bound_cols,
  #               fillOpacity = 0.1,
  #               color = "black",
  #               stroke = T,
  #               weight = 1,
  #               options = list(AREASifelse(input$map_bound == "REGION", "AREA_ID"),
  #               popup = ifelse(input$map_bound == "REGION", "AREA_ID"))
  # })
  
  # observe({
  #   filtered_type <- generationBySource %>%
  #     stringr::str_subset(pattern = input$source)
  #   leaflet::leafletProxy("alberta_map") %>%
  #     clearMarkers() %>%
  #     addMarkers(data = filtered_type,
  #                lng = ~)
    
  # })
}

