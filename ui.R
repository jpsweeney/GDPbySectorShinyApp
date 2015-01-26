
library(shiny)
shinyUI(pageWithSidebar(
        headerPanel("GDP by Sector"),
        sidebarPanel(
                h3('Options'),
                selectInput(inputId = 'dropbox', label = 'Sector', choices = List),
                numericInput('id1', 'Quarters', 20, min=0, max=200, step=1),
                dateInput("date", "Date:")
                
                ),
        mainPanel(
                h3('Nominal and Real Growth Rate Charts'),
                plotOutput("chart"),
                plotOutput("chart2")
                )
        ))
