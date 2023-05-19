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
  
serverDepression = function(input, output){
  
  output$depression_weekday_hour <- renderHighchart({
    depression_week_hour$hour <- as.numeric(depression_week_hour$hour)
    depression_week_hour$weekday <- factor(depression_week_hour$weekday, levels = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), ordered = TRUE)
    depression_week_hour <- depression_week_hour %>%
      arrange(weekday, hour)
    
    hchart(name = "Tweet Depression", depression_week_hour, "heatmap", hcaes(x = hour, y = weekday, value = value)) %>%
      hc_title(text = "Twitter - Weekday-Hourly Depression-related Tweet Frequency (AEST)") %>%
      hc_xAxis(title = list(text = "Hour of Day")) %>%
      hc_yAxis(title = list(text = "Weekday")) %>%
      hc_colorAxis(stops = color_stops(n = 10, colors = c("white", "red"))) %>%
      hc_tooltip(pointFormat = '<b>{point.weekday} {point.hour}:00</b>
                   <br/><b>Number of tweets:</b> {point.value}') %>% 
      hc_legend(align = "right", layout = "vertical",
                margin = 0, verticalAlign = "top",
                y = 60, symbolHeight = 250)
  })
  
  output$depression_weekday_hour_m <- renderHighchart({
    depression_week_hour_m_total$hour <- as.numeric(depression_week_hour_m_total$hour)
    depression_week_hour_m_total$weekday <- factor(depression_week_hour_m_total$weekday, levels = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'), ordered = TRUE)
    depression_week_hour_m_total <- depression_week_hour_m_total%>%
      arrange(weekday, hour)
    
    hchart(name = "Toot Depression", depression_week_hour_m_total, "heatmap", hcaes(x = hour, y = weekday, value = value)) %>%
      hc_title(text = "Mastodon - Weekday-Hourly Depression-related Toot Frequency (AEST)") %>%
      hc_xAxis(title = list(text = "Hour of Day")) %>%
      hc_yAxis(title = list(text = "Weekday")) %>%
      hc_colorAxis(stops = color_stops(n = 10, colors = c("white", "blue"))) %>%
      hc_tooltip(pointFormat = '<b>{point.weekday} {point.hour}:00</b>
                   <br/><b>Number of tweets:</b> {point.value}') %>% 
      hc_legend(align = "right", layout = "vertical",
                margin = 0, verticalAlign = "top",
                y = 60, symbolHeight = 250)
  })

  
  get_mastodon_depression_count <- reactive({
    # auto_refresh()
    legacy_social_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/count-depression?reduce=true&group=true&update=false')
    legacy_social_count <- fromJSON(httr::content(legacy_social_count, "text", encoding = "UTF-8"))$rows$value
    legacy_world_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/count-depression?reduce=true&group=true&update=false')
    legacy_world_count <- fromJSON(httr::content(legacy_world_count, "text", encoding = "UTF-8"))$rows$value
    stream_social_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/count-depression?reduce=true&group=true&update=false')
    stream_social_count <- fromJSON(httr::content(stream_social_count, "text", encoding = "UTF-8"))$rows$value
    stream_world_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/count-depression?reduce=true&group=true&update=false')
    stream_world_count <- fromJSON(httr::content(stream_world_count, "text", encoding = "UTF-8"))$rows$value
    total_count <- legacy_social_count + legacy_world_count + stream_social_count + stream_world_count
    
    return(total_count)
  })
  
  get_mastodon_count <- reactive({
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
  
  response_twitter <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-depression?reduce=true&group=true&update=false')
  count_depression_twitter <- as.data.frame(fromJSON(httr::content(response_twitter,"text", encoding = "UTF-8"))$rows)
  print(count_depression_twitter)
  output$depression_percentage_twitter <- renderValueBox({
    valueBox(
      value = paste0(round(count_depression_twitter$value/total_tweet$value * 100, 2), "%"), subtitle = "Percentage of Depression Mentioned in Twitter 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$depression_percentage_mastodon <- renderValueBox({
    valueBox(
      value = paste0(round(get_mastodon_depression_count()/get_mastodon_count() * 100, 2), "%"), subtitle = "Percentage of Depression Mentioned in Mastodon 2023",
      icon = fa_i("mastodon"),color="purple"
    )
  })
  
  output$depression_total_twitter <- renderValueBox({
    valueBox(
      value = paste0(count_depression_twitter$value), subtitle = "Total Number of Depression Mentioned in Twitter 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$depression_total_mastodon <- renderValueBox({
    valueBox(
      value = get_mastodon_depression_count(), subtitle = "Total Number of Depression Mentioned in Mastodon 2023",
      icon = fa_i("mastodon"), color = "purple"
    )
  })
  
}