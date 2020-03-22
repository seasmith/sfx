#' Unitless measures
#'
#' @inheritParams sf::geos_measures
#'
#' @examples
#' library(dplyr)
#' data(states_map)
#'
#' states_map %>%
#'   filter(sfx::st_ul_area(states_map) > 250e9)
#'
#' @name unitless_measures
#' @export
st_ul_area <- function (x, ...) unclass(sf::st_area(x, ...))
#' @name unitless_measures
#' @export
st_ul_length <- function (x) unclass(sf::st_length(x))
#' @name unitless_measures
#' @export
st_ul_distance <- function (x, y, ..., dist_fun, by_element = FALSE,
                            which = ifelse(isTRUE(sf::st_is_longlat(x)), 
                                           "Great Circle", "Euclidean"),
                            par = 0, tolerance = 0) {

    unclass(sf::st_distance(x, y, ..., dist_fun, by_element = by_element,
                            which = which, par = par, tolerance = tolerance))

}