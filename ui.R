library(shiny)
library(leaflet)

# Define UI
shiny::fluidPage(
  shiny::titlePanel("Alberta Map"),
  shiny::mainPanel(
    leaflet::leafletOutput(outputId = "alberta_map"),
    # shiny::tableOutput(outputId = "ab_tseires")
  ),
  shiny::sidebarPanel(
    shiny::selectInput(
      inputId = "source",
      label = "Filter by Type:",
      choices = type,
      selectize = F),
    shiny::radioButtons("map_bound", "Choose the Boundaries:",
                        choices = c("Area" = "AREA_ID",
                                    "Region" = "REGION"
                                    )
                        ),
    shiny::tableOutput(outputId = "ab_generation")
  )
)
