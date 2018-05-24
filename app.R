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
library(bea.R)
library(ggplot2)
library(scales)
library(stats)

# Load data

beaKey <- '056A7955-BF36-4C2C-BA21-E3C2B46A0C35'
beaSpecs <- list(
  'UserID' = beaKey ,
  'Method' = 'GetData',
  'datasetname' = 'RegionalProduct',
  'Component' = 'RGDP_MAN',
  'GeoFips' = 'MSA',
  'IndustryId' = '1',
  'Year' = 'LAST10',
  'ResultFormat' = 'json'
);
metro_gdp <- beaGet(beaSpecs, asWide = FALSE)
#strip out first 10 rows for 'US Metro Portion'
metro_gdp <- metro_gdp[-(1:10)]
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
                    dataTableOutput(outputId = "tbl"),
                    #plotOutput(outputId = "plot1"),
                    plotOutput(outputId = "plot2", height = 350, width = 600),
                    tags$a(href = "www.bea.gov", "Source: U.S. Bureau of Ecoomic Analysis", target = "_blank")
                  )
                )
)

# Define server function
server <- function(input, output, session) {

  output$txt <- renderText({
    req(input$selection)
    selection <- paste(input$selection, collapse = ", ")
    paste("You chose", selection)
  })
  
  output$tbl <- renderDataTable({
    req(input$selection)
    dt1 <- metro_gdp[metro_gdp$GeoName %in% input$selection, sum(DataValue), by = .(TimePeriod)]
    ts1 <- ts(dt1, start = first_year, frequency = 1)
    growthRates <- ts1[,2]/stats::lag(ts1[,2],-1) - 1
    dt2 <- data.table("Year" = as.integer(time(growthRates)), "Growth Rates" = percent(as.numeric(growthRates)))
  })
  
#output$plot1 <- renderPlot({
#    dt1 <- metro_gdp[metro_gdp$GeoName %in% input$selection, sum(DataValue), by = .(TimePeriod)]
#    ts1 <- ts(dt1, start = first_year, frequency = 1)
#    growthRates <- ts1[,2]/stats::lag(ts1[,2],-1) - 1
#    dt2 <- data.table("Year" = as.integer(time(growthRates)), "Growth Rates" = percent(as.numeric(growthRates)))
#    plot(dt2$"Year", dt2$"Growth Rates", type = "l", xlab = "Year", ylab = "Growth Rate")
#  })
  
  output$plot2 <- renderPlot({
    req(input$selection)
    dt1 <- metro_gdp[metro_gdp$GeoName %in% input$selection, sum(DataValue), by = .(TimePeriod)]
    ts1 <- ts(dt1, start = first_year, frequency = 1)
    growthRates <- ts1[,2]/stats::lag(ts1[,2],-1) - 1
    dt2 <- data.table("Year" = as.integer(time(growthRates)), "GrowthRates" = growthRates)
    ggplot(dt2, aes(Year, GrowthRates)) + geom_point(col='#004c97', size=5)  + geom_line(col='#004c97', size=1) + theme_classic() + scale_y_continuous(labels = percent) + geom_point(col='white', size=3) + labs(title = "Real GDP Growth for Aggregated MSAs", x = "Growth Rate", y = "Year")
  })
}

# Create Shiny object
shinyApp(ui = ui, server = server)