FROM rocker/shiny:latest

# Copy the Shiny app files to the container
COPY . /srv/shiny-server/

# Set the working directory
WORKDIR /app

# install packages
RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libglpk40 


# Install Shiny and other required packages
RUN R -e "install.packages(c('shiny', 'httr', 'stringr', 'shinythemes', 'fontawesome', 'shinydashboard', 'igraph', 'highcharter', 'dplyr', 'tidyr', 'dashboardthemes','shinyWidgets','tm'))"

# Copy the app files to the image
COPY ./server.R ./ui.R ./helper.R ./
COPY ./SUDO_data/ ./SUDO_data/
COPY ./ui/ ./ui/
COPY ./server/ ./server/

# Expose the Shiny app port
EXPOSE 3838


# Run the Shiny app
CMD ["R", "-e", "shiny::runApp('.', host='0.0.0.0', port=3838)"]