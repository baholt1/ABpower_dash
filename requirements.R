pack <- c("tidyverse", "plotly", "shiny", "maps", "sf", "rvest", "leaflet")

new.packages <- pack[!(pack %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  install.packages(new.packages, dependencies = TRUE)
}