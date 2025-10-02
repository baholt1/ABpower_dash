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
  
  shiny::observeEvent(input$refreshBtn, {
    updateData()})
  
  # reactive expression for filtering
  filteredData <- shiny::reactive({
                  
                  data <- reactiveGenerationBySource()
                  
                  if (input$typeInput != "All") {
                    if(input$gasInput != "All"){
                      data <- data %>%
                      dplyr::filter(subtype == input$gasInput)
                    } else {
                    data <- data %>%
                      dplyr::filter(type == input$typeInput)
                      }
                    }
                  
                  result <- data %>%
                    dplyr::group_by(Area_ID) %>% 
                    dplyr::summarise(MC_sum = sum(MC), TNG_sum = sum(TNG), date = date[1]) %>% 
                    dplyr::mutate(cap_prop = round(TNG_sum / MC_sum * 100), 1) %>%
                    dplyr::right_join(boundaries, by = "Area_ID") %>% 
                    tidyr::replace_na(list(MC_sum = 0, TNG_sum = 0, cap_prop = 0, date = data$date[1]))
                  result
                })
  
  # Render the filtered map
  output$alberta_map <- leaflet::renderLeaflet({
    # get the filtered data
    map_data <- filteredData() %>% 
      dplyr::arrange(desc(Area_ID))
    output$currentDate <- shiny::renderText({
      paste("Last Update: ", map_data$date[1])
    })
    # get user input for desired output
    var_x <- map_data[[input$colInput]]
    range_max <- max(var_x, na.rm = TRUE)
    # if range_max is zero, add a small increment to ensure uniqueness in breaks
    ifelse(range_max == 0, range_max <- 1, 0)
    # create dynamic bins
    dynamic_bins <- round(c(0, seq(10, range_max, length.out = 7)), digits = 0)
    # color palette
    pal <- leaflet::colorBin(c("YlOrRd"), domain = var_x, bins = dynamic_bins)
    
    labss <- lapply(1:nrow(map_data), function(i) {
      shiny::HTML(paste("Area: ", map_data$NAME[i], "<br>",
                 "Output: ", var_x[i], "MW", "<br>",
                 "Maximum Capacity: ", map_data$MC_sum[i], "MW", "<br>",
                 "Current Output: ", map_data$TNG_sum[i], "MW", "<br>",
                 "Current Utilization Rate: ", map_data$cap_prop[i], "%"))
      }
    )
    
    leaflet::leaflet() %>%
      leaflet::addTiles() %>%
      leaflet::addPolygons(data = boundaries,
                           fillColor = ~pal(var_x),
                           fillOpacity = 0.75,
                           color = "black",
                           opacity = 1,
                           stroke = T,
                           weight = 1,
                           label = labss,
                           highlightOptions = highlightOptions(
                             weight = 5,
                             color = "#000",
                             bringToFront = TRUE)) %>% 
      leaflet::addLegend(pal = pal, values = var_x, title = "Output in MW")
    }
  )
}

