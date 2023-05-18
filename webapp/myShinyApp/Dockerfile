FROM rocker/shiny:latest

# Copy the Shiny app files to the container
COPY . /srv/shiny-server/

# Set the working directory
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libglpk40

# Install Shiny and other required packages
RUN R -e "install.packages(c('shiny', 'httr', 'stringr', 'shinythemes', 'fontawesome', 'shinydashboard', 'igraph', 'highcharter', 'dplyr', 'tidyr', 'dashboardthemes','shinyWidgets','rgdal','tm'))"
# Copy the app files to the image
COPY ./server.R /app/server.R
COPY ./ui.R /app/ui.R
COPY ./helper.R /app/helper.R

# Set the working directory
WORKDIR /

# Expose the Shiny app port
EXPOSE 3838

# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('/app/', host='0.0.0.0', port=3838)"]