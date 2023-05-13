# Server

# Importing libraries
library(shiny)
library(httr)
library(stringr)
library(shinythemes)
library(fontawesome)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dplyr)
library(tidyr)
library(dashboardthemes)
source('helper.R')

# Set a global theme highcharter plot
options(highcharter.theme = hc_theme_hcrt())

server <- shinyServer(function(input, output) {
  
  # Value box for incident count
  output$total_tweet <- renderValueBox({
    valueBox(
      value = total_tweet$rows[[1]]$value, subtitle = "Total Tweets",
      icon = fa_i("twitter"), color = "light-blue"
    )
  })
  
  capital_cities <- data.frame(
    city = c("Canberra", "Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Darwin", "Hobart"),
    lat = c(-35.2809, -33.8688, -37.8136, -27.4698, -31.9505, -34.9285, -12.4634, -42.8821),
    lon = c(149.1300, 151.2093, 144.9631, 153.0251, 115.8605, 138.6007, 130.8456, 147.3272)
  )
  
  output$aus_map <- renderHighchart({
    hcmap("countries/au/au-all") %>%
      hc_add_series(
        type = "mappoint",
        data = capital_cities,
        hcaes(x = lon, y = lat, name = city),
        color = "red",
        marker = list(radius = 5)
      )
  })
  
  output$year_casualty <- renderHighchart({
    tweet_month$key <- as.character(tweet_month$key)
    tweet_month$formatted_time <- format(as.Date(paste0(tweet_month$key, ", 01"), "%Y, %m, %d"), "%b, %Y")
    
    hchart(tweet_month, "spline", hcaes(x = formatted_time, y = value)) %>%
      hc_xAxis(type = "datetime", labels = list(format = "{value:%b %Y}"))
  })
  
  
  
  
})
