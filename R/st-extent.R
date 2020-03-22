#' Return the bounding box as 'sf' or 'sfc'
#'
#' @param x (sf/sfc) Spatial data
#' @param type (character) Return type; either \code{"sf"}
#'  (Default) or \code{"sfc"}
#'
#' @examples
#'
#' library(dplyr)
#' library(ggplot2)
#' data(states_map)
#'
#' tx_extent <- states_map %>%
#'   filter(region == "texas") %>%
#'   st_extent()
#'
#' class(tx_extent)
#'
#' # Can use in joins
#' ngp %>%
#'   st_anti_join(tx_extent) %>%
#'   ggplot() +
#'   geom_sf(data = states_map) +
#'   geom_sf(data = tx_extent, fill = NA) +
#'   geom_sf(color = "red")
#'
#' @name st_extent
#' @export
st_extent <- function (x, type = "sf") {

    x <- sf::st_bbox(x)
    x <- switch(type,

      sf = {
          x %>%
            sf::st_as_sfc() %>%
            sf::st_sf()
      },

      sfc = {
          x %>%
            sf::st_as_sfc()
      })

    # RETURN
    x
}