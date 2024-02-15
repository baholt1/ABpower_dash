pack <- c("tidyverse", "plotly", "shiny", "maps", "sf", "rvest", "leaflet")

new.pack <- pack[!(pack %in% installed.packages()[, "Packages"])]

if (length(new.pack)) {
  install.packages(new.pack, dependencies = T)
}