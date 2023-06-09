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
  
serverHome = function(input, output){
  auto_refresh <- reactiveTimer(5000)
  
  get_mastodon_count <- reactive({
    auto_refresh()
    legacy_social_count <- GET('http://172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false')
    legacy_social_count <- fromJSON(httr::content(legacy_social_count, "text", encoding = "UTF-8"))$rows$value
    legacy_world_count <- GET('http://172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false')
    legacy_world_count <- fromJSON(httr::content(legacy_world_count, "text", encoding = "UTF-8"))$rows$value
    stream_social_count <- GET('http://172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false')
    stream_social_count <- fromJSON(httr::content(stream_social_count, "text", encoding = "UTF-8"))$rows$value
    stream_world_count <- GET('http://172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false')
    stream_world_count <- fromJSON(httr::content(stream_world_count, "text", encoding = "UTF-8"))$rows$value
    total_count <- legacy_social_count + legacy_world_count + stream_social_count + stream_world_count
    
    return(total_count)
  })
  
  # Value box for incident count
  output$total_tweet <- renderValueBox({
    valueBox(
      value = total_tweet$value, subtitle = "Total Tweets",
      icon = fa_i("twitter"), color = "aqua"
    )
  })
  
  output$total_mastodon <- renderValueBox({
    valueBox(
      value = get_mastodon_count(), subtitle = "Total Toots",
      icon = fa_i("mastodon"), color = "purple"
    )
  })
  
  output$aus_map <- renderHighchart({
    
    base_map <- hcmap(
      "countries/au/au-all",
      data = state_population_data,
      value = "population",
      joinBy = c("hc-key", "state"),
      name = "State Population",
      dataLabels = list(enabled = FALSE, format = "{point.name}"),
      borderColor = "#808080",
      borderWidth = 0.1,
      showInLegend = FALSE
    ) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_chart(backgroundColor = "#D8F9FF") %>%
      hc_title(text = "Tweet and Population Statistics <small>(Hover for more detail)</small>", useHTML = T) %>%
      hc_colorAxis(minColor = '#FFEBEE', maxColor = '#FF7F7F')
    
    
    if (length(input$map_state) > 0) {
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
      colorGCC = "purple"  
      
      colorRural = "#069AF3"
      
      data <- data %>%
        mutate(color = ifelse(grepl("Rural", key), colorRural, colorGCC)) %>%
        mutate(area = ifelse(grepl("Rural", key), "Rural", "Greater Capital City"))
      
      data <- data %>%
        filter(area %in% input$map_state)
      
      base_map <- base_map %>%
        hc_add_series(type = "mapbubble", data = data, maxSize = "15%", showInLegend = TRUE, name = "Greater Capital City", color = colorGCC) %>%
        hc_add_series(type = "mapbubble", data = data, maxSize = "15%", showInLegend = TRUE, name = "Rural", color = colorRural)
    }
    
    # Unified tooltip that checks the series name before determining what information to display
    base_map <- base_map %>%
      hc_tooltip(
        useHTML = TRUE,
        formatter = JS("
        function() {
          if (this.series.name == 'State Population') {
            return '<b>' + this.series.name + '</b><br><b>' + this.point.name + '</b>: ' + this.point.value;
          } else {
            return '<b>' + this.point.key + '</b><br/><b>Number of tweets:</b> ' + this.point.z;
          }
        }
      ")
      ) %>%
      hc_legend(enabled = TRUE, title = list(text = "State Population"))
    
    return(base_map)
  })
  
  
  
  output$tweet_timeline <- renderHighchart({
    hchart(tweet_month, "spline", hcaes(x = YearMonth, y = value),
           tooltip = list(pointFormat = "Number of Tweets Made: <b>{point.value}</b>")) %>%
      hc_title(text = "Twitter Time Machine: Tracking Tweet Distribution of 2022") %>%
      hc_yAxis(title = list(text = "Number of Tweets")) %>%
      hc_xAxis(title = list(text = "Month")) %>%
      hc_colors('#FBE106')
  })
  
  output$home_wordcloud <- renderHighchart({
    hchart(home_wordcloud, "wordcloud", hcaes(name = key, weight = value)) %>%
      hc_tooltip(pointFormat = '<b>Count</b>: {point.weight}') %>%
      hc_title(text = "Clouds of Conversation: Mapping Australia's Twitter Top Words in 2022")
  })

}