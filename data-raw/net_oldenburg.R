## code to prepare `net_oldenburg` dataset goes here


library(sf)
library(osmextract)
library(dplyr)
library(tmap)

centroid = osmextract:::oe_search("Oldenburg, Germany")
poly = zonebuilder::zb_zone(centroid, n_circles = 1)
mapview::mapview(poly)
et = c("cycleway", "lanes", "lit", "maxspeed", "rcn", "smoothness", "surface", "surveillance")
et = c("lanes", "lit", "maxspeed", "rcn", "smoothness", "surface")
walking_network = oe_get_network(poly, "walking", boundary = poly, boundary_type = "clipsrc", extra_tags = et)
walking_network = walking_network[c("osm_id", "name", et)]
plot(walking_network)
nrow(walking_network)
walking_network_linestrings = st_cast(walking_network, "LINESTRING")
plot(walking_network_linestrings)
nrow(walking_network_linestrings)
net_oldenburg_raw = walking_network_linestrings

usethis::use_data(net_oldenburg_raw, overwrite = TRUE)

points = oe_get(poly, extra_tags = c("amenity"), query = "SELECT * FROM points WHERE amenity = 'pub'", boundary = poly, boundary_type = "clipsrc")
points = points |>
  select(name, osm_id)
mapview::mapview(points)
points_oldenburg = points |>
  filter(stringr::str_detect(name, "Ben|Gast|AU|Kar"))
usethis::use_data(points_oldenburg, overwrite = TRUE)

