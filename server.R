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
    data <- reactiveGenerationBySource()
    
    if (input$typeInput != "All") {
      data <- data %>%
        filter(type == input$typeInput)
    }
    
    result <- data %>%
      group_by(Area_ID) %>% 
      summarise(MC_sum = sum(MC), TNG_sum = sum(TNG), DCR_sum = sum(DCR)) %>% 
      right_join(boundaries, by = "Area_ID") %>% 
      replace_na(list(MC_sum = 0, TNG_sum = 0, DCR_sum = 0))
    
    result
  })
  
  

  # Render the filtered table
  # output$filteredTable <- renderTable({
  #   filteredData()
  # })
  
  # Update the selectInput choices dynamically based on the updated data
  # observe({
  #   updateSelectInput(session, "typeInput", choices = unique(reactiveGenerationBySource()$type))
  # })
    
  # Create table of production by region
  production_table <-  generationBySource %>% 
    dplyr::group_by(Area_ID) %>% 
    dplyr::summarise(MC_sum = sum(MC), TNG_sum = sum(TNG), DCR_sum = sum(DCR)) %>% 
    dplyr::right_join(boundaries, by = "Area_ID") %>% 
    replace_na(list(MC_sum = 0, TNG_sum = 0, DCR_sum = 0))
  
  # Render the filtered map
  output$alberta_map <- leaflet::renderLeaflet({
    
    var_x <- filteredData()[[input$colInput]]
    # Assuming 'var_x' is your variable for coloring
    range_max <- max(var_x, na.rm = TRUE)
    
    # If range_max is zero, add a small increment to ensure uniqueness in breaks
    ifelse(range_max == 0, range_max <- 1, 0)
    
    # Create dynamic bins
    dynamic_bins <- round(c(0, seq(10, range_max, length.out = 7)), digits = 0)
    
    # Use dynamic_bins in leaflet::colorBin
    pal <- leaflet::colorBin("YlOrRd", domain = var_x, bins = dynamic_bins)
    
    labss <- lapply(1:nrow(boundaries), function(i) {
      HTML(paste("Area: ", boundaries$NAME[i], "<br>",
                 "Output: ", var_x[i], "MW", "<br>",
                 "Maximum Capability: ", filteredData()$MC_sum[i], "MW", "<br>",
                 "Total Net Generation: ", filteredData()$TNG_sum[i], "MW", "<br>",
                 "Dispatched Contingency Reserve: ", filteredData()$DCR_sum[i], "MW"))
    })
    
    leaflet::leaflet() %>%
      leaflet::addTiles() %>%
      leaflet::addPolygons(data = boundaries,
                           fillColor = ~pal(var_x),
                           fillOpacity = 0.7,
                           color = "black",
                           opacity = 1,
                           stroke = T,
                           weight = 1,
                           label = labss,
                           highlightOptions = highlightOptions(
                             weight = 5,
                             color = "#000",
                             bringToFront = TRUE)) %>% 
      addLegend(pal = pal, values = var_x, title = "Output in MW") %>%
      leaflet::addCircleMarkers(data = locations,
                                lng = ~jittered_lng,
                                lat = ~jittered_lat,
                                popup =  ~locations$`Facility Name`,
                                radius = 1,
                                color = "red")
  })
  
}