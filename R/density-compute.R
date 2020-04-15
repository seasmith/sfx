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
                              bw = NULL, n = 200,
                              x_expansion = NULL,
                              y_expansion = NULL) {

  check_for_coords(data)
  lims <- compute_limits(data, x_expansion, y_expansion)
  bw <- check_for_bw(bw, data, m = "kde2d")
  dens <- MASS::kde2d(data[, "X"], data[, "Y"], h = bw, n = n, lims = lims)
  df <- reshape_density(data, dens, return_geometry)
  df
}

names_exist <- function (x, n) match(n, colnames(x), nomatch = 0L) > 0L

check_for_coords <- function (x) {
  if (!all(names_exist(x, c("X", "Y"))))
    stop("[compute]: Data must be coordinate matrix", call. = FALSE)
}

as_matrix <- function (...) {
  as.matrix(data.frame(...))
}
