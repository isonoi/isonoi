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

# Commented code that will be generalised in iso_vnoi:
# points_projected = st_transform(points, local_crs)
# poly_projected = st_transform(poly, local_crs)
# voronoi_projected = st_voronoi(st_union(points_projected), poly_projected$geometry)
# voronoi_projected_polygons = st_collection_extract(voronoi_projected, type = "POLYGON")
# But with sf:: before the st_* functions

#' Generate voronoi polygons from a bounding box and points
#' 
#' @param points An sf object of points
#' @param poly A polygon object
#' @return An sf object of voronoi polygons
#' @export
#' @examples
#' points = points_oldenburg
#' poly = sf::st_convex_hull(sf::st_union(net_oldenburg_raw))
#' nvoi = iso_vnoi(points, poly)
#' plot(nvoi)
#' plot(points, add = TRUE)
iso_vnoi = function(points, poly) {
  browser()
  points_projected = sf::st_transform(points, sf::st_crs(poly))
  poly_projected = sf::st_transform(poly, sf::st_crs(points))
  voronoi_projected = sf::st_voronoi(sf::st_union(points_projected), poly_projected$geometry)
  voronoi_projected_polygons = sf::st_collection_extract(voronoi_projected, type = "POLYGON")
  voronoi_projected_polygons_sf = sf::st_sf(
    sf::st_drop_geometry(points_projected),
    geometry = voronoi_projected_polygons
  )
  voronoi_projected_polygons_sf
}

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

