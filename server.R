library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(leaflet)
library(shinyjs)

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
      dplyr::summarise(MC_sum = sum(MC), TNG_sum = sum(TNG)) %>% 
      dplyr::mutate(cap_prop = round(TNG_sum / MC_sum * 100), 1) %>%
      right_join(boundaries, by = "Area_ID") %>% 
      replace_na(list(MC_sum = 0, TNG_sum = 0, cap_prop = 0))
    
    result
  })
  
  observeEvent(input$refreshBtn, {
    shinyjs::disable("refreshBtn")
    updateData()
    shinyjs::enable("refreshBtn")})
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
    pal <- leaflet::colorBin(c("YlOrRd"), domain = var_x, bins = dynamic_bins)
    
    labss <- lapply(1:nrow(boundaries), function(i) {
      HTML(paste("Area: ", boundaries$NAME[i], "<br>",
                 "Output: ", var_x[i], "MW", "<br>",
                 "Maximum Capacity: ", filteredData()$MC_sum[i], "MW", "<br>",
                 "Total Generation: ", filteredData()$TNG_sum[i], "MW", "<br>",
                 "Current Utilization Rate: ", filteredData()$cap_prop[i], "%"))
    })
    
    leaflet::leaflet() %>%
      leaflet::addTiles() %>%
      leaflet::addPolygons(data = boundaries,
                           fillColor = ~pal(var_x),
                           fillOpacity = 0.8,
                           color = "black",
                           opacity = 1,
                           stroke = T,
                           weight = 1,
                           label = labss,
                           highlightOptions = highlightOptions(
                             weight = 5,
                             color = "#000",
                             bringToFront = TRUE)) %>% 
      addLegend(pal = pal, values = var_x, title = "Output in MW")
  })
  
}