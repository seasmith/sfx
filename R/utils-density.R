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

  names(dens) <- c("x", "y", "z")
  df <- reshape_density(data, dens, return_geometry)
  df
}

sf_compute_kde2d <- function (data, return_geometry = "point",
                              bw = NULL, n = 200, bins = NULL) {

  check_for_coords(data)
  bw <- check_for_bw(bw, data, m = "kde2d")
  dens <- MASS::kde2d(data[, "X"], data[, "Y"], h = bw, n = n)
  df <- reshape_density(data, dens, return_geometry)
  df
}
