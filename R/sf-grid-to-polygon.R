rm_na <- function (x) c(stats::na.omit(x))
st_list_polygon <- function (x) lapply(x, function (l) sf::st_polygon(list(l)))

# Convert a regularly-spaced grid to polygons
#
# @param x (matrix/data.frame) Coordinates
# @param coords (character) Character name or ordinal position of
#  coordinate columns (x and y, respectively).
# @param crs (crs) The crs of the coordinates.
sf_grid_to_polygon <- function (x, coords = NULL, crs = NULL) {

  if (is.null(coords)) coords <- 1:2
  if (is.null(crs)) crs <- sf::st_crs(NA)

  x_coords <- x[, coords[1]]
  y_coords <- x[, coords[2]]
  nr <- nrow(x)
  ux <- unique(sort(x_coords))
  uy <- unique(sort(y_coords))
  dx <- diff(ux)
  dy <- diff(uy)

  # Extend to same length as grid
  dx <- c(dx, dx[length(dx)])
  dy <- c(dy, dy[length(dy)])
  lx <- length(dx)
  ly <- length(dy)

  # Create vectors the same length as rows
  vdx <- rep(dx, nr / lx)
  vdy <- rep(dy, each = nr / ly)

  mx <- mapply(function (sx, sy, hx, hy) {
                 x <- sx + c(-hx, hx, hx, -hx, -hx)
                 y <- sy + c(hy, hy, -hy, -hy, hy)
                 matrix(c(x, y), ncol = 2)
               },
               sx = x_coords, sy = y_coords, hx = vdx / 2, hy = vdy / 2,
               SIMPLIFY = FALSE)

  mx <- sf::st_sfc(st_list_polygon(mx), crs = crs)
  x <- sf::st_sf(geometry = mx)

  # RETURN
  x
}