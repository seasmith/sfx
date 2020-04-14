library(tidyverse)
library(sf)
library(nngeo)
library(isoband)
data(towns)

devtools::load_all()


tcoords <- st_coordinates(towns)
tgrid <- sf_compute_kde2d(tcoords, "grid")


st_list_polygon <- function (x) lapply(x, function (l) st_polygon(list(l)))
# Get unique x/y and x/y-intervals
ux <- unique(sort(tgrid$x))
uy <- unique(sort(tgrid$y,  decreasing = TRUE))
dx <- diff(ux)
dy <- diff(uy)

# Extend to same length as grid
dx <- c(dx, dx[length(dx)])
dy <- c(dy, dy[length(dy)])

# Create vectors the same length as rows
vdx <- rep(dx, nrow(tgrid) / length(dx))
vdy <- rep(dy, each = nrow(tgrid) / length(dy))

mx <- mapply(function (sgx, sgy, shx, shy) {
           x <- sgx + c(-shx, shx, shx, -shx, -shx)
           y <- sgy + c(shy, shy, -shy, -shy, shy)
           matrix(c(x, y), ncol = 2)
         },
         sgx = tgrid$x, sgy = tgrid$y, shx = vdx / 2, shy = vdy / 2,
         SIMPLIFY = FALSE)

px <- st_sf(st_sfc(st_list_polygon(mx)))
px %>% slice(1:400) %>% ggplot() + geom_sf(color = NA, fill =  "red")
plot(px)


xiso <- st_density(towns, "isoband")

xiso %>% 
filter(level < 21) %>%
  ggplot() +
  geom_sf(aes(fill = level), color = NA) +
  geom_sf(data = towns, color = "red") +
  scale_fill_viridis_c()


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

