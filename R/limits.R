compute_limits <- function (data,
                            x_expansion,
                            y_expansion,
                            bw,
                            method = "kde2d") {
  switch(method,

         kde2d = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"], na.rm = TRUE)
           } else {
             x_expansion <- rep(x_expansion, length.out = 2)
             x_expansion <- c(1 - x_expansion[1], 1 + x_expansion[2])
             rng_x <- range(data[, "X"], na.rm = TRUE)
             rng_x <- rng_x * (x_expansion)
           }

           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"], na.rm = TRUE)
           } else {
             y_expansion <- rep(y_expansion, length.out = 2)
             y_expansion <- c(1 - y_expansion[1], 1 + y_expansion[2])
             rng_y <- range(data[, "Y"], na.rm = TRUE)
             rng_y <- rng_y * (y_expansion)
           }
          return(c(rng_x, rng_y))
         },

         bkde2D = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"])
             rng_x[1] <- rng_x[1] - 1.75 * bw[1]
             rng_x[2] <- rng_x[2] + 1.75 * bw[1]
           }

           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"])
             rng_y[1] <- rng_y[1] - 1.75 * bw[2]
             rng_y[2] <- rng_y[2] + 1.75 * bw[2]
           }
           return(list(rng_x, rng_y))
         })
}
