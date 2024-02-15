FROM --platform=linux/amd64 rocker/shiny-verse:latest
RUN apt-get update && apt-get install -y git

RUN apt-get update && apt-get install -y \
    libssl-dev \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libfontconfig1-dev
    
RUN R -e "install.packages(c('tidyquant', 'magrittr', 'plotly', 'shiny', 'maps', 'sf', 'rvest', 'leaflet', 'ggplot2'), dependencies = TRUE, repos = 'https://packagemanager.rstudio.com/cran/latest')"

RUN echo "library(magrittr)" >> /usr/local/lib/R/site-library/00-first-packages.R

# Create and set the working directory
WORKDIR /srv/shiny-server

# Install from GitHub repository
RUN git clone https://github.com/cbeebe27/ABpower_dash.git /srv/shiny-server/ABpower_dash

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/ABpower_dash/', host = '0.0.0.0', port = 3838)"]