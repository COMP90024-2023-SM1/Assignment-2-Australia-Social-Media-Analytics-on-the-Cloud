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
source('ui/home.R')
source('ui/religion.R')
source('ui/depression.R')
source('ui/war.R')

header <- dashboardHeader(
  # Define the header and insert image as title
  title = tags$a(tags$img(src='https://bit.ly/3cSvLu7',
                          height='40', width='160')),
  titleWidth = 280
)

sidebar <- dashboardSidebar(
  width = 280,
  sidebarMenu(
    # Tab for different visualisation
    menuItemHome(),
    menuItemReligion(),
    menuItemDepression(),
    menuItemWar()
  )
)

body <- dashboardBody(
  customTheme,
  tabItems(
    # Structure for home tab
    tabItemHome(),
    tabItemReligion(),
    tabItemDepression(),
    tabItemWar()
  )
)

# Putting the UI together
ui <- dashboardPage(
  title = "CCC Dashboard",
  header, 
  sidebar, 
  body
)