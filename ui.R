library(shiny)
library(shinythemes)
library(leaflet)

# Define UI
ui <- fluidPage(
  theme = shinythemes::shinytheme("superhero"), 
  titlePanel("ALBERTA POWER GENERATION GRID", windowTitle = "Alberta Power Generation"),
  sidebarLayout(
    sidebarPanel(
      selectInput("typeInput", "Choose a Type:", choices = c("All", unique(generationBySource$type))),
      radioButtons("colInput", "Choose a variable to display:",
                   choices = c("Maximum Capacity" = "MC_sum", "Current Output" = "TNG_sum", "Current Utilization Rate" = "cap_prop")),
      actionButton("refreshBtn", "Refresh Data", icon = icon("refresh")),
      shiny::wellPanel(
        h4("How the App Works"),
        p("This app allows you to explore live Alberta electricity generation data (updated every minute). 
          Select a type and a variable to display on the map."),
        tags$div(textOutput("currentDate"), style = "font-size: 10px;")
      )
    ),
    mainPanel(
      leaflet::leafletOutput(outputId = "alberta_map",  width = "100%", height = 750),
      tags$div(
        p("Created by: Olivier Haley, Connor Beebe, Luke Talman & Brooklyn Holt", style = "font-style: italic; font-size: 12px;")
      )
    )
  )
)
