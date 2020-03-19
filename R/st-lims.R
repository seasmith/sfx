#' Get one-set of the bounding box
#'
#' @param x (bbox/sfc/sf) Either a bounding box or a geometry.
#' @name bbox_lims
#' @export
st_xlim <- function (x) UseMethod("st_xlim")
#' @name bbox_lims
#' @export
st_xlim.sf   <- function (x) sf::st_bbox(x)[c(1, 3)]
#' @name bbox_lims
#' @export
st_xlim.sfc  <- st_xlim.sf
#' @name bbox_lims
#' @export
st_xlim.bbox <- function (x) x[c(1, 3)]
#' @name bbox_lims
#' @export
st_ylim <- function (x) UseMethod("st_ylim")
#' @name bbox_lims
#' @export
st_ylim.sf   <- function (x) sf::st_bbox(x)[c(2, 4)]
#' @name bbox_lims
#' @export
st_ylim.sfc  <- st_ylim.sf
#' @name bbox_lims
#' @export
st_ylim.bbox <- function (x) x[c(2, 4)]
