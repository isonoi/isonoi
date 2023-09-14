#' Calculate voronoi-style polygons based on grid with OSRM routing duration
#'
#' @note The function requires OSRM to be running, with the server being
#' @note defined by the setting for the osrm package,
#' @note i.e., getOption("osrm.server") and getOption("osrm.profile")
#'
#'
#' @param x An sf object of a grid
#' @param points An sf object of points
#' @param measure passed on to osrm::osrmTable, can be either "duration" (minutes) or "distance" (meters)
#' @param osrm.server the base URL of the routing server (end with "/")
#' @param osrm.profile the routing profile to use
#'
#' @return An sf object of a grid, where column 'index_min' gives the index of the input point, for which the measure is minimal
#' @importFrom  rlang .data
#' @export
#'
#' @examples
#' points = points_oldenburg
#' x = sf::st_as_sf(iso_grid(net_oldenburg_raw, resolution = 10))
#' options(osrm.server = "http://0.0.0.0:5000/")
#' options(osrm.profile = "car")
#' #grid = isonoi::iso_osrm(x, points, measure = "duration")
#' #plot(grid)
iso_osrm <- function(x,
                     points,
                     measure = "duration",
                     osrm.server = getOption("osrm.server"),
                     osrm.profile = getOption("osrm.profile")) {

  grid_centroids <- sf::st_centroid(x)

  osrm_result <- lapply(1:nrow(points), function(i) {
    osrm_request <- osrm::osrmTable(src = points[i,],
                                    dst = grid_centroids,
                                    measure = measure,
                                    osrm.server = osrm.server,
                                    osrm.profile = osrm.profile)
    if (measure == "duration") {
      return(osrm_request$durations)
    }
    if (measure == "distance") {
      return(osrm_request$distances)
    }
  })

  matrix <- do.call(rbind, osrm_result) |>
    t() |>
    tibble::as_tibble(.name_repair = "unique") |>
    dplyr::rowwise() |>
    dplyr::mutate(
      index_min = which.min(dplyr::c_across(dplyr::everything())),
      osrm_measure = measure,
      osrm_profile = osrm.profile
    )

  x <- dplyr::bind_cols(x, matrix |>
                               dplyr::select(index_min,
                                             osrm_measure,
                                             osrm_profile))
  x
}
