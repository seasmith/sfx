check_for_coords <- function (x) {
  if (!all(names_exist(x, c("X", "Y"))))
    stop("[compute]: Data must be coordinate matrix", call. = FALSE)
}

check_for_bw <- function (x, d, m) {
  if (is.null(x)) {
    x <- estimate_bw(d, method = m)
    message("No bandwidth provided, using estimate: " %P% x)
  }

  x
}

expand_density <- function (x) {
  dx <- expand.grid(x = x$x, y = x$y)
  dx$z <- as.vector(x$z)
  names(df) <- c("x", "y", "density")
  df
}

interpolate_point <- function (raw, x, y, z) {
    ix <- findInterval(raw[, "X"], x)
    iy <- findInterval(raw[, "Y"], y)
    ii <- cbind(ix, iy)

    df <- data.frame(x = raw[, "X"],
                     y = raw[, "Y"],
                     density = z[ii])

    names(df) <- c("x", "y", "density")
    df

}

as_matrix <- function (...) {
  as.matrix(data.frame(...))
}

names_exist <- function (x, n) match(n, colnames(x), nomatch = 0L) > 0L


estimate_bw <- function (data, method = "kde2d") UseMethod("estimate_bw")

estimate_bw.sf <- function (data, method = "kde2d") {

  data <- sf::st_coordinates(data)
  NextMethod()
}

estimate_bw.sfc <- estimate_bw.sf

estimate_bw.default <- function (data, method = "kde2d") {

  set.seed(1814)

  bw <- switch(method,

         # Preserve in case I want to use stats::bw.SJ
         # kde2d = {
         #   mean(c(stats::bw.SJ(data[, "X"]), stats::bw.SJ(data[, "Y"])))
         # },

         bkde2D = {
           c(KernSmooth::dpik(data[, "X"]), KernSmooth::dpik(data[, "Y"]))
         },

         kde2d = {
           c(MASS::bandwidth.nrd(data[, "X"]),
             MASS::bandwidth.nrd(data[, "Y"]))
         })

  bw
}

sf_compute_bkde2D <- function (data, return_geometry = "point",
                               bw = NULL, grid_size = c(51, 51),
                               range.x = NULL, truncate = TRUE) {

  check_for_coords(data)
  bw <- check_for_bw(bw, data, m = "bkde2D")

  if (length(grid_size) == 1) grid_size <- rep(grid_size, 2)

  if (is.null(range.x)) {
        x_range <- range(data[, "X"])
        y_range <- range(data[, "Y"])
        x_range[1] <- x_range[1] - 1.75 * bw[1]
        x_range[2] <- x_range[2] + 1.75 * bw[1]
        y_range[1] <- y_range[1] - 1.75 * bw[2]
        y_range[2] <- y_range[2] + 1.75 * bw[2]
        range.x <- list(x_range, y_range)
    }

  dens <- KernSmooth::bkde2D(as_matrix(x = data[, "X"], y = data[, "Y"]),
                             bw, grid_size, range.x, truncate)

  switch(return_geometry,

         point = {
           df <- interpolate_point(data, dens$x1, dens$x2, dens$fhat)
           df$ndensity <- df$density / max(df$density, na.rm = TRUE)
         },

         grid = {},

         raster = {},

         polygon = {},

         contour = {},

         isoband = {})

  df
}

sf_compute_kde2d <- function (data, return_geometry = "point",
                              bw = NULL, n = 200, bins = NULL) {

  check_for_coords(data)
  bw <- check_for_bw(bw, data, m = "kde2d")
  dens <- MASS::kde2d(data[, "X"], data[, "Y"], h = bw, n = n)

  switch(return_geometry,

           point = {
            df <- interpolate_point(data, dens$x, dens$y, dens$z)
            df$ndensity <- df$density / max(df$density, na.rm = TRUE)
           },

           grid = ,

           raster = {
             df <- expand_density(dens)
             df$ndensity <- df$density/max(df$density, na.rm = TRUE)
           },

           polygon = {},
           contour = {},
           isoband = {})

    df
}
