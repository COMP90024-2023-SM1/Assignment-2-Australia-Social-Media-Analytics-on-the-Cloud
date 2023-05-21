# UI
# You can run the application by clicking 'Run App' above.
# But PLEASE follow the instructions given in README.md
# And install all the required packages via "Package Install Commands.Rmd"

# Importing libraries
library(shiny)
library(shinythemes)
library(fontawesome)
library(shinyWidgets)
library(shinydashboard)
library(igraph)
library(highcharter)
library(dashboardthemes)
source('helper.R')


menuItemReligion <- function() {
  menuItem("Religion",
           tabName = "religion",
           icon = fa_i("church"))}

tabItemReligion <- function() {
  tabItem("religion",
          fluidPage(
            
            titlePanel(strong("Scenario 1 - Religion ")),
            h5("This scenario aims to study the relationship between christianity proportion and percentage of tweets/toots associated with christianity across various locations in Australia, using supplementary SUDO data to asisst in analysis. "),
            hr(),
            fluidRow(
              column(4, valueBoxOutput("christianity_percentage_2016", width = 14)),
              column(4, valueBoxOutput("christianity_percentage_twitter", width = 14)),
              column(4, valueBoxOutput("christianity_percentage_mastodon", width = 14))
            ),
            hr(),
            highchartOutput("christianity", height = 486),
            hr(),
            highchartOutput("christrianity_date_range", height = 250),

            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
