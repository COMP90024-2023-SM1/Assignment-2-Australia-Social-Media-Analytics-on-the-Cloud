library(jsonlite)
library(lubridate)
library(tm)
library(httr)
library(dplyr)
library(tidyr)

# Helper functions
total_tweet <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-total?reduce=true&group=true&update=false")
total_tweet <- as.data.frame(fromJSON(httr::content(total_tweet, "text", encoding = "UTF-8"))$rows)

generalTweet_info <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-gcc-date?reduce=true&group=true&update=false")
generalTweet_info <- as.data.frame(fromJSON(httr::content(generalTweet_info, "text", encoding = "UTF-8"))$rows)
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

tweet_month <- GET('http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-month?reduce=true&group=true&update=false')
tweet_month <- fromJSON(httr::content(tweet_month, "text", encoding = "UTF-8"))$rows
tweet_month <- tweet_month %>%
  mutate(key = sapply(key, function(x) paste(unlist(x), collapse = ", ")))
tweet_month <- tweet_month %>%
  separate(key, into = c("year", "month"), sep = ", ") %>%
  mutate(
    date = paste(year, month, "01", sep = "-"),
    date = ymd(date),
    month_label = month(date, label = TRUE),
    YearMonth = paste(month_label, year, sep = " ")
  ) %>%
  select(-date, -month_label)

home_wordcloud <- fromJSON("./SUDO_data/count-token.json")$rows
home_wordcloud <- subset(home_wordcloud, value >= 200)
stopwords_list <- c(stopwords("english"), "about", "are", "and", "the", "can", "just", "will", "amp", "didn", 
                    "don", "also", "get", "doesn", "every", "said")
home_wordcloud <- home_wordcloud[!(tolower(home_wordcloud$key) %in% stopwords_list),]
home_wordcloud = home_wordcloud[order(home_wordcloud$value, decreasing = TRUE), ]
home_wordcloud <- home_wordcloud[1:100, ]

chris_percent_gcc <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/religion-per-gcc?reduce=true&group=true&update=false")
chris_percent_gcc <- as.data.frame(fromJSON(httr::content(chris_percent_gcc, "text", encoding = "UTF-8"))$rows)
chris_percent_gcc <- chris_percent_gcc[chris_percent_gcc$key != "9OTER", ]
chris_percent_gcc$key <- location_mapping[chris_percent_gcc$key]
colnames(chris_percent_gcc) <- c('key', 'religion_value')
gcc_total_tweet <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/count-by-gcc?reduce=true&group=true&update=false")
gcc_total_tweet <- as.data.frame(fromJSON(httr::content(gcc_total_tweet, "text", encoding = "UTF-8"))$rows)
gcc_total_tweet <- gcc_total_tweet[gcc_total_tweet$key != "9OTER", ]
gcc_total_tweet$key <- location_mapping[gcc_total_tweet$key]
chris_percent_gcc <- merge(chris_percent_gcc, gcc_total_tweet, by = 'key')
chris_percent_gcc$percent <- round((chris_percent_gcc$religion_value / chris_percent_gcc$value) * 100, 2)

depression_week_hour <- GET("http://admin:admin@172.26.128.113:5984/twitter_data/_design/customDoc/_view/depression-week-hour-aest?reduce=true&group=true&update=false")
depression_week_hour <- as.data.frame(fromJSON(httr::content(depression_week_hour, "text", encoding = "UTF-8"))$rows)
depression_week_hour <- depression_week_hour %>%
  separate(key, into = c("weekday", "hour"), sep = " ")

# read depression mastodon week hour data
depression_week_hour_m_world <- GET("http://admin:admin@172.26.128.113:5984/legacy_mastodon_world_data/_design/customDoc/_view/depression-week-hour-aest?reduce=true&group=true&update=false")
depression_week_hour_m_world <- as.data.frame(fromJSON(httr::content(depression_week_hour_m_world, "text", encoding = "UTF-8"))$rows)
depression_week_hour_m_social <- GET("http://admin:admin@172.26.128.113:5984/legacy_mastodon_social_data/_design/customDoc/_view/depression-week-hour-aest?reduce=true&group=true&update=false")
depression_week_hour_m_social <- as.data.frame(fromJSON(httr::content(depression_week_hour_m_social, "text", encoding = "UTF-8"))$rows)

depression_week_hour_s_world <- GET("http://admin:admin@172.26.128.113:5984/streaming_mastodon_world_data/_design/customDoc/_view/depression-week-hour-aest?reduce=true&group=true&update=false")
depression_week_hour_s_world <- as.data.frame(fromJSON(httr::content(depression_week_hour_s_world, "text", encoding = "UTF-8"))$rows)
depression_week_hour_s_social <- GET("http://admin:admin@172.26.128.113:5984/streaming_mastodon_social_data/_design/customDoc/_view/depression-week-hour-aest?reduce=true&group=true&update=false")
depression_week_hour_s_social <- as.data.frame(fromJSON(httr::content(depression_week_hour_s_social, "text", encoding = "UTF-8"))$rows)

combined_data <- rbind(depression_week_hour_m_world, depression_week_hour_m_social,depression_week_hour_s_social,depression_week_hour_s_world)
depression_week_hour_m_total <- aggregate(value ~ key, data = combined_data, FUN = sum)
depression_week_hour_m_total <- depression_week_hour_m_total %>%
  separate(key, into = c("weekday", "hour"), sep = " ")

# read SUDO data
population_sudo <- read.csv("./SUDO_data/population_religion_languages.csv", header = T)
education_sudo <- read.csv("./SUDO_data/education.csv", header=T)
income_sudo <- read.csv("./SUDO_data/investment_income.csv", header=T)
merged_data1 <- merge(population_sudo, education_sudo, by = c("gccsa_code", "gccsa_name"))
sudo_data <- merge(merged_data1, income_sudo, by = c("gccsa_code", "gccsa_name"))
sudo_data$key <-  location_mapping[sudo_data$gccsa_code]
sudo_data <- merge(sudo_data, chris_percent_gcc, by = 'key')

desired_order <- c("Adelaide", "Rural SA", "Brisbane", "Rural QLD", "Darwin", 
                   'Rural NT', "Melbourne", 'Rural VIC', "Perth", "Rural WA", 
                   "Sydney", "Rural NSW", "Hobart", "Rural TAS", "Canberra")

sudo_data <- sudo_data %>%
  mutate(key = factor(key, levels = desired_order)) %>%
  arrange(key)

# load spatial data
#gcc_shapefile <- readOGR( 
#  dsn = "./SUDO_data", 
#  layer = "GCCSA_2021_AUST_GDA2020",
#  verbose = FALSE
#)

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
