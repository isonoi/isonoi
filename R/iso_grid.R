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
  voronoi_collection = sf::st_voronoi(sf::st_union(points), poly)
  voronoi_polygons = sf::st_collection_extract(voronoi_collection, type = "POLYGON")
  voronoi = sf::st_join(sf::st_as_sf(voronoi_polygons), points)
  voronoi_clipped = sf::st_intersection(voronoi, poly)
  voronoi_clipped
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
  grid_joined = iso_join(points, grid)
  voronoi_grid = grid_joined |>
    dplyr::group_by(dplyr::across(1)) |>
    dplyr::summarise()
  voronoi_grid
}

iso_join = function(points, grid) {
  grid_sf = sf::st_as_sf(grid)
  grid_centroids = sf::st_centroid(grid_sf)
  nearest_points = sf::st_join(grid_centroids, points, join = nngeo::st_nn, k = 1, progress = FALSE)
  grid_joined = sf::st_sf(
    sf::st_drop_geometry(nearest_points),
    geometry = grid
  )
}

# Code to inform the function:

# ```{r}
# net_nodes = net |> 
#   activate("nodes") |>
#   st_as_sf()
# point_ids = nngeo::st_nn(
#   rpoints,
#   net_nodes, k = 1,
#   progress = FALSE
# ) |> unlist()
# point_df = data.frame(
#   from = rep(point_ids, each = length(point_ids)),
#   to = rep(point_ids, length(point_ids))
# ) |>
#   filter(from != to)

# paths_all = st_network_paths(
#   net,
#   from = point_df$from,
#   to = point_df$to,
#   weights = "weight"
# )
# class(paths_all)
# routes_list = lapply(seq(nrow(paths_all)), function(i) {
#   net |> 
#     activate("edges") |> 
#     slice(paths_all$edge_paths[[i]]) |>
#     mutate(route_number = i) |>
#     sf::st_as_sf()
# })
# routes_list[[1]]
# routes_sf = do.call(rbind, routes_list)
# tm_shape(roxel) + tm_lines() +
#   tm_shape(rpoints) + tm_dots(col = "red", size = 0.8) +
#   tm_shape(routes_sf) + tm_lines(lwd = 5, col = "blue", alpha = 0.05)
# ```

# We can calculate the amount of travel on each link as follows:

# ```{r}
# routes_sf$n = 1
# rnet = stplanr::overline(routes_sf, "n")
# tm_shape(rnet) + tm_lines(lwd = "n", scale = 9)
# ```

# ```{r, echo=TRUE}
# net_linestrings = sf::st_cast(walking_network, "LINESTRING")
# net = sfnetworks::as_sfnetwork(net_linestrings, directed = FALSE)
# library(tidygraph)
# with_graph(net, graph_component_count())
# net = net |>
#   activate("edges") |>
#   mutate(weight = edge_length()) |>
#   activate("nodes") |>
#   filter(group_components() == 1)
# with_graph(net, graph_component_count())

# net_sf = net |> 
#   sfnetworks::activate("edges") |> 
#   sf::st_as_sf() |> 
#   dplyr::select(from, to, weight)
# nrow(net_sf)
# nrow(walking_network)
# tm_shape(walking_network) + tm_lines("grey", lwd = 5) +
#   tm_shape(net_sf) + tm_lines("blue", lwd = 2) 
# ```

# We'll start by calculating routes from the first `hex_boundary` cell to the nearest point.

# ```{r}
# net_nodes = net |> 
#   activate("nodes") |>
#   st_as_sf()
# from_point = hex_joined_centroids[1, ]
# to_point = points[1, ]
# path = sfnetworks::st_network_paths(net, from_point, to_point)
# path_sf = net |> 
#   activate("edges") |> 
#   slice(path$edge_paths[[1]]) |>
#   sf::st_as_sf()

# tm_shape(voronoi_hex, bb = st_bbox(voronoi)) + tm_polygons(col = "name") +
#   tm_shape(hex_joined[1, ]) + tm_fill(col = "black") +
#   tm_shape(hex_boundary) + tm_fill(col = "grey", alpha = 0.8) +
#   tm_shape(points) + tm_dots(col = "red", size = 0.8) +
#   tm_shape(voronoi) + tm_borders(col = "blue", lwd = 5) +
#   tm_shape(path_sf) + tm_lines()
#   tm_layout(legend.outside = TRUE)
# ```

# ## Calculation of shortest paths in boundary cell

# A logical next step is to calculate the shortest path to n nearest (in Euclidean distance) destinations for 'boundary cells'.
# We do this for the first boundary cell as follows:

# ```{r}
# n = 3
# first_boundary_point = hex_boundary_centroids[1, ]
# nearest_point_ids = nngeo::st_nn(
#   first_boundary_point,
#   points, k = n,
#   progress = FALSE
# )[[1]]
# nearest_points = points[nearest_point_ids, ]
# # plot the result
# tm_shape(voronoi_hex, bb = st_bbox(voronoi)) + tm_polygons(col = "name") +
#   tm_shape(hex_boundary[1, ]) + tm_fill(col = "black") +
#   tm_shape(hex_boundary) + tm_fill(col = "grey", alpha = 0.8) +
#   tm_shape(points) + tm_dots(col = "red", size = 0.8) +
#   tm_shape(voronoi) + tm_borders(col = "blue", lwd = 5) +
#   tm_shape(nearest_points) + tm_dots(col = "green", size = 0.8) +
#   tm_layout(legend.outside = TRUE)
# ```

# Next we'll calculate the paths, keeping the total length of each path:

# ```{r}
# paths = st_network_paths(
#   net,
#   from = first_boundary_point,
#   to = nearest_points,
#   weights = "weight"
# )
# path_1 = net |> 
#   activate("edges") |> 
#   slice(paths$edge_paths[[1]]) |>
#   mutate(route_number = 1) |>
#   sf::st_as_sf()
# sum(path_1$weight)

# path_weights = sapply(seq(nrow(paths)), function(i) {
#   net |> 
#     activate("edges") |> 
#     slice(paths$edge_paths[[i]]) |>
#     mutate(route_number = i) |>
#     sf::st_as_sf() |>
#     summarise(length = sum(weight)) |>
#     pull(length)
# })
# point_shortest_id = which.min(path_weights)
# point_shortest = nearest_points[point_shortest_id, ]
# cell_value_original = first_boundary_point$name
# cell_value_new = point_shortest$name
# cell_value_original
# cell_value_new
# ```

# As shown, the pub associated with the shortest path is different from the pub associated with the original cell.
# We will update the cell value to reflect this:

# ```{r}
# which_hex = which(lengths(st_intersects(hex_joined, first_boundary_point)) > 0)
# hex_iso = hex_joined
# hex_iso$name[which_hex] 
# hex_iso$name[which_hex] = cell_value_new
# m1 = tm_shape(hex_joined) + tm_polygons(col = "name")
# m2 = tm_shape(hex_iso) + tm_polygons(col = "name")
# tmap_arrange(m1, m2)
# ```

# We'll now repeat this process for all boundary cells:

# ```{r}
# i = 2
# for(i in seq(nrow(hex_boundary))) {
#   first_boundary_point = hex_boundary_centroids[i, ]
#   nearest_point_ids = nngeo::st_nn(
#     first_boundary_point,
#     points, k = n,
#     progress = FALSE
#   )[[1]]
#   nearest_points = points[nearest_point_ids, ]
#   paths = st_network_paths(
#     net,
#     from = first_boundary_point,
#     to = nearest_points,
#     weights = "weight"
#   )
#   path_weights = sapply(seq(nrow(paths)), function(i) {
#     net |> 
#       activate("edges") |> 
#       slice(paths$edge_paths[[i]]) |>
#       mutate(route_number = i) |>
#       sf::st_as_sf() |>
#       summarise(length = sum(weight)) |>
#       pull(length)
#   })
#   point_shortest_id = which.min(path_weights)
#   point_shortest = nearest_points[point_shortest_id, ]
#   cell_value_original = first_boundary_point$name
#   cell_value_new = point_shortest$name
#   which_hex = which(lengths(st_intersects(hex_joined, first_boundary_point)) > 0)
#   hex_iso$name[which_hex] = cell_value_new
# }

#' Calculate voronoi-style polygons based on network distance/time with sfnetworks
#' 
#' @param net An sfnetworks object representing a travel network
#' @param n The number of nearest points to calculate routes to
#' @inheritParams iso_vgrid
#' @export
#' @examples
#' points = points_oldenburg
#' net = sfnetworks::as_sfnetwork(net_oldenburg_raw, directed = FALSE)
#' grid = iso_grid(net_oldenburg_raw)
#' sfn = iso_sfn(points, net, grid)
#' plot(sfn)
iso_sfn = function(points, net, grid, n = 3) {

  # # Prepare data
  # TODO: separate out as separate cleaning function?
  net = net |> 
    sfnetworks::activate("edges") |> 
    dplyr::mutate(weight = sfnetworks::edge_length()) |> 
    sfnetworks::activate("nodes") |> 
    dplyr::filter(tidygraph::group_components() == 1)
  net_nodes = net |> 
    sfnetworks::activate("nodes") |>
    sf::st_as_sf()

  # Note: this bit could be made more performant (although small beer):
  vgrid = iso_vgrid(points, grid)
  grid_v = iso_join(points, grid)[1]
  vgrid_points = sf::st_centroid(grid_v)
  inner_lines = rmapshaper::ms_innerlines(vgrid)
  grid_boundary_ids = which(lengths(sf::st_intersects(grid, inner_lines)) > 0)

  # Calculate shortest paths
  i = 1
  for(i in grid_boundary_ids) {
    grid_point_i = vgrid_points[i, ]
    nearest_point_ids = nngeo::st_nn(
      grid_point_i,
      points,
      k = n,
      progress = FALSE
    )[[1]]
    paths = sfnetworks::st_network_paths(
      net,
      from = grid_point_i,
      to = points[nearest_point_ids, ],
      weights = "weight"
    )
    path_weights = sapply(seq(nrow(paths)), function(j) {
      net |> 
        sfnetworks::activate("edges") |> 
        dplyr::slice(paths$edge_paths[[j]]) |>
        dplyr::mutate(route_number = j) |>
        sf::st_as_sf() |>
        dplyr::summarise(length = sum(weight)) |>
        dplyr::pull(length)
    })
    point_shortest_id = which.min(path_weights)
    point_shortest = points[point_shortest_id, ]
    cell_value_original = grid_point_i[[1]]
    cell_value_new = point_shortest[[1]]
    grid_v[[1]][i] = cell_value_new
  }
  grid_v = dplyr::left_join(grid_v, sf::st_drop_geometry(points))
  grid_v
}
