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
#' @note This function is a wrapper for `h3o::sfc_to_cells` and `h3o::flatten_h3`.
#' It assumes that the input object has a geographic (lon/lat) coordinate system, e.g. EPSG:4326.
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

# # example code for the function, to be packaged:

# ```{r}
# hex_grid = stplanr::geo_projected(
#   voronoi,
#   st_make_grid,
#   cellsize = 200,
#   square = FALSE
# )
# hex_grid = hex_grid[poly]
# tm_shape(hex_grid) + tm_polygons() +
#   tm_shape(points) + tm_dots(col = "red", size = 0.8)
# ```

# We'll iterate over every hex cell to find the nearest pub, first using nearest distances:

# ```{r}
# hex_df = data.frame(name = NA)
# hex_centroids = st_as_sf(st_centroid(hex_grid))
# nearest_points = st_join(hex_centroids, points, join = nngeo::st_nn, k = 1, progress = FALSE)
# hex_joined = st_sf(
#   st_drop_geometry(nearest_points),
#   geometry = hex_grid
# )
# hex_joined_centroids = st_centroid(hex_joined)
# voronoi_hex = hex_joined |>
#   group_by(name) |>
#   summarise(n = n())
# tm_shape(voronoi_hex, bb = st_bbox(voronoi)) + tm_polygons(col = "name") +
#   tm_shape(points) + tm_dots(col = "red", size = 0.8) +
#   tm_shape(voronoi) + tm_borders(col = "blue", lwd = 5) +
#   tm_layout(legend.outside = TRUE)
# ```

#' Calculate voronoi-style polygons based on grid with Euclidean distances
#' 
#' @note The function groups by the first column in the points object which should be unique (e.g. OSM ID).
#' 
#' @param points An sf object of points
#' @param grid An sf object of a grid
#' @export
#' @examples
#' points = points_oldenburg
#' x = net_oldenburg_raw
#' grid = iso_grid(x)
#' vgrid = iso_vgrid(points, grid)
iso_vgrid = function(points, grid) {
  grid_sf = sf::st_as_sf(grid)
  grid_centroids = sf::st_centroid(grid_sf)
  nearest_points = sf::st_join(grid_centroids, points, join = nngeo::st_nn, k = 1, progress = FALSE)
  grid_joined = sf::st_sf(
    sf::st_drop_geometry(nearest_points),
    geometry = grid
  )
  grid_joined_centroids = sf::st_centroid(grid_joined)
  voronoi_grid = grid_joined |>
    dplyr::group_by(dplyr::across(1)) |>
    dplyr::summarise()
  voronoi_grid
}

# #' Calculate voronoi-style polygons based on network distance/time with sfnetworks
# #' 
# #' @param x An sfnetworks object

