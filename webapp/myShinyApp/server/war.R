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
  auto_refresh <- reactiveTimer(50000)
  
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
      hc_title(text = "Number of Tweets related to the Russo-Ukraine War 2022") %>%
      hc_yAxis(title = list(text = "Number of Tweets")) %>%
      hc_xAxis(title = list(text = "Month")) %>%
      hc_colors('#FBE106')
  })
  
  get_mastodon_lang <- reactive({
    auto_refresh()
    legacy_social_lang <- GET('http://172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    legacy_world_lang <- GET('http://172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    streaming_social_lang <- GET('http://172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    streaming_world_lang <- GET('http://172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    legacy_social_lang <- as.data.frame(fromJSON(httr::content(legacy_social_lang, "text", encoding = "UTF-8"))$rows)
    legacy_world_lang <- as.data.frame(fromJSON(httr::content(legacy_world_lang, "text", encoding = "UTF-8"))$rows)
    streaming_social_lang <- as.data.frame(fromJSON(httr::content(streaming_social_lang, "text", encoding = "UTF-8"))$rows)
    streaming_world_lang <- as.data.frame(fromJSON(httr::content(streaming_world_lang, "text", encoding = "UTF-8"))$rows)
    
    combined_df <- bind_rows(streaming_social_lang, streaming_world_lang, legacy_social_lang, legacy_world_lang) %>%
      group_by(key) %>%
      summarise(total_value = sum(value))
    combined_df <- as.data.frame(combined_df)
    
    return(combined_df)
  })
  
  output$sudo_war_lang <- renderHighchart({
    data_lang %>%
      hchart("pie", innerSize = '60%', hcaes(x = key, y = freq), showInLegend = TRUE, 
             dataLabels = list(enabled = FALSE), allowPointSelect = TRUE) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_colors(c('#3cdfff', '#ffb6c1')) %>%
      hc_title(text = "The Linguistic Landscape of Australia Obtained from SUDO Data (2016)") %>%
      hc_tooltip(pointFormat = 'Percentage of Tweets: <b>{point.y:.2f}%</b>') %>%
      hc_legend(labelFormat = '{name}')
  })
  
  
  output$twitter_war_lang <- renderHighchart({
    data <- GET('http://172.26.128.113:5984/twitter_data/_design/customDoc/_view/war-language?reduce=true&group=true&update=false')
    data <- as.data.frame(fromJSON(httr::content(data, "text", encoding = "UTF-8"))$rows)
    
    data %>%
      mutate(freq = round(value/sum(value), 4) * 100) %>%
      hchart("pie", innerSize = '60%', hcaes(x = key, y = freq), showInLegend = TRUE, 
             dataLabels = list(enabled = FALSE), allowPointSelect = TRUE) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_colors(c('#3cdfff', '#ffb6c1')) %>%
      hc_title(text = "The Linguistic Landscape of Tweets Related to the Russo-Ukraine War") %>%
      hc_tooltip(pointFormat = 'Percentage of Tweets: <b>{point.freq:.2f}%</b>') %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.4">{n}</span>')
  })
  
  output$mastodon_war_lang <- renderHighchart({
    data <- get_mastodon_lang()
    data %>%
      mutate(freq = round(total_value/sum(total_value), 4) * 100) %>%
      hchart("pie", innerSize = '60%', hcaes(x = key, y = freq), showInLegend = TRUE, 
             dataLabels = list(enabled = FALSE), allowPointSelect = TRUE) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_colors(c('#3cdfff', '#ffb6c1')) %>%
      hc_title(text = "The Linguistic Landscape of Toots Related to the Russo-Ukraine War") %>%
      hc_tooltip(pointFormat = 'Percentage of Tweets: <b>{point.freq:.2f}%</b>') %>%
      hc_legend(labelFormat = '{name} <span style="opacity: 0.4">{n}</span>')
  })
  
  get_mastodon_war_count <- reactive({
    auto_refresh()
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
  
  response_twitter <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-war?reduce=true&group=true&update=false')
  count_war_twitter <- as.data.frame(fromJSON(httr::content(response_twitter,"text", encoding = "UTF-8"))$rows)
  print(count_war_twitter)
  output$war_percentage_twitter <- renderValueBox({
    valueBox(
      value = paste0(round(count_war_twitter$value/total_tweet$value * 100, 2), "%"), subtitle = "Russo-Ukraine War related Tweet Proportion 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$war_percentage_mastodon <- renderValueBox({
    valueBox(
      value = paste0(round(get_mastodon_war_count()/get_mastodon_count() * 100, 2), "%"), subtitle = "Russo-Ukraine War related Toot Proportion 2023",
      icon = fa_i("mastodon"),color="purple"
    )
  })
  
  output$war_total_twitter <- renderValueBox({
    valueBox(
      value = paste0(count_war_twitter$value), subtitle = "Total Number of Russo-Ukraine War related Tweets 2022",
      icon = fa_i("twitter"),color="aqua"
    )
  })
  
  output$war_total_mastodon <- renderValueBox({
    valueBox(
      value = get_mastodon_war_count(), subtitle = "Total Number of Russo-Ukraine War related Toots 2023",
      icon = fa_i("mastodon"), color = "purple"
    )
  })
  
}