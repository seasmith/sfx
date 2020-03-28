#' @importFrom magrittr %>%
NULL

#' Check for minimum and maximum occurences of \code{TRUE}
#' from a binary logical function.
#'
#' Converts a logical matrix into a more manageable logical
#' vector.  Each row of the logical matrix must meet the
#' min and max \code{TRUE} threshold (\code{1} and \code{Inf}
#' by default, respectively).
#'
#' @param x (sgbp/matrix) Return object of a simple feature
#'   binary logical function.
#' @param at_least (integer) Minimal occurences of \code{TRUE}.
#'   Default is \code{1L}.
#' @param at_most (integer) Maximum occurences of \code{TRUE}.
#'   Default is \code{Inf}.
#'
#' @examples
#' library(sf)
#' data(ngp)
#' data(states_map)
#'
#' i <- ngp %>%
#'   st_intersects(states_map)
#'
#' i %>%
#'   st_any() %>%
#'   head()
#'
#' i %>%
#'   st_any(3, 10) %>%
#'   head()
#'
#' j <- ngp %>%
#'   st_any_intersects(states_map)
#'
#' head(j)
#' @rdname st_any
#' @export
st_any <- function (x, at_least = 1L, at_most = Inf) UseMethod("st_any")

#' @export
st_any.sgbp <- function (x, at_least = 1L, at_most = Inf) {

  x_int <- x %>%
    lengths()

  # RETURN
  (x_int >= at_least) & (x_int <= at_most)

}

#' @export
st_any.matrix <- function (x, at_least = 1L, at_most = Inf) {

  x_int <- x %>%
    rowSums() %>%
    as.vector()

  # RETURN
  (x_int >= at_least) & (x_int <= at_most)

}

# Workhorse function factory for binary logical operators.
st_any_bin_log_factory <- function(fun) {
    function (x, y, at_least = 1L, at_most = Inf, match_crs = TRUE, ...) {

  x_crs <- sf::st_crs(x)
  y_crs <- sf::st_crs(y)

  if ((x_crs != y_crs) & match_crs) {
    message("CRS of 'y' does not match 'x'.\n" %P%
            "Setting CRS of 'y' to match 'x'.")
    message(x_crs)
    y <- sf::st_transform(y, x_crs)
  }


  # RETURN
  x %>%
    fun(y, sparse = FALSE, ...) %>%
    st_any(at_least, at_most)
  }
}

#' Check for any occurences of \code{TRUE}
#'
#' These functions wrap 'sf' binary logical operators with
#' a call to \code{>=} and \code{<=} -- verifying that a
#' minimamal and maximal number of occurences of \code{TRUE}
#' have been achieved.
#'
#' @inheritParams sf::geos_binary_pred
#' @inheritParams st_any
#' @param match_crs (logical) Should the CRS of \code{y} be coerced to match
#'   the CRS of \code{x}? Default is \code{TRUE}.
#' @param ... (various) Arguments passed on to the underlying binary logical
#'   operator.
#'
#' @examples
#' library(sf)
#' data(ngp)
#' data(states_map)
#'
#' # Works like normal 'sf' binary logical
#' # operators, except it returns a vector.
#' i <- ngp %>%
#'   st_any_intersects(states_map)
#'
#' head(i)
#' @name any_binary_pred
#' @export
st_any_intersects         <- st_any_bin_log_factory(sf::st_intersects)
#' @name any_binary_pred
#' @export
st_any_contains           <- st_any_bin_log_factory(sf::st_contains)
#' @name any_binary_pred
#' @export
st_any_contains_properly  <- st_any_bin_log_factory(sf::st_contains_properly)
#' @name any_binary_pred
#' @export
st_any_covered_by         <- st_any_bin_log_factory(sf::st_covered_by)
#' @name any_binary_pred
#' @export
st_any_covers             <- st_any_bin_log_factory(sf::st_covers)
#' @name any_binary_pred
#' @export
st_any_crosses            <- st_any_bin_log_factory(sf::st_crosses)
#' @name any_binary_pred
#' @export
st_any_disjoint           <- st_any_bin_log_factory(sf::st_disjoint)
#' @name any_binary_pred
#' @export
st_any_equals             <- st_any_bin_log_factory(sf::st_equals)
#' @name any_binary_pred
#' @export
st_any_equals_exact       <- st_any_bin_log_factory(sf::st_equals_exact)
#' @name any_binary_pred
#' @export
st_any_is_within_distance <- st_any_bin_log_factory(sf::st_is_within_distance)
#' @name any_binary_pred
#' @export
st_any_overlaps           <- st_any_bin_log_factory(sf::st_overlaps)
#' @name any_binary_pred
#' @export
st_any_touches            <- st_any_bin_log_factory(sf::st_touches)
#' @name any_binary_pred
#' @export
st_any_within             <- st_any_bin_log_factory(sf::st_within)
