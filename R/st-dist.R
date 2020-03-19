#' Get bounding box dimensions
#'
#' @inheritParams bbox_lims
#' @name bbox_dist
#' @export 
st_xdist <- function (x) UseMethod("st_xdist")
#' @name bbox_dist
#' @export 
st_ydist <- function (x) UseMethod("st_ydist")
#' @name bbox_dist
#' @export 
st_xdist.sf <- function (x) {
  xlim <- st_xlim(x)
  xlim[2] - xlim[1]
}
#' @name bbox_dist
#' @export 
st_xdist.sfc <- st_xdist.sf
#' @name bbox_dist
#' @export 
st_xdist.bbox <- function (x) {
  x[2] - x[1]
}
#' @name bbox_dist
#' @export 
st_ydist.sf <- function (x) {
  ylim <- st_ylim(x)
  ylim[2] - ylim[1]
}
#' @name bbox_dist
#' @export 
st_ydist.sfc <- st_ydist.sf
#' @name bbox_dist
#' @export 
st_ydist.bbox <- function (x) {
  x[2] - x[1]
}
