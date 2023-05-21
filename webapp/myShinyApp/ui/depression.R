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


menuItemDepression <- function() {
  menuItem("Depression",
           tabName = "depression",
           icon = fa_i("heart-crack"))}

tabItemDepression <- function() {
  tabItem("depression",
          fluidPage(
            titlePanel(strong("Scenario 2 - Depression")),
            h5("This scenario aims to provide an in-depth analysis of depression-related tweets/toots across various locations in Australia. 
               We are then able to visualise insights into differences and similarities in the conversation surrounding mental health on 
               Twitter VS. Mastodon."),
            hr(),
            fluidRow(
              column(3, valueBoxOutput("depression_percentage_twitter", width = 14)),
              column(3, valueBoxOutput("depression_total_twitter", width = 14)),
              column(3, valueBoxOutput("depression_percentage_mastodon", width = 14)),
              column(3, valueBoxOutput("depression_total_mastodon", width = 14))
            ),
            hr(),
            highchartOutput("depression_weekday_hour", height = 390),
            hr(),
            highchartOutput("depression_weekday_hour_m", height = 390),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
