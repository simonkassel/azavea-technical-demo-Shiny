# ---- Technical Demo: Monitoring Philadelphia's Imminently Dangerous Buildings ----

# UI Script

# In this script you will define the layout of the apps user interface. 
# You will reference dynamic elements that will be modified within the server script.


# attach packages
library(shiny)
library(leaflet)
library(shinythemes)
library(timevis)

# There are several methods for laying out a Shiny UI that give you varying degrees of
# flexibility. In this example I have used a fluid layout which allows you to position
# ui elements according to a 12 column grid.

fluidPage(theme = shinytheme("paper"),
  
  # title
  fluidRow(
    column(width = 10, offset = 1,
      h1("Monitor Philadelphia's 'imminently dangerous' buildings", style = 'text-align:center; font-weight: bold')
    )
  ),

  # separator
  div(style = 'height:50px'),
  
  # map/sidebar
  fluidRow(
    
    # sidebar with text
    column(width = 3, offset = 1,
      h4("Address:", style = 'font-weight: bold'),
      h5(
        htmlOutput("addr")
      ),
      h4("Owner:", style = 'font-weight: bold'),
      h5(
        htmlOutput("owner")
      ),
      h4("Organization:", style = 'font-weight: bold'),
      h5(
        htmlOutput("org")
      ),
      h4("Total violations:", style = 'font-weight: bold'),
      h5(
        htmlOutput("violations")
      ),
      h4("Since last inspection:", style = 'font-weight: bold'),
      h5(
        htmlOutput("duration")
      )
    ),
    
    # leaflet map
    column(width = 6, offset = 1,
      leafletOutput("map")
    )
  ),
  
  # separator
  div(style = 'height:50px'),
  
  # timeline
  fluidRow(
    column(width = 10, offset = 1,
    timevisOutput("tl"))
  ),
  
  # separator
  div(style = 'height:50px'),
  
  # table
  fluidRow(
    column(
      width = 10, offset = 1,
      dataTableOutput(outputId = "table")
    )
  )
)



