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
      hc_title(text = "Year 12 or Above by GCCSA") %>%
      hc_xAxis(categories = sudo_data$key) %>%
      hc_yAxis(title = list(text = "Year 12 or Above")) %>%
      hc_add_series(name = "Year 12 or Above", data = sudo_data$year_12_or_above)
    
  })
  
  output$christianity <- renderHighchart({
    highchart() %>%
      hc_chart(type = '')
  })
}