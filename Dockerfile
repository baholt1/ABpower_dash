FROM rocker/shiny-verse:latest
RUN apt-get update && apt-get install -y git

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libfontconfig1-dev

RUN R -e "install.packages(c('tidyverse', 'plotly', 'maps', 'sf', 'rvest', 'leaflet'), dependencies = TRUE, repos = 'https://packagemanager.rstudio.com/cran/latest')"
# Create and set the working directory
WORKDIR /srv/shiny-server

# Install from GitHub repository
RUN git clone https://github.com/cbeebe27/ABpower_dash.git /srv/shiny-server/ABpower_dash

# Make the Shiny app available at port 3838
EXPOSE 3838