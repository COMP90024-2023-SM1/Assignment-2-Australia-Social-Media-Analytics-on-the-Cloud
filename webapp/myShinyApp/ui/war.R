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
            h5("In February 2022, Russia recognized the DPR and LPR as independent states and subsequently invaded Ukraine, 
            facing international condemnation and increased sanctions. Russia's attempt to capture Kyiv failed, with Ukraine 
            reclaiming territories by August. Despite international rejection, Russia declared annexation of four Ukrainian regions. 
            It then conducted unsuccessful operations in the Donbas, preparing for an expected Ukrainian counteroffensive. 
            The war has led to a severe refugee crisis and numerous fatalities."),
            hr(),
            # Use fluid row layout to put two plots side by side
            fluidRow(
              column(3, valueBoxOutput("war_percentage_twitter", width = 14)),
              column(3, valueBoxOutput("war_total_twitter", width = 14)),
              column(3, valueBoxOutput("war_percentage_mastodon", width = 14)),
              column(3, valueBoxOutput("war_total_mastodon", width = 14))
            ),
            hr(),
            fluidRow(
              highchartOutput("war_trend_tweet")
            ),
            hr(),
            fluidRow(
              column(6, highchartOutput("twitter_war_lang")),
              column(6, highchartOutput("mastodon_war_lang"))
            ),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
          )
  )
}
