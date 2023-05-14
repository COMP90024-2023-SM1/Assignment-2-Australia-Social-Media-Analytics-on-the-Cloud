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
            h5("This scenario aims to study the religion across various areas and different demographic categories, using supplementary SUDO data to explore the situation of its development and distribution. "),
            hr(),
            # Define highcharter output
            # highchartOutput("year_casualty", height = 485),
            highchartOutput("education_religion", height = 485),
            hr(),
            h4("School shooting have been happening every year since the 1999 Columbine massacre. 
                 And the number of casualties has top the chart in 2018 with a horrifying record of 
                 95 casualties. The number of incidents and casualties has significantly reduced in 
                 2020, which might be primarily due to school closures during the pandemic. However,
                 the number of incidents skyrocketed in 2021, with a chart-topping 42 shooting 
                 incidents happening last year.",
               style = "color: #808080;font-size:15px;"),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
