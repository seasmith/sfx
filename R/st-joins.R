#' Join two 'sf' objects.
#'
#' @description
#' Both `st_left_join()` and `st_inner_join()` are
#' wrappers around `sf::st_join()` with appropriate
#' argument handling for `left`.
#'
#' Both `st_anti_join()` and `st_semi_join()` are
#' wrappers around `sfx::st_any()` used within
#' `dplyr::filter()` (plus the application of
#' logical `!` where appropriate).
#'
#' @inheritParams sf::st_join
#'
#' @examples
#' library(sf)
#' library(ggplot2)
#' library(dplyr)
#' data(states_map)
#' data(ngp)
#'
#' show_map <- function (x) {
#'     ggplot(x) +
#'         geom_sf(data = tx) +
#'         geom_sf(color = "red") +
#'         theme_void()
#' }
#'
#' # MUTLIPOLYGON of the US state of Texas
#' tx <- states_map %>%
#'     filter(region == "texas")
#'
#' # [Semi-join] Intersects (Default)
#' ngp %>%
#'         st_semi_join(tx) %>%
#'         show_map()
#'
#' # [Semi-join] Coveredy by
#' ngp %>%
#'         st_semi_join(tx, sf::st_covered_by) %>%
#'         show_map()
#'
#' # [Anti-join] Intersects (Default)
#' ngp %>%
#'         st_anti_join(tx) %>%
#'         show_map()
#'
#' # [Inner-join] Intersects (Default)
#' ngp %>%
#'   st_inner_join(tx)
#'
#' @name st_joins
#' @export
st_left_join <- function (x, y, ...) sf::st_join(x, y, left = TRUE, ...)
#' @name st_joins
#' @export
st_inner_join <- function (x, y, ...) sf::st_join(x, y, left = FALSE, ...)

#' @name st_joins
#' @export
st_semi_join <- function (x, y, join = sf::st_intersects, ...) {

    stopifnot(inherits(x, "sf") && inherits(y, "sf"))

    # RETURN
    x %>%
      dplyr::filter(st_any(join(x, y, ...)))
}

#' @name st_joins
#' @export
st_anti_join <- function (x, y, join = sf::st_intersects, ...) {

    stopifnot(inherits(x, "sf") && inherits(y, "sf"))

    # RETURN
    x %>%
      dplyr::filter(!st_any(join(x, y, ...)))
}