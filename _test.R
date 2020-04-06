library(tidyverse)
library(sf)
library(nngeo)
library(isoband)
data(towns)

devtools::load_all()

xiso <- st_density(towns, "isoband")

xiso %>% 
filter(level < 21) %>%
  ggplot() +
  geom_sf(aes(fill = level), color = NA) +
  geom_sf(data = towns, color = "red") +
  scale_fill_viridis_c()

tcoords <- st_coordinates(towns)
tgrid <- sf_compute_kde2d(tcoords, "grid")


towns %>%
  st_density() %>%
  ggplot() +
  geom_sf(aes(color = density)) +
  scale_color_viridis_c()


library(sf)
library(sfx)
library(ggplot2)

olinda1 <- sf::read_sf("C:\\Users\\Luke\\R\\win-library\\3.6\\sf\\shape\\olinda1.shp")

olinda1_centroids <- olinda1  %>%
    sf::st_centroid() 
    
olinda1_centroids %>%
    st_density() %>%
    ggplot() +
    geom_sf(aes(color = density)) +
    scale_color_viridis_c()

olinda1_centroids %>%
    st_density(method = "bkde2D") %>%
    ggplot() +
    geom_sf(aes(color = density)) +
    scale_color_viridis_c()
    

olinda1_centroids %>%
    st_density("isoband") %>%
    ggplot() +
    geom_sf(aes(fill = level), alpha = 1) +
    geom_sf(data = olinda1_centroids, color = "red", size = 2) +
    scale_fill_viridis_c()

olinda1_centroids %>%
    st_density("point") %>%
    ggplot() +
    geom_sf(aes(fill = ndensity), 
            color = "black",
            pch = 21,
            size = 4) +
    scale_fill_viridis_c()

