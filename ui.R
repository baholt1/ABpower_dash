library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Alberta Map"),
  mainPanel(
    leafletOutput(outputId = "alberta_map")
  )
)
