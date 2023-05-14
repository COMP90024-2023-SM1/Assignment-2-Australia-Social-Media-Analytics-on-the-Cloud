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
              column(5, highchartOutput("public_private")),
              column(7, highchartOutput("school_type"))
            ),
            hr(),
            h4("As the pie chart on the left depicted, near 94% of the shooting incidents
                 were occurred in public school. However, we do need to consider the difference
                 that there are more public school than private school. Whilst the bar chart on
                 the right shows that over 60% of the incidents were happened in high school,
                 followed by elementary school with 14.5%. Nevertheless, local government and 
                 school should take more effective actions to reduce the risk of school shootings.", 
               style = "color: #808080;font-size:15px;"),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
