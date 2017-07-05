# ---- Technical Demo: Monitoring Philadelphia's Imminently Dangerous Buildings ----

# 'Global' Script

# This script runs before anything else happens in the app. It is a good place to 
# load and prepare data or define helper functions


# attach packages
library(dplyr)

# load data
load("Technical_Demo_data.Rdata")

# generate dataset of unique addressed
dd <- distinct(da, address_key, .keep_all = TRUE)

# helper function to define time range for timeline
# input a vector of inspection dates and return another 
# vector of length two with start and end points for the timeline
getTlWin <- function(start) {
  
  startTime = as.Date(min(start))
  
  if (length(unique(start)) > 1) {
    endTime <- as.Date(max(start))
  } else {
    endTime <- Sys.Date()
  }
  
  buffer <- (endTime - startTime) * 0.1
  
  endpoints <- c(startTime - buffer, endTime + (2 * buffer))
  
  return(endpoints)
}


