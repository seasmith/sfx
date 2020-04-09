# Isoband to raster: https://gist.github.com/mdsumner/a06faedbdf30b6d5c1820487f81a6959

#' Compute 2D density
#'
#' Choose from methods \code{"kde2d"} and \code{"bkde2D"},
#' and various return geometries
#'
#' @param x (sf/sfc) [missing] Spatial data
#' @param return_geometry [\code{"point}"] (character) What gets returned?
#' @param method (character) [\code{"kde2d}"] How should density be computed?
#' @param bw (numeric) [\code{NULL}] Binwidth
#' @param n (numeric) [\code{NULL}] Grid size
#' @param bins (numeric) [\code{NULL}] Number of contour bins
#' @param truncate (logical) [\code{TRUE}] See \code{KernSmooth::bkde2D}
#' @param x_expansion,y_expansion (numeric) [\code{NULL}] Expansion multiple
#'  applied to x-/y-range and used in \code{lims} and \code{range.x}
#'  arguments for methods \code{"kde2d"} and \code{"bkde2D"}, respectively.
#'
#' @name st_density
#' @export
st_density <- function (x,
                        return_geometry = "point",
                        method = "kde2d",
                        bw = NULL,
                        n = 200,
                        bins = NULL,
                        truncate = TRUE,
                        x_expansion = NULL,
                        y_expansion = NULL,
                        levels_low = NULL,
                        levels_high = NULL) {
  UseMethod("st_density")
}

#' @name st_density
#' @export
st_density.sfc <- function (x,
                            return_geometry = "point",
                            method = "kde2d",
                            bw = NULL,
                            n = NULL,
                            bins = NULL,
                            truncate = TRUE,
                            x_expansion = NULL,
                            y_expansion = NULL,
                            levels_low = NULL,
                            levels_high = NULL) {

  data_coords <- sf::st_coordinates(x)

  if (is.null(n)) {
    n <- switch(method,
                kde2d = 200,
                bkde2D = c(51, 51))
  }

  # Compute density by method and return geometry
  dens <- switch(method,
                 kde2d = sf_compute_kde2d(data_coords, return_geometry, bw,
                                          x_expansion, y_expansion),

                 bkde2D = sf_compute_bkde2D(data_coords, return_geometry,
                                            bw, n, x_expansion, y_expansion,
                                            truncate))

  switch(return_geometry,

          point  = {
            x$density  <- dens$density
            x$ndensity <- dens$ndensity
          },

          raster = {},

          isoband = {
            if (is.null(levels_high) | is.null(levels_low)) {
              levels_low <- .05 * (0:20)
              levels_high <- .05 * (1:21)
            }
            iso_matrix <- tapply(dens$ndensity, dens[, c("y", "x")], identity)
            iso_band <- isoband::isobands(unique(dens$x),
                                          unique(dens$y),
                                          iso_matrix,
                                          levels_low = levels_low,
                                          levels_high = levels_high)
            iso_band <- isoband::iso_to_sfg(iso_band)
            x <- st_sf(level = seq_len(length(iso_band)),
                       crs = sf::st_crs(x),
                       geometry = sf::st_sfc(iso_band))
          })

  x

}

#' @name st_density
#' @export
st_density.sf <- st_density.sfc
