compute_expansion <- function (return_type, method) {
  if (return_type == "polygon" & method == "kde2d") {
    x_expansion <- 0.15
    y_expansion <- 0.15
  } else {
    x_expansion <- 0
    y_expansion <- 0
  }
  
  # RETURN
  c(x_expansion, y_expansion)
}

compute_limits <- function (data,
                            return_type,
                            x_expansion,
                            y_expansion,
                            bw,
                            method = "kde2d") {
  # if(is.null(x_expansion) & is.null(y_expansion)) ex <- compute_expansion(return_type, method)
  # x_expansion <- ex[1]
  # y_expansion <- ex[2]
  
  switch(method,
         
         kde2d = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"], na.rm = TRUE)
           } else {
             x_expansion <- rep(x_expansion, length.out = 2)
             rng_x <- range(data[, "X"], na.rm = TRUE)
             dist_x <- as.vector(stats::dist(rng_x))
             
             if (x_expansion[1] > 0) {
               rng_x[1] <- rng_x[1] - abs(x_expansion[1] * dist_x)
             } else {
               rng_x[1] <- rng_x[1] + abs(x_expansion[1] * dist_x)
             }
             
             if (x_expansion[2] > 0) {
               rng_x[2] <- rng_x[2] + abs(x_expansion[2] * dist_x)
             } else {
               rng_x[2] <- rng_x[2] - abs(x_expansion[2] * dist_x)
             }
           }
           
           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"], na.rm = TRUE)
           } else {
             y_expansion <- rep(y_expansion, length.out = 2)
             rng_y <- range(data[, "Y"], na.rm = TRUE)
             dist_y <- as.vector(stats::dist(rng_y))
             
             if (y_expansion[1] > 0) {
               rng_y[1] <- rng_y[1] - abs(y_expansion[1] * dist_y)
             } else {
               rng_y[1] <- rng_y[1] + abs(y_expansion[1] * dist_y)
             }
             
             if (y_expansion[2] > 0) {
               rng_y[2] <- rng_y[2] + abs(y_expansion[2] * dist_y)
             } else {
               rng_y[2] <- rng_y[2] - abs(y_expansion[2] * dist_y)
             }
           }
           return(c(rng_x, rng_y))
         },
         
         bkde2D = {
           if (is.null(x_expansion)) {
             rng_x <- range(data[, "X"])
             rng_x[1] <- rng_x[1] - 1.75 * bw[1]
             rng_x[2] <- rng_x[2] + 1.75 * bw[1]
           } else {
             rng_x <- x_expansion
           }
           
           if (is.null(y_expansion)) {
             rng_y <- range(data[, "Y"])
             rng_y[1] <- rng_y[1] - 1.75 * bw[2]
             rng_y[2] <- rng_y[2] + 1.75 * bw[2]
           } else {
             rng_y <- y_expansion
           }
           
           return(list(rng_x, rng_y))
         })
}
