library(shiny)
library(leaflet)

# Define UI
ui <- fluidPage(
  theme = shinythemes::shinytheme("superhero"), 
  titlePanel("ALBERTA ELECTRICITY GENERATION", windowTitle = "Alberta Electricity Generation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("typeInput", "Choose a Type:", choices = c("All", unique(generationBySource$type))),
      radioButtons("colInput", "Choose a variable to display:",
                   choices = c("Maximum Capability" = "MC_sum", "Total Net Generation" = "TNG_sum", "Dispatched Contingency Reserve" = "DCR_sum")),
    tableOutput("filteredTable"), width = 3
    ),
    mainPanel(
      leaflet::leafletOutput(outputId = "alberta_map",  width = "100%", height = 750)
    )
  )
)
