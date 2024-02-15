FROM --platform=linux/amd64 rocker/shiny-verse:latest
RUN apt-get update && apt-get install -y git

# Set the working directory for the app
WORKDIR /srv/shiny-server

# Install from GitHub repository
RUN git clone https://github.com/cbeebe27/ABpower_dash.git /srv/shiny-server/ABpower_dash
RUN Rscript /srv/shiny-server/ABpower_dash/requirements.R

# Make the Shiny app available at port 3838
EXPOSE 3838

# Run the app
CMD ["R", "-e", "shiny::runApp('/srv/shiny-server/ABpower_dash/', host = '0.0.0.0', port = 3838)"]