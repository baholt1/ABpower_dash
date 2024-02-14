library(shiny)
library(leaflet)

# # Define UI
# shiny::fluidPage(
#   shiny::titlePanel("Alberta Map"),
#   shiny::mainPanel(
#     leaflet::leafletOutput(outputId = "alberta_map"),
#     # shiny::tableOutput(outputId = "ab_tseires")
#   ),
#   shiny::sidebarPanel(
#     shiny::selectInput(
#       inputId = "source",
#       label = "Filter by Type:",
#       choices = type,
#       selectize = F),
#     shiny::tableOutput(outputId = "ab_generation")
#   )
# )

# Define UI
ui <- fluidPage(
  titlePanel("Filterable Table by Type"),
  sidebarLayout(
    sidebarPanel(
      selectInput("typeInput", "Choose a Type:", choices = unique(generationBySource$type)),
    tableOutput("filteredTable"),
    ),
    mainPanel(
      leaflet::leafletOutput(outputId = "alberta_map")
    )
  )
)
