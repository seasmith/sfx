#' Get one-set of the bounding box
#'
#' Return either the x-axis limits
#' or y-axis limits.
#'
#' @param x (bbox/sfc/sf) Either a bounding box or a geometry.
#'
#' @examples
#' library(sf)
#' data(states_map)
#'
#' x <- st_xlim(states_map)
#' x
#'
#' # The crs is preserved
#' st_crs(x)
#' @name bbox_lims
#' @export
st_xlim <- function (x) UseMethod("st_xlim")
#' @name bbox_lims
#' @export
st_xlim.sf   <- function (x) {
    box <- sf::st_bbox(x)
    box_attrs <- attributes(box)
    box <- box[c(1, 3)]
    box <- structure(box,
                    class = "xlim",
                    names = c("xmin", "xmax"),
                    crs = box_attrs$crs)
    box
    }
#' @name bbox_lims
#' @export
st_xlim.sfc  <- st_xlim.sf
#' @name bbox_lims
#' @export
st_xlim.bbox <- function (x) {
    box_attrs <- attributes(x)
    xlim <- x[c(1, 3)]
    xlim <- structure(xlim,
                      class = "xlim",
                      names = c("xmin", "xmax"),
                      crs = box_attrs$crs)
    xlim
    }
#' @name bbox_lims
#' @export
st_ylim <- function (x) UseMethod("st_ylim")
#' @name bbox_lims
#' @export
st_ylim.sf   <- function (x) {
    box <- sf::st_bbox(x)
    box_attrs <- attributes(box)
    box <- box[c(2, 4)]
    box <- structure(box,
                    class = "ylim",
                    names = c("ymin", "ymax"),
                    crs = box_attrs$crs)
    box
    }
#' @name bbox_lims
#' @export
st_ylim.sfc  <- st_ylim.sf
#' @name bbox_lims
#' @export
st_ylim.bbox <- function (x) {
    box_attrs <- attributes(x)
    ylim <- x[c(2, 4)]
    ylim <- structure(ylim,
                      class = "ylim",
                      names = c("ymin", "ymax"),
                      crs = box_attrs$crs)
    ylim
    }

# Print xlim class object
print.xlim <- function (x) {
    px <- structure(x, crs = NULL, class = NULL)
    print(px)
    invisible(x)
}

# Print ylim class object
print.ylim <- print.xlim

# Fetch crs of xlim object
st_crs.xlim <- function (x) {
    if (is.null(attr(x, "crs")))
        sf::NA_crs_
    else attr(x, "crs")
    }

# Fetch crs of ylim object
st_crs.ylim <- st_crs.xlim