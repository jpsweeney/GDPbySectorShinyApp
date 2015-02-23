data(mtcars)

shinyServer(
        function(input,output) {
                output$inputValue <- renderPrint({input$cutoff})
                output$prediction <- renderPrint({mtcars[mtcars$mpg < input$cutoff,]})
        })
