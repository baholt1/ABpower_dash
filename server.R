server <- function(input, output){
  output$table <- renderDT*(data)
    # code to build the output.
    # If it uses an input value (input$myinput),
    # the output will be rebuilt whenever
    # the input value changes
  }