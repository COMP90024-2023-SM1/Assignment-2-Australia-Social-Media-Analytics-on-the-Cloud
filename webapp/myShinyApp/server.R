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
source('server/home.R')
source('server/religion.R')
source('server/depression.R')
source('server/war.R')

# Set a global theme highcharter plot
options(highcharter.theme = hc_theme_hcrt())

server <- shinyServer(function(input, output) {
  serverHome(input, output)
  serverReligion(input, output)
  serverDepression(input, output)
  serverWar(input, output)
})