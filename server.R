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
    # Assuming scrapeGen() fetches and processes your data
    # Update this function call if it requires different handling
    newData <- scrapeGen(read_html('http://ets.aeso.ca/ets_web/ip/Market/Reports/CSDReportServlet'))
    reactiveGenerationBySource(newData)
  }
  
  updateData()
  
  # Reactive expression for filtering
  filteredData <- reactive({
    req(reactiveGenerationBySource())  # Ensure data is available before proceeding
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

  

  
  # Render the filtered map
  output$alberta_map <- leaflet::renderLeaflet({
  leaflet::leaflet() %>%
    leaflet::addTiles() %>%
    leaflet::addPolygons(data = boundaries,
                         fillColor = bound_cols,
                         fillOpacity = 0.1,
                         color = "black",
                         stroke = T,
                         weight = 1,
                         popup = boundaries$NAME) %>% 
    leaflet::addCircleMarkers(data = locations,
                              lng = ~jittered_lng,
                              lat = ~jittered_lat,
                              popup =  ~locations$`Facility Name`,
                              radius = 5,
                              color = "red") 
  })
  

  

  
}

