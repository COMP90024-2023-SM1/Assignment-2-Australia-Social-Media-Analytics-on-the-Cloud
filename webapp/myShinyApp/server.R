# Server

# Importing libraries
library(shiny)
library(httr)
library(stringr)
library(shinythemes)
library(fontawesome)
library(shinydashboard)
library(igraph)
library(lubridate)
library(highcharter)
library(dplyr)
library(tidyr)
library(dashboardthemes)
source('helper.R')

# Set a global theme highcharter plot
options(highcharter.theme = hc_theme_hcrt())

server <- shinyServer(function(input, output) {
  
  auto_refresh <- reactiveTimer(100000)
  
  get_api_data <- reactive({
    auto_refresh()
    
    tweet_month <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-month?reduce=true&group=true&update=false')
    tweet_month <- fromJSON(content(tweet_month, "text", encoding = "UTF-8"))$rows
    tweet_month <- tweet_month %>%
      mutate(key = sapply(key, function(x) paste(unlist(x), collapse = ", ")))
    tweet_month <- tweet_month %>%
      separate(key, into = c("year", "month"), sep = ", ") %>%
      mutate(
        date = paste(year, month, "01", sep = "-"),
        date = ymd(date),
        month_label = month(date, label = TRUE),
        YearMonth = paste(month_label, year, sep = " ")
      ) %>%
      select(-date, -month_label)
    
    return(tweet_month)
  })
  
  # Value box for incident count
  output$total_tweet <- renderValueBox({
    print(input$dateRange)
    valueBox(
      value = total_tweet$rows[[1]]$value, subtitle = "Total Tweets",
      icon = fa_i("twitter"), color = "light-blue"
    )
  })

  
  output$aus_map <- renderHighchart({
    if (length(input$map_state) == 0) {
      hcmap("countries/au/au-all", borderColor = "#808080", borderWidth = 0.1, showInLegend = FALSE) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_chart(backgroundColor = "#D8F9FF") %>%
      hc_title(text = "General Tweet Statistics of Australia in 2022 <small>(Hover for more detail)</small>", 
               useHTML = T)
    }
    else{
      if (length(input$map_state) == 2) {
        data <- generalTweet_info
      } else if (input$map_state == 'Greater Capital City') {
        data <- subset(generalTweet_info, !grepl("^Rural", key))
      } else {
        data <- subset(generalTweet_info, grepl("^Rural", key))
      }
      colnames(data) <- c('key', 'z', 'lat', 'lon')
      
      hcmap("countries/au/au-all", borderColor = "#808080", borderWidth = 0.1, showInLegend = FALSE) %>%
        hc_exporting(enabled = TRUE) %>%
        hc_chart(backgroundColor = "#D8F9FF") %>%
        hc_add_series(name = "Cities/Areas", type = "mapbubble", data = data, maxSize = "15%") %>%
        #hc_add_series(name = "Cities/Areas",
        #  type = "mappoint", data = data, hcaes(x = lon, y = lat, name = key), color = "red",
        #  marker = list(radius = 5)) %>%
        hc_title(text = "General Tweet Statistics of Australia in 2022 <small>(Hover for more detail)</small>", 
                 useHTML = T) %>%
        hc_tooltip(pointFormat = '<b>{point.key}</b>
                   <br/><b>Number of tweets:</b> {point.z}')
    }
  })
  
  output$tweet_timeline <- renderHighchart({
    tweet_month <- get_api_data()
    hchart(tweet_month, "spline", hcaes(x = YearMonth, y = value),
           tooltip = list(pointFormat = "Number of Tweets Made: <b>{point.value}</b>")) %>%
      hc_title(text = "Number of Tweets Made in 2022") %>%
      hc_yAxis(title = list(text = "Number of Tweets")) %>%
      hc_xAxis(title = list(text = "Month"))
  })

})