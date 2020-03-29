
#' Compute 2D density
#'
#' Choose from methods \code{"kde2d"} and \code{"bkde2D"},
#' and various return geometries
#'
#' @param x (sf/sfc) Spatial data
#' @param return_geometry (character) What gets returned?
#' @param method (character) How should density be computed?
#' @param bw (numeric) Binwidth
#' @param n (numeric) Grid size
#' @param bins (numeric) Number of contour bins
#' @param range.x (numeric-list) See \code{KernSmooth::bkde2D}
#' @param truncate (logical) See \code{KernSmooth::bkde2D}
#'
#' @name st_density
#' @export
st_density <- function (x, return_geometry = "point", method = "kde2d",
                        bw = NULL, n = 200, bins = NULL, range.x = NULL,
                        truncate = TRUE) {
  UseMethod("st_density")
}

#' @name st_density
#' @export
st_density.sfc <- function (x, return_geometry = "point", method = "kde2d",
                            bw = NULL, n = NULL, bins = NULL, range.x = NULL,
                            truncate = TRUE) {

  data_coords <- sf::st_coordinates(x)

  if (is.null(n)) {
    n <- switch(method,
                kde2d = 200,
                bkde2D = c(51, 51))
  }

  # Compute density by method and return geometry
  dens <- switch(method,
                 kde2d = sf_compute_kde2d(data_coords, return_geometry, bw),

                 bkde2D = sf_compute_bkde2D(data_coords, return_geometry,
                                            bw, n, range.x, truncate))

  switch(return_geometry,

          point  = {
            x$density  <- dens$density
            x$ndensity <- dens$ndensity
          },

          raster = {})

  x

}

#' @name st_density
#' @export
st_density.sf <- st_density.sfc
