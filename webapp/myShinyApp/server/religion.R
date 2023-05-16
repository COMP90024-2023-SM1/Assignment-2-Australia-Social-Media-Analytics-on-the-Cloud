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
  
serverReligion = function(input, output){
  #output$education_religion <- renderHighchart({
    # education_data <- education_sudo
  #  highchart() %>%
  #    hc_chart(type = "column") %>%
  #    hc_title(text = "Religion People Number and Year 12 or Above by Area") %>%
  #    hc_xAxis(categories = sudo_data$key) %>%
  #    hc_yAxis(title = list(text = "Year 12 or Above")) %>%
  #    hc_add_series(name = "Year 12 or Above", data = sudo_data$year_12_or_above) %>%
  #    hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000)))
  #  
  #})
  base_url <- "http://172.26.134.229:5984"
  database <- "twitter_data"
  design_doc <- "customDoc"
  view_name <- "count-religion"
  
  # Build the view URL
  count_religion_url <- paste0(base_url, "/", database, "/_design/", design_doc, "/_view/", view_name, "?reduce=true&update=false")
  response <- GET(count_religion_url)
  count_religion <- as.data.frame(fromJSON(httr::content(response,"text", encoding = "UTF-8"))$rows)
  output$education_religion <- renderHighchart({
    # education_data <- education_sudo
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = "Religion People Number and Year 12 or Above by Area") %>%
      hc_xAxis(categories = sudo_data$key) %>%
      hc_yAxis(title = list(text = "Year 12 or Above")) %>%
      hc_add_series(name = "2016 SUDO", data = sudo_data$year_12_or_above) %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000)))
    
  })
  
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
  
  output$christianity_percentage_2016 <- renderValueBox({
    valueBox(
      value = paste0(round(mean(sudo_data$christianity_percentage), 2), "%"), 
      subtitle = "Australia Christianity Population (2016)",
      icon = fa_i("earth-oceania"), 
      color = "blue"
    )
  })
  
  output$christianity_percentage_twitter <- renderValueBox({
    valueBox(
      value = paste0(round(count_religion$value/total_tweet$value * 100, 2), "%"), 
      subtitle = "Christian-related Tweet Proportion in 2022",
      icon = fa_i("twitter"), color="aqua"
    )
  })
}
