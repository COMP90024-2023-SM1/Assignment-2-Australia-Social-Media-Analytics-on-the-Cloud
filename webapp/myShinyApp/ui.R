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
    menuItem("Home",
             tabName = "home",
             selected = T,
             icon = fa_i('fas fa-house')),
    menuItem("Religion",
             tabName = "religion",
             icon = fa_i("church")),
    menuItem("Depression",
             tabName = "depression",
             icon = fa_i("heart-crack")),
    menuItem("War",
             tabName = "war",
             icon = fa_i("jet-fighter"))
  )
)

body <- dashboardBody(
  customTheme,
  tabItems(
    # Structure for home tab
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
              column(6, highchartOutput("unholy"))
            ),
            hr(),
            h5('Charts and map are created using ', 
               a("Highcharter", 
                 href="https://jkunst.com/highcharter/"), 
               '(a R wrapper for Highcharts)')
    ),
    
    tabItem("religion",
            fluidPage(

              titlePanel(strong("Religion Scenario ")),
              h5("This scenario aims to study the belief in Christianity across various regions and different demographic categories, using supplementary SUDO data to explore the situation of its development and distribution. "),
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
    ),
    
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
    ),
    tabItem("war",
            fluidPage(
              titlePanel(strong("War Scenario")),
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
  )
)

# Putting the UI together
ui <- dashboardPage(
  title = "CCC Dashboard",
  header, 
  sidebar, 
  body
)