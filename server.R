# ---- Technical Demo: Monitoring Philadelphia's Imminently Dangerous Buildings ----

# Server Script

# This script defines what is going on behind the scenes. You can use any available
# R code to create elements (e.g. text, plots, tables, etc.) that will be output to 
# the ui.


# attach packages
library(shiny)
library(dplyr)
library(ggthemes)
library(scales)
library(DT)
library(htmlwidgets)
library(timevis)
library(rsconnect)

# The server script is comprised of one function with two parameters: a list of input
# and another of outputs. Inputs are information that come from rective events in the 
# ui. You can use these inputs to modify ui elements.
function(input, output) {
  
  # output a leaflet map
  output$map <- renderLeaflet({
    
    leaflet(dd) %>%
      setView(lng = "-75.1635996", lat = "39.9523789", zoom = 14) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(~long, ~lat,
        layerId = ~address_key,
        radius = 5,
        color = "#89CFF0",
        stroke = TRUE,
        fillOpacity = 0.5
      )
  })
  
  # output an empty timeline
  output$tl <- renderTimevis({
     timevis() %>% 
      setWindow(
        start = getTlWin(da$violation_date)[1], 
        end = getTlWin(da$violation_date)[2]
        )
  })
  
  # output a data table of all imminently dangerous inspections
  output$table <- renderDataTable({dd}, options = list(scrollX = TRUE))

  
  # There are a number of reactive funtions that each operate differently. In this 
  # case I use the 'observe' function, which runs every time an input changes. This
  # input changes when there is a new mouse click on the map. A non-null mouse
  # click (i.e. one that lands on a point), triggers code which renders new UI
  # elements accordingly.
  observe({
    
    # create a map proxy variable
    proxy <- leafletProxy("map")
    
    # return a df containing the attributes of the the property that was clicked
    click <- input$map_marker_click
    
    # ensure that the user actually clicked on a point
    if(is.null(click)) {
      return()
    }
    
    # change map view to zoom in on the point that was clicked
    proxy %>% setView(click$lng, click$lat, zoom = 17)
    
    # find all of the inspections associated with this property
    theCase <- filter(da, address_key == click$id)
    
    # generate strings that specify the following about the property
    #   address
    address <- theCase$address
    #   owner
    owner <- theCase$owner
    #   organization
    org <- theCase$organization
    #   total number of violations
    totalViolations <- as.character(length(unique(theCase$fail_key)))
    #   days since last inspection
    duration <- (Sys.Date() - max(as.Date(theCase$most_recent_inspection))) %>% 
      as.integer() %>%
      paste0(" days")
    
    # output each of these strings to the information box in the UI
    output$addr <- renderUI(address)
    output$owner <- renderUI(owner)
    output$org <- renderUI(org)
    output$violations <- renderUI(totalViolations)
    output$duration <- renderUI(duration)
    
    # create a dataset of all inspections associated with this property
    df <- filter(da, address_key == click$id)
    
    # select certain variables that we will need to create the timeline
    dt <- select(theCase, start = inspection_date, content = inspection_outcome, group = fail_key, title = violation_description) %>%
      mutate(style = ifelse(content == "Failed", 
                            'background-color: red; color: white; border-color: white', 
                            'background-color: blue; color: white; border-color: white'))
    
    # This is a shortcut to fix a minor bug: ensure that the number of unique violation
    # ids line up the number of unique violation descriptions
    ids <- unique(dt$group)
    viols <- unique(dt$title)
    if (length(ids) != length(viols)) {
      viols <- head(dt$title, length(ids))
    }
    
    # create a timeline visualization
    tv <- timevis(dt, 
                  groups = data.frame(id = ids, content = viols),
                  showZoom = TRUE,
                  fit = TRUE)
    
    # render the timeline visualization to the ui with an appropriate beginning and
    # end points
    output$tl <- renderTimevis({
      setWindow(tv, getTlWin(dt$start)[1], getTlWin(dt$start)[2])
    })
    
    # create and render a data table of all inspections associated with the address in question
    output$table <- renderDataTable({df}, options = list(scrollX = TRUE))
  })
}



