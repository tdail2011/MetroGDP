library(bea.R)
library(readr)
library(tseries)
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

# what's the first year in the data?
first_year = as.numeric(min(metro_gdp$TimePeriod))

# Select metros (use checkboxGroupInput)
selection <- c('Akron, OH (Metropolitan Statistical Area)', 'Abilene, TX (Metropolitan Statistical Area)')

# turn aggregate the data for selected metros
dt1 <- metro_gdp[metro_gdp$GeoName %in% selection, sum(DataValue), by = .(TimePeriod)]

#convert table to time series and calculate percentage change
ts1 <- ts(dt1, start = first_year, frequency = 1)
growthRates <- ts1[,2]/lag(ts1[,2],-1) - 1
plot(growthRates, xlab = 'Year', ylab = 'Percent Change', col = "blue")
