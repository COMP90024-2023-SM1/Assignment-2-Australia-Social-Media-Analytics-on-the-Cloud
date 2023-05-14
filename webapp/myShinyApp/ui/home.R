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


menuItemHome <- function() {menuItem("Home",
             tabName = "home",
             selected = T,
             icon = fa_i('fas fa-house'))}

tabItemHome <- function(){
  tabItem("home",
          fluidPage(
            # Title for home tab
            titlePanel(strong("Australia Social Media Analytics on the Cloud")),
            hr(),
            h5(strong("General Statistics"),
               style = "font-size:16px;"),
            
            # Value box
            fluidRow(
              column(3, valueBoxOutput("total_tweet", width = 14)),
              column(3, valueBoxOutput("total_mastodon", width = 14)),
              column(3, valueBoxOutput("kill_1", width = 14)),
              column(3, valueBoxOutput("injury_1", width = 14))
            )
          ),
          hr(),
          tags$style(type = "text/css", ".shiny-output-error { visibility: hidden; }",
                     ".shiny-output-error:before { visibility: hidden; }"),
          fluidRow(
            column(12,
                   highchartOutput("aus_map", height = 505),
                   absolutePanel(
                     dateRangeInput("dateRange",
                                    tags$p(fa("filter", fill = "forestgreen"),
                                           "Select date range:"),
                                    start = "2022-02-10",
                                    end = "2022-08-10",
                                    min = "2022-02-10",
                                    max = "2022-08-10"),
                     pickerInput("map_state",
                                 tags$p(fa("filter", fill = "forestgreen"),
                                        "State filter for visualisation"),
                                 ruralcity_choiceVec, selected = ruralcity_choiceVec,
                                 multiple = TRUE, options = list(`actions-box` = TRUE)),
                     style = "position: absolute; top: 60px; right: 10px; padding: 10px; border-radius: 5px;"
                   )
            )
          ),
          hr(),
          fluidRow(
            column(6, highchartOutput("tweet_timeline")),
            column(6, highchartOutput("home_wordcloud"))
          ),
          hr(),
          h5('Charts and map are created using ', 
             a("Highcharter", 
               href="https://jkunst.com/highcharter/"), 
             '(a R wrapper for Highcharts)')
  )
}
