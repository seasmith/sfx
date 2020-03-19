library(sf)
library(dplyr)
library(ggplot2)

source("data-raw/ngp-data.R")
source("data-raw/states-map.R")

usethis::use_data(ngp,
                  states_map
                  , internal = FALSE, overwrite = TRUE)