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
            hr(),
            
            # Use fluid row layout to put two plots side by side
            fluidRow(
              column(6, highchartOutput("shooter_age")),
              column(6, highchartOutput("weapon_source"))
            ),
            hr(),
            h4("As the plot above on the left depicted, over 55% of shooters with known 
                 age are between the age of 15 and 19, followed by those aged between 10 to 
                 14 with almost 20%, while the plot on the right shows that for those aged 
                 between 10 and 19, over 70% of their known weapon source were from relatives. 
                 Thus, adult should pay more attention and reduce minor's access to firearms.
                 On the other hand, the plot below shows that over 55% of shooting incidents 
                 were targeted, however, indiscriminate firing leads to the highest number of 
                 casualties, which is even higher than the rest combined.",
               style = "color: #808080;font-size:15px;"),
            hr(),
            fluidRow(
              column(12, highchartOutput("shooter_intention"))
            ),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
