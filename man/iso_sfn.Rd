% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iso_grid.R
\name{iso_sfn}
\alias{iso_sfn}
\title{Calculate voronoi-style polygons based on network distance/time with sfnetworks}
\usage{
iso_sfn(points, net, grid, n = 3)
}
\arguments{
\item{points}{An sf object of points}

\item{net}{An sfnetworks object representing a travel network}

\item{grid}{An sf object of a grid}

\item{n}{The number of nearest points to calculate routes to}
}
\description{
Calculate voronoi-style polygons based on network distance/time with sfnetworks
}
\examples{
points = points_oldenburg
net = sfnetworks::as_sfnetwork(net_oldenburg_raw, directed = FALSE)
grid = iso_grid(net_oldenburg_raw)
sfn = iso_sfn(points, net, grid)
plot(sfn)
}
