#' Create hexagonal grid
#'
#' @param x An sf object the convex hull of which will determine the hex grid
#' @param ... Extra arguments passed to the grid generator (TBC)
#' @export
#' @examples
#' x = net_oldenburg_raw
#' iso_grid(x)
iso_grid = function(x) {
  browser()
  sf::st_convex_hull(sf::st_union(x))
}
