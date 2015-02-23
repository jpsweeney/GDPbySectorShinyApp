shinyUI(
        pageWithSidebar(
                headerPanel("Car Selecter"),
                
                sidebarPanel(
                        numericInput('cutoff', 'Minimum MPG', 20, min = 10, max = 35, step = 1),
                        submitButton('Submit')
                ),
                mainPanel(
                        h3('Possible Cars'),
                        h4('You chose a cutoff of'),
                        verbatimTextOutput("inputValue"),
                        h3('Which means the cars in the MPG range you chose are'),
                        verbatimTextOutput("prediction")
                        )
                )
        )
