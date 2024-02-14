library(shiny)

# Define UI
fluidPage(
  titlePanel("Alberta Map"),
  mainPanel(
    leafletOutput(outputId = "alberta_map")
  ),
  sidebarPanel(
    selectInput(
      inputId = "source",
      label = "Filter by Type:",
      choices = type,
      selectize = F
    )
  )
)
