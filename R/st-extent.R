#' Return the bounding box as 'sf' or 'sfc'
#'
#' @param x (sf/sfc) Spatial data
#' @param type (character) Return type; either \code{"sf"}
#'  (Default) or \code{"sfc"}
#'
#' @name st_extent
#' @export
st_extent <- function (x, type = "sf") {

    x <- sf::st_bbox(x)
    x <- switch(type,

      sf = {
          x %>%
            sf::st_as_sfc() %>%
            sf::st_as_sf()
      },

      sfc = {
          x %>%
            sf::st_as_sfc()
      })

    # RETURN
    x
}