library(httr)
library(jsonlite)
library(lubridate)
library(dplyr)
library(tidyr)
library(rgdal)

# Helper functions
total_tweet <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false")
total_tweet <- content(total_tweet, "parsed")

generalTweet_info <- GET('http://172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-gcc-date?reduce=true&group=true&update=false')
generalTweet_info <- as.data.frame(fromJSON(content(generalTweet_info, "text", encoding = "UTF-8"))$rows)
generalTweet_info$key <- sapply(generalTweet_info$key, paste, collapse = ", ")
generalTweet_info <- generalTweet_info %>%
  separate(key, c("key", "date"), sep = ", ")
generalTweet_info$date <- as.Date(generalTweet_info$date)
generalTweet_info <- generalTweet_info[generalTweet_info$key != "9OTER", ]
location_mapping <- c("1GSYD" = "Sydney", "2GMEL" = "Melbourne", "3GBRI" = "Brisbane", 
                      "4GADE" = "Adelaide", "5GPER" = "Perth", "6GHOB" = "Hobart", 
                      "7GDAR" = "Darwin", "8ACTE" = "Canberra", "9OTER" = "Other", 
                      "1RNSW" = "Rural NSW", "2RVIC" = "Rural VIC", "3RQLD" = "Rural QLD",
                      "4RSAU" = "Rural SA", "5RWAU" = "Rural WA", "6RTAS" = "Rural TAS",
                      "7RNTE" = "Rural NT")
generalTweet_info$key <- location_mapping[generalTweet_info$key]

# read SUDO data
population_sudo <- read.csv("../SUDO_data/population_religion_languages.csv", header = T)
education_sudo <- read.csv("../SUDO_data/education.csv", header=T)
income_sudo <- read.csv("../SUDO_data/investment_income.csv", header=T)
merged_data1 <- merge(population_sudo, education_sudo, by = c("gccsa_code", "gccsa_name"))
sudo_data <- merge(merged_data1, income_sudo, by = c("gccsa_code", "gccsa_name"))
sudo_data$key <-  location_mapping[sudo_data$gccsa_code]

# load spatial data
gcc_shapefile <- readOGR( 
  dsn = "../SUDO_data", 
  layer = "GCCSA_2021_AUST_GDA2020",
  verbose = FALSE
)

capital_cities <- data.frame(
  key = c("Canberra", "Sydney", "Melbourne", "Brisbane", "Perth", "Adelaide", "Darwin", "Hobart",
           "Rural VIC", "Rural SA", "Rural NSW", "Rural QLD", "Rural NT", "Rural WA", "Rural TAS"),
  lat = c(-35.2809, -33.8688, -37.8136, -27.4698, -31.9505, -34.9285, -12.4634, -42.8821, 
          -36.546835, -30.461157, -31.000383, -22.395562, -20.932729, -25.382024, -41.276145),
  lon = c(149.1300, 151.2093, 144.9631, 153.0251, 115.8605, 138.6007, 130.8456, 147.3272, 
          143.049673, 134.602050, 145.057544, 144.241518, 133.261762, 121.899317, 145.029348)
)

# Theme for dashboard
customTheme <- shinyDashboardThemeDIY(
  ### general
  appFontFamily = "Optima"
  ,appFontColor = "#2D2D2D"
  ,primaryFontColor = "#000000"
  ,infoFontColor = "#000000"
  ,successFontColor = "#0F0F0F"
  ,warningFontColor = "#D41A1A"
  ,dangerFontColor = "#D41A1A"
  ,bodyBackColor = "#FFFFFF"
  
  ### header
  ,logoBackColor = "#FFFFFF"
  
  ,headerButtonBackColor = "#FFFFFF"
  ,headerButtonIconColor = "#000000"
  ,headerButtonBackColorHover = "#CAE0E6"
  ,headerButtonIconColorHover = "#000000"
  
  ,headerBackColor = "#FFFFFF"
  ,headerBoxShadowColor = ""
  ,headerBoxShadowSize = "0px 0px 0px"
  
  ### sidebar
  ,sidebarBackColor = "#F0F0F0"
  ,sidebarPadding = "3"
  
  ,sidebarMenuBackColor = "transparent"
  ,sidebarMenuPadding = "2"
  ,sidebarMenuBorderRadius = 0
  
  ,sidebarShadowRadius = ""
  ,sidebarShadowColor = "0px 0px 0px"
  
  ,sidebarUserTextColor = "#737373"
  
  ,sidebarSearchBackColor = "#FFFFFF"
  ,sidebarSearchIconColor = "#000000"
  ,sidebarSearchBorderColor = "#DCDCDC"
  
  ,sidebarTabTextColor = "#737373"
  ,sidebarTabTextSize = "15"
  ,sidebarTabBorderStyle = "none"
  ,sidebarTabBorderColor = "none"
  ,sidebarTabBorderWidth = "0"
  
  ,sidebarTabBackColorSelected = "#D1D1D1"
  ,sidebarTabTextColorSelected = "#000000"
  ,sidebarTabRadiusSelected = "0px"
  
  ,sidebarTabBackColorHover = "#F5F5F5"
  ,sidebarTabTextColorHover = "#000000"
  ,sidebarTabBorderStyleHover = "none solid none none"
  ,sidebarTabBorderColorHover = "#C8C8C8"
  ,sidebarTabBorderWidthHover = "4"
  ,sidebarTabRadiusHover = "0px"
  
  ### boxes
  ,boxBackColor = "#FFFFFF"
  ,boxBorderRadius = "5"
  ,boxShadowSize = "none"
  ,boxShadowColor = ""
  ,boxTitleSize = "20"
  ,boxDefaultColor = "#E1E1E1"
  ,boxPrimaryColor = "#5F9BD5"
  ,boxInfoColor = "#B4B4B4"
  ,boxSuccessColor = "#70AD47"
  ,boxWarningColor = "#ED7D31"
  ,boxDangerColor = "#E84C22"
  
  ,tabBoxTabColor = "#F8F8F8"
  ,tabBoxTabTextSize = "15"
  ,tabBoxTabTextColor = "#646464"
  ,tabBoxTabTextColorSelected = "#2D2D2D"
  ,tabBoxBackColor = "#F8F8F8"
  ,tabBoxHighlightColor = "#C8C8C8"
  ,tabBoxBorderRadius = "5"
  
  ### inputs
  ,buttonBackColor = "#E2D2FA"
  ,buttonTextColor = "#2D2D2D"
  ,buttonBorderColor = "#FFFFFF"
  ,buttonBorderRadius = "9"
  
  ,buttonBackColorHover = "#BEBEBE"
  ,buttonTextColorHover = "#000000"
  ,buttonBorderColorHover = "#969696"
  
  ,textboxBackColor = "#FFFFFF"
  ,textboxBorderColor = "#6C6C6C"
  ,textboxBorderRadius = "9"
  ,textboxBackColorSelect = "#F5F5F5"
  ,textboxBorderColorSelect = "#6C6C6C"
  
  ### tables
  ,tableBackColor = "#F8F8F8"
  ,tableBorderColor = "#EEEEEE"
  ,tableBorderTopSize = "5"
  ,tableBorderRowSize = "4"
)

ruralcity_choiceVec <- c('Greater Capital City', 'Rural')
