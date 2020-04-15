# Reshape density to grid (expand_density()) or point (interpolate_density())
# @param raw (tibble) Original data (used to create density)
# @param grid (tibble) Computed density; must contain x, y, and z
reshape_density <- function (raw, grid, return_geometry) {
  switch(return_geometry,
         point = {
           df <- interpolate_density(raw, grid$x, grid$y, grid$z)
         },

         grid    = ,
         raster  = ,
         polygon = ,
         contour = ,
         isoband = {
           df <- expand_density(grid$x, grid$y, grid$z)
         })
  df$ndensity <- df$density / max(df$density, na.rm = TRUE)
  df
}

expand_density <- function (x, y, z) {
  df <- expand.grid(x = x, y = y)
  df$z <- as.vector(z)
  names(df) <- c("x", "y", "density")
  df
}

interpolate_density <- function (raw, x, y, z) {
    ix <- findInterval(raw[, "X"], x)
    iy <- findInterval(raw[, "Y"], y)
    ii <- cbind(ix, iy)

    df <- data.frame(x = raw[, "X"],
                     y = raw[, "Y"],
                     density = z[ii])

    names(df) <- c("x", "y", "density")
    df

}
