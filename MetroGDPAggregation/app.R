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
library(stats)
library(ggplot2)
library(tseries)

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
first_year = as.numeric(min(metro_gdp$TimePeriod))

# Define UI
ui <- fluidPage(
              titlePanel("Metro GDP Growth"),
              sidebarLayout(
                sidebarPanel(
                    
                  # Select type of trend to plot
                   checkboxGroupInput("selection", "Choose metros:",
                                     choiceNames = (metro_names),
                                     choiceValues = (metro_names)

                    )
                  ),
                  
                  # Output: Description, lineplot, and reference
                  mainPanel(
                    textOutput(outputId = "txt"),
                    textOutput(outputId = "desc"),
                    tags$a(href = "www.bea.gov", "Source: U.S. Bureau of Ecoomic Analysis", target = "_blank")
                  )
                )
)

# Define server function
server <- function(input, output, session) {
  
  # Subset data
  
  #dt1 <- metro_gdp[metro_gdp$GeoName %in% input$selection, sum(DataValue), by = .(TimePeriod)]
  
  output$txt <- renderText(selection)
  # turn aggregate the data for selected metros
  #dt1 <- metro_gdp[metro_gdp$GeoName %in% selection, sum(DataValue), by = .(TimePeriod)]
  
  #convert table to time series and calculate percentage change
  #ts1 <- ts(dt1, start = first_year, frequency = 1)
  #growthRates <- ts1[,2]/stats::lag(ts1[,2],-1) - 1
  
  #dt2 <- data.table(as.numeric(time(growthRates)), as.numeric(growthRates))
    
 
  
}

# Create Shiny object
shinyApp(ui = ui, server = server)