library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)

# Define server logic
function(input, output, session) {
  
  # Reactive value to store the fetched data
  reactiveGenerationBySource <- reactiveVal()
  
  # Function to fetch and update data
  updateData <- function() {
    newData <- scrapeGen(read_html('http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet'))
    reactiveGenerationBySource(newData)
  }
  
  updateData()
  
  # Reactive expression for filtering
  filteredData <- reactive({
    req(reactiveGenerationBySource())
    reactiveGenerationBySource() %>%
      filter(type == input$typeInput) %>% 
      select(-c(type, subtype, date))
    
  })
  
  
  
  # Render the filtered table
  output$filteredTable <- renderTable({
    filteredData()
  })
  
  # Update the selectInput choices dynamically based on the updated data
  observe({
    updateSelectInput(session, "typeInput", choices = unique(reactiveGenerationBySource()$type))
  })
    
  # Create table of production by region
  production_table <- generationBySource %>% 
    dplyr::rename(Area_ID = planArea) %>%
    dplyr::group_by(Area_ID) %>% 
    dplyr::summarise(MC_sum = sum(MC), TNG_sum = sum(TNG), DCR_sum = sum(DCR)) %>% 
    dplyr::left_join(boundaries, by = "Area_ID")
      
  bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, 100000)
  pal <- leaflet::colorBin("YlOrRd", domain = production_table$TNG_sum, bins = bins)
  
  # Render the filtered map
  output$alberta_map <- leaflet::renderLeaflet({
    leaflet::leaflet() %>%
      leaflet::addTiles() %>%
      leaflet::addPolygons(data = boundaries,
                           fillColor = ~pal(production_table$TNG_sum),
                           fillOpacity = 0.7,
                           color = "black",
                           opacity = 1,
                           stroke = T,
                           weight = 1,
                           popup = boundaries$NAME,
                           highlightOptions = highlightOptions(
                             weight = 5,
                             color = "#000",
                             bringToFront = TRUE)) %>% 
      addLegend(pal = pal, values = production_table$TNG_sum) %>%
      leaflet::addCircleMarkers(data = locations,
                                lng = ~jittered_lng,
                                lat = ~jittered_lat,
                                popup =  ~locations$`Facility Name`,
                                radius = 1,
                                color = "red")
  })
  
}
