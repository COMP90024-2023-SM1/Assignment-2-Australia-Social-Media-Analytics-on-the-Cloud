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
  
serverWar = function(input, output){
  
  output$war_trend_tweet <- renderHighchart({
    war_month_data <- GET('http://172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-war-by-date?reduce=true&group=true&update=false')
    war_month_data <- as.data.frame(fromJSON(httr::content(war_month_data, "text", encoding = "UTF-8"))$rows)
    war_month_data <- war_month_data %>% mutate(key = sapply(key, function(x) paste(unlist(x), collapse = ", ")))
    war_month_data <- war_month_data %>%
      separate(key, into = c("year", "month"), sep = ", ") %>%
      mutate(
        date = paste(year, month, "01", sep = "-"),
        date = ymd(date),
        month_label = month(date, label = TRUE),
        YearMonth = paste(month_label, year, sep = " ")
        ) %>%
      select(-date, -month_label)
    
    hchart(war_month_data, "spline", hcaes(x = YearMonth, y = value),
           tooltip = list(pointFormat = "Number of Tweets Made: <b>{point.value}</b>")) %>%
      hc_title(text = "Number of Tweets Made About Russo-Ukraine War in 2022") %>%
      hc_yAxis(title = list(text = "Number of Tweets")) %>%
      hc_xAxis(title = list(text = "Month")) %>%
      hc_colors('#FBE106')
  })
  
  output$twitter_war_lang <- renderHighchart({
    data <- GET('http://172.26.128.113:5984/twitter_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    data <- as.data.frame(fromJSON(httr::content(data, "text", encoding = "UTF-8"))$rows)
    
    data %>%
      mutate(freq = round(value/sum(value), 3)) %>%
      hchart("pie", innerSize = '60%', hcaes(x = key, y = freq*100), showInLegend = TRUE, 
             dataLabels = list(enabled = FALSE), allowPointSelect = TRUE) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_colors(c('#ffb6c1', '#3cdfff')) %>%
      hc_title(text = "The Linguistic Landscape of Australia in the Russo-Ukraine War") %>%
      hc_tooltip(pointFormat = 'Percentage of Tweets: <b>{point.freq:.2f}%</b>') %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.4">{n}</span>')
  })
  
  output$mastodon_war_lang <- renderHighchart({
    
  })
  
  get_mastodon_war_count <- reactive({
    # auto_refresh()
    legacy_social_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
    legacy_social_count <- fromJSON(httr::content(legacy_social_count, "text", encoding = "UTF-8"))$rows$value
    legacy_world_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
    legacy_world_count <- fromJSON(httr::content(legacy_world_count, "text", encoding = "UTF-8"))$rows$value
    stream_social_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
    stream_social_count <- fromJSON(httr::content(stream_social_count, "text", encoding = "UTF-8"))$rows$value
    stream_world_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
    stream_world_count <- fromJSON(httr::content(stream_world_count, "text", encoding = "UTF-8"))$rows$value
    total_count <- legacy_social_count + legacy_world_count + stream_social_count + stream_world_count
    
    return(total_count)
  })
  
  get_mastodon_count <- reactive({
    # auto_refresh()
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
  
  response_twitter <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
  count_war_twitter <- as.data.frame(fromJSON(httr::content(response_twitter,"text", encoding = "UTF-8"))$rows)
  print(count_war_twitter)
  output$war_percentage_twitter <- renderValueBox({
    valueBox(
      value = paste0(round(count_war_twitter$value/total_tweet$value * 100, 2), "%"), subtitle = "Percentage of Russia vs. Ukraine War Mentioned in Twitter 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$war_percentage_mastodon <- renderValueBox({
    valueBox(
      value = paste0(round(get_mastodon_war_count()/get_mastodon_count() * 100, 2), "%"), subtitle = "Percentage of Russia vs. Ukraine War Mentioned in Mastodon 2023",
      icon = fa_i("mastodon"),color="purple"
    )
  })
  
  output$war_total_twitter <- renderValueBox({
    valueBox(
      value = paste0(count_war_twitter$value), subtitle = "Total Number of Russia vs. Ukraine War Mentioned in Twitter 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$war_total_mastodon <- renderValueBox({
    valueBox(
      value = get_mastodon_war_count(), subtitle = "Total Number of Russia vs. Ukraine War Mentioned in Mastodon 2023",
      icon = fa_i("mastodon"), color = "purple"
    )
  })
  
}