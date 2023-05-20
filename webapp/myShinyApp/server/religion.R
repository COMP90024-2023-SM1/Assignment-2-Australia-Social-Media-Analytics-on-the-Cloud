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
  
serverReligion = function(input, output){
  
  count_religion_response <- GET("http://admin:admin@172.26.128.113:5984//twitter_data/_design/customDoc/_view/count-religion?reduce=true&group=true&update=false")
  count_religion <- as.data.frame(fromJSON(httr::content(count_religion_response,"text", encoding = "UTF-8"))$rows)
  
  month_religion_reponse <- GET("http://admin:admin@172.26.128.113:5984//twitter_data/_design/customDoc/_view/count-religion-tweet-month?reduce=true&group=true&update=false")
  month_religion <- as.data.frame(fromJSON(httr::content(month_religion_reponse,"text", encoding = "UTF-8"))$rows)
                                  
  
  output$christianity <- renderHighchart({
    # Define color options
    col <- c('#FBE106', '#8080FF')
    
    highchart() %>%
      hc_exporting(enabled = TRUE) %>%
      hc_title(text = "Christianity Population and Christian-related Tweet In Each Location") %>%
      hc_chart(zoomType = "x") %>%
      hc_yAxis_multiples(
        list(title = list(text = "Christian Population Percentage %"), showLastLabel = TRUE, opposite = FALSE),
        list(title = list(text = "Christian-related Tweet Percentage %"), opposite = TRUE)
      ) %>%
      hc_xAxis(
        title = list(text = "Australian Location"),
        categories = sudo_data$key) %>%
      hc_add_series(sudo_data, name = "Christian Population Percentage %", "column", hcaes(x = key, y = christianity_percentage)) %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000))) %>%
      hc_add_series(sudo_data, name = "Christian-related Tweet Percentage %", "spline", hcaes(x = key, y = percent), yAxis = 1) %>%
      hc_colors(col) %>%
      # Use shared tooltips
      hc_tooltip(crosshairs = TRUE, shared = TRUE)

  })
  output$christrianity_date_range <- renderHighchart({
    highchart() %>%
      hc_chart(type = "spline") %>%
      hc_title(text = "Christian-related Tweet Time Distribution in 2022") %>%
      hc_xAxis(categories = month_religion$key) %>%
      hc_yAxis(title = list(text = "Tweet Count")) %>%
      hc_add_series(name = "Tweet Count", data = month_religion$value) %>%
      hc_exporting(enabled = TRUE) %>%
      hc_colors('red')
  })
  
  
  output$christianity_percentage_2016 <- renderValueBox({
    valueBox(
      value = paste0(round(mean(sudo_data$christianity_percentage), 2), "%"), 
      subtitle = "Australia Christianity Population (2016)",
      icon = icon("earth-oceania", class='fa-spin'), 
      color = "blue"
    )
  })
  
  output$christianity_percentage_twitter <- renderValueBox({
    valueBox(
      value = paste0(round(count_religion$value/total_tweet$value * 100, 2), "%"), 
      subtitle = "Christian-related Tweets Proportion",
      icon = icon("twitter"), color="aqua"
    )
  })
  
  # auto_refresh <- reactiveTimer(50000)
  
  get_mastodon_religion_count <- reactive({
    # auto_refresh()
    legacy_social_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/count-religion?reduce=true&group=true&update=false')
    legacy_social_count <- fromJSON(httr::content(legacy_social_count, "text", encoding = "UTF-8"))$rows$value
    legacy_world_count <- GET('http://admin:admin@172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/count-religion?reduce=true&group=true&update=false')
    legacy_world_count <- fromJSON(httr::content(legacy_world_count, "text", encoding = "UTF-8"))$rows$value
    stream_social_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/count-religion?reduce=true&group=true&update=false')
    stream_social_count <- fromJSON(httr::content(stream_social_count, "text", encoding = "UTF-8"))$rows$value
    stream_world_count <- GET('http://admin:admin@172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/count-religion?reduce=true&group=true&update=false')
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
  
  output$christianity_percentage_mastodon <- renderValueBox({
    valueBox(
      value = paste0(round(get_mastodon_religion_count()/get_mastodon_count() * 100, 2), "%"), 
      subtitle = "Christian-related Toots Proportion",
      icon = fa_i("mastodon"),color="purple"
    )
  })
}
