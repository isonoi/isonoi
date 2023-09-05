# Aim: test the h3o R package

# Starting point: hex grids in sf
remotes::install_github("isonoi/isonoi")
remotes::install_github("josiahparry/h3o")
library(isonoi)
library(sf)
poly = sf::st_convex_hull(sf::st_union(net_oldenburg_raw))
hex_grid = stplanr::geo_projected(
  sf::st_as_sf(poly),
  sf::st_make_grid,
  cellsize = 200,
  square = FALSE
)
hex_grid_smaller = hex_grid[net_oldenburg_raw]
plot(hex_grid)
plot(hex_grid_smaller, add = TRUE, col = "red")
plot(net_oldenburg_raw, add = TRUE, col = "blue")

hex = h3o::sfc_to_cells(poly, resolution = 9)
hex_flat = h3o::flatten_h3(hex)
hex_sfc = sf::st_as_sfc(hex_flat)
plot(hex_grid)
plot(hex_grid_smaller, add = TRUE, col = "red")
plot(hex_sfc, add = TRUE, col = "yellow")
plot(net_oldenburg_raw, add = TRUE, col = "black")

