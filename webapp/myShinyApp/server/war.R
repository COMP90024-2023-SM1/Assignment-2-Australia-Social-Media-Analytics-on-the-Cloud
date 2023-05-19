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
}