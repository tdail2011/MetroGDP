#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# Load packages
library(shiny)
library(shinydashboard)
library(dplyr)
library(bea.R)
library(readr)

# Load data

beaKey <- '056A7955-BF36-4C2C-BA21-E3C2B46A0C35'
beaSpecs <- list(
  'UserID' = beaKey ,
  'Method' = 'GetData',
  'datasetname' = 'RegionalProduct',
  'Component' = 'QI_MAN',
  'GeoFips' = 'MSA',
  'IndustryId' = '1',
  'Year' = 'LAST5',
  'ResultFormat' = 'json'
);
metro_gdp <- beaGet(beaSpecs, asWide = FALSE)
metro_names <- unique(metro_gdp$GeoName)

# Define UI
ui <- fluidPage(
              titlePanel("Metro GDP Growth"),
              sidebarLayout(
                sidebarPanel(
                    
                  # Select type of trend to plot
                   checkboxGroupInput("metro_area", "Choose icons:",
                                     choiceNames = (metro_names),
                                     choiceValues = (metro_names)
                                       
                  
                  
               #   selectInput(inputId = "metro_area", label = strong("Area"),
                #                choices = unique(metro_gdp$GeoName),
                 #               selected = "United States (Metropolitan Portion)"),
                    
                    # Select date range to be plotted
                    #selectInput(inputId = "start", strong("Start Year"), start = "2012", end = "2016",
                    #               min = "2012", max = "2016"),
                    
                    # Select whether to overlay smooth trend line
                    #checkboxInput(inputId = "smoother", label = strong("Overlay smooth trend line"), value = FALSE),
                    
                    # Display only if the smoother is checked
                   # conditionalPanel(condition = "input.smoother == true",
                                     #sliderInput(inputId = "f", label = "Smoother span:",
                                    #             min = 0.01, max = 1, value = 0.67, step = 0.01,
                                     #            animate = animationOptions(interval = 100)),
                                     #HTML("Higher values give more smoothness.")
                    )
                  ),
                  
                  # Output: Description, lineplot, and reference
                  mainPanel(
                    plotOutput(outputId = "lineplot", height = "300px"),
                    textOutput(outputId = "desc"),
                    tags$a(href = "www.bea.gov", "Source: U.S. Bureau of Ecoomic Analysis", target = "_blank")
                  )
                )
)

# Define server function
server <- function(input, output) {
  
  # Subset data
  selected_metros <- reactive({
    #req(input$date)
    #validate(need(!is.na(input$date[1]) & !is.na(input$date[2]), "Error: Please provide both a start and an end date."))
    #validate(need(input$date[1] < input$date[2], "Error: Start date should be earlier than end date."))
    metro_gdp %>%
      filter(
       GeoName == input$metro_area
    #    date > as.POSIXct(2012) & date < as.POSIXct(2016)
       )
    })
  
  
  # Create scatterplot object the plotOutput function is expecting
  output$lineplot <- renderPlot({
    color = "#434343"
    par(mar = c(4, 4, 1, 1))
    plot(x = selected_metros()$TimePeriod, y = selected_metros()$DataValue, type = "l",
         xlab = "Date", ylab = "Real GDP Growth (Quantity Index)", col = color, fg = color, col.lab = color, col.axis = color)
    # Display only if smoother is checked
    #if(input$smoother){
     # smooth_curve <- lowess(x = as.numeric(selected_metros()$TimePeriod), y = selected_metros()$DataValue, f = input$f)
      #lines(smooth_curve, col = "#E6553A", lwd = 3)
  })
  
  # Pull in description of trend
  #output$desc <- renderText({
  #  trend_text <- filter(trend_description, type == input$type) %>% pull(text)
  #  paste(trend_text, "The index is set to 2009 = 100.")
  }


# Create Shiny object
shinyApp(ui = ui, server = server)