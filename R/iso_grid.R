#' Create hexagonal grid
#' 
#' Create a hexagonal grid from an sf object.
#' 
#' See the documentation of the upstream
#' [`h3`](https://h3geo.org/docs/core-library/restable/#average-area-in-km2)
#' library for more information.
#' Note: default value of 9 represents around 0.1 km^2, you may way to consider
#' higher values (e.g. 10, which is around 0.015 km^2 or 15k m^2) for more detailed
#' analysis or lower values for larger areas.
#'
#' @param x An sf object the convex hull of which will determine the hex grid
#' @param resolution The resolution of the hex grid, 9 by default
#' @return An sf object
#' @export
#' @examples
#' x = net_oldenburg_raw
#' iso_grid(x)
iso_grid = function(x, resolution = 9) {
  poly = sf::st_convex_hull(sf::st_union(x))
  hex = h3o::sfc_to_cells(poly, resolution = resolution)
  hex_flat = h3o::flatten_h3(hex)
  hex_sfc = sf::st_as_sfc(hex_flat)
  hex_sfc
}