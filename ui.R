library(shiny)
library(DT)

fluidPage(
  titlePanel(p("Spatial app", style = "color:#3474A7")),
  sidebarLayout(
    sidebarPanel(
    ),
    mainPanel(
      leafletOutput(outputId = "map"),
      dygraphOutput(outputId = "timetrend"),
      DTOutput(outputId = "table")
    )
  )
)

