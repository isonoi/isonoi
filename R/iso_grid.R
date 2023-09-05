#' Create hexagonal grid
#' 
#' Create a hexagonal grid from an sf object
#'
#' @param x An sf object the convex hull of which will determine the hex grid
#' @param resolution The resolution of the hex grid
#' @return An sfc object
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

