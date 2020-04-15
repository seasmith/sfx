check_for_bw <- function (x, d, m) {
  if (is.null(x)) {
    x <- estimate_bw(d, method = m)
    message("No bandwidth provided, using estimate: " %P% x)
  }

  x
}

estimate_bw <- function (data, method = "kde2d") UseMethod("estimate_bw")

estimate_bw.sf <- function (data, method = "kde2d") {

  data <- sf::st_coordinates(data)
  NextMethod()
}

estimate_bw.sfc <- estimate_bw.sf

estimate_bw.default <- function (data, method = "kde2d") {

  set.seed(1814)

  bw <- switch(method,

         # Preserve in case I want to use stats::bw.SJ
         # kde2d = {
         #   mean(c(stats::bw.SJ(data[, "X"]), stats::bw.SJ(data[, "Y"])))
         # },

         bkde2D = {
           c(KernSmooth::dpik(data[, "X"]), KernSmooth::dpik(data[, "Y"]))
         },

         kde2d = {
           c(MASS::bandwidth.nrd(data[, "X"]),
             MASS::bandwidth.nrd(data[, "Y"]))
         })

  bw
}
