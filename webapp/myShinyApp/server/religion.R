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
  output$education_religion <- renderHighchart({
    # education_data <- education_sudo
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = "Religion People Number and Year 12 or Above by Area") %>%
      hc_xAxis(categories = sudo_data$key) %>%
      hc_yAxis(title = list(text = "Year 12 or Above")) %>%
      hc_add_series(name = "Year 12 or Above", data = sudo_data$year_12_or_above) %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000)))
    
  })
  
  output$christianity <- renderHighchart({
    highchart() %>%
      hc_chart(type = "column") %>%
      hc_title(text = "Christianity Percentage Comparison") %>%
      hc_xAxis(categories = sudo_data$key) %>%
      hc_yAxis(title = list(text = "Religion Percentage")) %>%
      hc_add_series(name = "Religion Percentage", data = sudo_data$christianity_percentage, color="#DF5665") %>%
      hc_plotOptions(series = list(borderRadius = 4, animation = list(duration = 3000)))
  })
  
  output$christianity_percentage_2016 <- renderValueBox({
    valueBox(
    value = mean(sudo_data$christianity_percentage), subtitle = "Christianity Percentage in 2016",
    icon = fa_i("mastodon"), color = "blue"
    )
  })
  
}