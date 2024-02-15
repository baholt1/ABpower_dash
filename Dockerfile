FROM rocker/shiny

# Set the working directory for the app
WORKDIR /home/shiny-app

# Install from GitHub repository
RUN git clone -b Brooklyn https://github.com/cbeebe27/ABpower_dash.git /home/shiny-app/ABpower_dash
RUN Rscript /home/shiny-app/ABpower_dash/requirements.R

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/ABpower_dash/', host = '0.0.0.0', port = 3838)"]