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
            titlePanel(strong("Depression Scenario")),
            h5("This scenario aims to study the depression across various areas and different demographic categories"),
            hr(),
            highchartOutput("depression_weekday_hour", height = 450),
            hr(),
            # Use fluid row layout to put two plots side by side
            fluidRow(
              column(6, valueBoxOutput("depression_percentage_twitter", width = 7)),
              column(6, valueBoxOutput("depression_total_twitter", width = 7))
              #column(6, valueBoxOutput("depression_total_mastodon", width = 7)),
              #column(6, valueBoxOutput("depression_total_mastodon", width = 7))
            ),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
