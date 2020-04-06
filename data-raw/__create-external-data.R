library(sf)
library(dplyr)
library(ggplot2)
library(sfx)
library(rmapshaper)
library(readr)

source("data-raw/ngp-data.R")
source("data-raw/wells-data.R")
source("data-raw/states-map.R")

usethis::use_data(ngp,
                  states_map,
                  wells,
                  , internal = FALSE, overwrite = TRUE)