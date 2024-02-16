library(shiny)
library(shinythemes)
library(leaflet)

# Define UI
ui <- shiny::fluidPage(
  theme = shinythemes::shinytheme("superhero"), 
  
  shiny::titlePanel(h1("Alberta Power Generation"), windowTitle = "Alberta Power Generation"),
  
  shiny::sidebarLayout(
    shiny::sidebarPanel(
      shiny::selectInput("typeInput", "Choose Energy Source:", choices = c("All", unique(generationBySource$type))),
      shiny::conditionalPanel(
        condition = 'input.typeInput == "GAS"',
        shiny::selectInput("gasInput", "Choose GAS Type:", choices = c("All", unique(filter(generationBySource, type == "GAS")$subtype)))
      ),
      shiny::radioButtons("colInput", "",
                   choices = c("Maximum Capacity" = "MC_sum", "Current Output" = "TNG_sum", "Current Utilization Rate" = "cap_prop")),
      shiny::actionButton("refreshBtn", "Refresh Data", icon = icon("refresh")),
      shiny::wellPanel(
        h4("Instructions"),
        tags$div(
        p("This map provides up to date electricity generation data from the Alberta Electric System Operator.
          Select an energy type and desired output to visualize summarised generation data by transmission planning area."), style = "font-size: 14px;"),
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
