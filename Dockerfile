FROM rocker/shiny-verse


# Set the working directory for the app
WORKDIR /srv/shiny-server

# Install from GitHub repository
RUN git clone -b Brooklyn https://github.com/cbeebe27/ABpower_dash.git /srv/shiny-server/ABpower_dash
RUN R -e "install.packages(c("tidyverse", "plotly", "shiny", "maps", "sf", "rvest", "leaflet"))"

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/ABpower_dash/', host = '0.0.0.0', port = 3838)"]