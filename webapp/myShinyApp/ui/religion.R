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
            
            titlePanel(strong("Religion Scenario ")),
            h5("This scenario aims to study the christianity across various areas and different demographic categories, using supplementary SUDO data to explore the situation of its development and distribution. "),
            hr(),
            fluidRow(
              column(6, valueBoxOutput("christianity_percentage_2016", width = 14)),
              column(6, valueBoxOutput("christianity_percentage_twitter", width = 14))
            ),
            # Define highcharter output
            #highchartOutput("education_religion", height = 485),
            hr(),
            highchartOutput("christianity", height = 486),
            highchartOutput("christrianity_date_range", height = 486),

            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}