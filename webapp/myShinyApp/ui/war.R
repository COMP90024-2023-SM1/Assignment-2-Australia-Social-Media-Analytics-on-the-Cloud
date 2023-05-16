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


menuItemWar <- function() {
  menuItem("War",
           tabName = "war",
           icon = fa_i("jet-fighter"))}

tabItemWar <- function() {
  tabItem("war",
          fluidPage(
            titlePanel(strong("Russo-Ukrainian War")),
            hr(),
            fluidRow(
              highchartOutput("war_trend_tweet")
            ),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
