rm_na <- function (x) c(stats::na.omit(x))
st_list_polygon <- function (x) lapply(x, function (l) sf::st_polygon(list(l)))

sf_grid_to_polygon <- function (x, coords = NULL, crs = NULL) {

  if (is.null(coords)) coords <- 1:2
  if (is.null(crs)) crs <- sf::st_crs(NA)

  x_coords <- x[, coords[1]]
  y_coords <- x[, coords[2]]
  nr <- nrow(x)
  ux <- unique(sort(x_coords))
  uy <- unique(sort(y_coords))
  dx <- diff(ux)
  dy <- diff(uy)

  # Extend to same length as grid
  dx <- c(dx, dx[length(dx)])
  dy <- c(dy, dy[length(dy)])
  lx <- length(dx)
  ly <- length(dy)

  # Create vectors the same length as rows
  vdx <- rep(dx, nr / lx)
  vdy <- rep(dy, each = nr / ly)

  mx <- mapply(function (sx, sy, hx, hy) {
                 x <- sx + c(-hx, hx, hx, -hx, -hx)
                 y <- sy + c(hy, hy, -hy, -hy, hy)
                 matrix(c(x, y), ncol = 2)
               },
               sx = x_coords, sy = y_coords, hx = vdx / 2, hy = vdy / 2,
               SIMPLIFY = FALSE)

  mx <- sf::st_sfc(st_list_polygon(mx), crs = crs)
  x <- sf::st_sf(geometry = mx)

  # RETURN
  x
}

names_exist <- function (x, n) match(n, colnames(x), nomatch = 0L) > 0L

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

as_matrix <- function (...) {
  as.matrix(data.frame(...))
}

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

compute_limits <- function (data,
                            x_expansion,
                            y_expansion,
                            bw,
                            method = "kde2d") {
  switch(method,

         kde2d = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"], na.rm = TRUE)
           } else {
             x_expansion <- rep(x_expansion, length.out = 2)
             x_expansion <- c(1 - x_expansion[1], 1 + x_expansion[2])
             rng_x <- range(data[, "X"], na.rm = TRUE)
             rng_x <- rng_x * (x_expansion)
           }

           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"], na.rm = TRUE)
           } else {
             y_expansion <- rep(y_expansion, length.out = 2)
             y_expansion <- c(1 - y_expansion[1], 1 + y_expansion[2])
             rng_y <- range(data[, "Y"], na.rm = TRUE)
             rng_y <- rng_y * (y_expansion)
           }
          return(c(rng_x, rng_y))
         },

         bkde2D = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"])
             rng_x[1] <- rng_x[1] - 1.75 * bw[1]
             rng_x[2] <- rng_x[2] + 1.75 * bw[1]
           }

           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"])
             rng_y[1] <- rng_y[1] - 1.75 * bw[2]
             rng_y[2] <- rng_y[2] + 1.75 * bw[2]
           }
           return(list(rng_x, rng_y))
         })
}

sf_compute_bkde2D <- function (data, return_geometry = "point",
                               bw = NULL, grid_size = c(51, 51),
                               x_expansion = NULL,
                               y_expansion = NULL,
                               truncate = TRUE) {

  check_for_coords(data)
  bw <- check_for_bw(bw, data, m = "bkde2D")
  grid_size <- rep(grid_size, length.out = 2)
  lims <- compute_limits(data, x_expansion, y_expansion)

  dens <- KernSmooth::bkde2D(as_matrix(x = data[, "X"], y = data[, "Y"]),
                             bw, grid_size, lims, truncate)

  names(dens) <- c("x", "y", "z")
  df <- reshape_density(data, dens, return_geometry)
  df
}

sf_compute_kde2d <- function (data, return_geometry = "point",
                              bw = NULL, n = 200, bins = NULL,
                              x_expansion = NULL,
                              y_expansion = NULL) {

  check_for_coords(data)
  lims <- compute_limits(data, x_expansion, y_expansion)
  bw <- check_for_bw(bw, data, m = "kde2d")
  dens <- MASS::kde2d(data[, "X"], data[, "Y"], h = bw, n = n, lims = lims)
  df <- reshape_density(data, dens, return_geometry)
  df
}
