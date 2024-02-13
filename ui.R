library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Alberta Map"),
  mainPanel(
    leafletOutput("alberta_map")
  )
)
