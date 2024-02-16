library(shiny)
library(shinythemes)
library(leaflet)

# Define UI
ui <- shiny::fluidPage(
  theme = shinythemes::shinytheme("superhero"), 
  shiny::titlePanel("ALBERTA POWER GENERATION GRID", windowTitle = "Alberta Power Generation"),
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput("typeInput", "Choose Energy Source:", choices = c("All", unique(generationBySource$type))),
      shiny::radioButtons("colInput", "",
                   choices = c("Maximum Capacity" = "MC_sum", "Current Output" = "TNG_sum", "Current Utilization Rate" = "cap_prop")),
      shiny::actionButton("refreshBtn", "Refresh Data", icon = icon("refresh")),
      shiny::wellPanel(
        h4("Instructions"),
        p("This app allows you to explore up to date Alberta electricity generation data.
          Select an energy type and desired output to display on the map."),
        tags$div(textOutput("currentDate"), style = "font-size: 10px;")
      )
    ),
    shiny::mainPanel(
      leaflet::leafletOutput(outputId = "alberta_map",  width = "100%", height = 750),
      tags$div(
        p("Created by: Olivier Haley, Connor Beebe, Luke Talman & Brooklyn Holt", style = "font-style: italic; font-size: 12px;")
      )
    )
  )
)
