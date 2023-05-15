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
library(rgdal)
source('helper.R')
  
serverHome = function(input, output){
  auto_refresh <- reactiveTimer(100000)
  get_tweet_month <- reactive({
    auto_refresh()
    tweet_month <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-month?reduce=true&group=true&update=false')
    tweet_month <- fromJSON(httr::content(tweet_month, "text", encoding = "UTF-8"))$rows
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
      } else if (input$map_state == 'Rural') {
        data <- subset(generalTweet_info, grepl("^Rural", key))
        
      }
      
      data <- data %>%
        filter(date >= input$dateRange[1] & date <= input$dateRange[2]) %>%
        group_by(key) %>% summarise(value = sum(value))
      data <- merge(data, capital_cities, by = "key")
      colnames(data) <- c('key', 'z', 'lat', 'lon')
      
      # Add the bubble color column based on the condition
      colorGCC = "#67bd7e"
      colorRural = "#6795bd"
      
      data <- data %>%
        mutate(color = ifelse(grepl("Rural", key), colorRural, colorGCC)) %>%
        mutate(area = ifelse(grepl("Rural", key), "Rural", "Greater Capital City"))
      
      data <- data %>%
        filter(area %in% input$map_state)
      
      hcmap("countries/au/au-all", borderColor = "#808080", borderWidth = 0.1, showInLegend = FALSE) %>%
        hc_exporting(enabled = TRUE) %>%
        hc_chart(backgroundColor = "#D8F9FF") %>%
        hc_add_series(type = "mapbubble", data = data, maxSize = "15%", showInLegend = TRUE, name = "Greater Capital City", color = colorGCC) %>%
        hc_add_series(type = "mapbubble", data = data, maxSize = "15%", showInLegend = TRUE, name = "Rural", color = colorRural) %>%
        hc_title(text = "General Tweet Statistics of Australia in 2022 <small>(Hover for more detail)</small>", 
                 useHTML = T) %>%
        hc_tooltip(pointFormat = '<b>{point.key}</b>
                   <br/><b>Number of tweets:</b> {point.z}') %>%
        hc_legend(enabled = TRUE)
    }
  })
  
  output$tweet_timeline <- renderHighchart({
    tweet_month <- get_tweet_month()
    hchart(tweet_month, "spline", hcaes(x = YearMonth, y = value),
           tooltip = list(pointFormat = "Number of Tweets Made: <b>{point.value}</b>")) %>%
      hc_title(text = "Number of Tweets Made in 2022") %>%
      hc_yAxis(title = list(text = "Number of Tweets")) %>%
      hc_xAxis(title = list(text = "Month"))
  })
  
  output$home_wordcloud <- renderHighchart({
    hchart(home_wordcloud, "wordcloud", hcaes(name = key, weight = value)) %>%
      hc_tooltip(pointFormat = '<b>Count</b>: {point.weight}') %>%
      hc_title(text = "Clouds of Conversation: Mapping Australia's Twitter Top Words in 2022")
  })

}