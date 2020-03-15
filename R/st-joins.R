#' Join two 'sf' objects.
#'
#' @inheritParams sf::st_join
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