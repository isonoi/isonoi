% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/iso_grid.R
\name{iso_grid}
\alias{iso_grid}
\title{Create hexagonal grid}
\usage{
iso_grid(x, resolution = 9)
}
\arguments{
\item{x}{An sf object the convex hull of which will determine the hex grid}

\item{resolution}{The resolution of the hex grid}
}
\value{
An sfc object
}
\description{
Create a hexagonal grid from an sf object.
}
\details{
See the documentation of the upstream
\href{https://h3geo.org/docs/core-library/restable/#average-area-in-km2}{\code{h3}}
library for more information.
Note: default value of 9 represents around 0.1 km^2, you may way to consider
higher values (e.g. 10, which is around 0.015 km^2 or 15k m^2) for more detailed
analysis or lower values for larger areas.
}
\note{
This function is a wrapper for \code{h3o::sfc_to_cells} and \code{h3o::flatten_h3}.
It assumes that the input object has a geographic (lon/lat) coordinate system, e.g. EPSG:4326.
}
\examples{
x = net_oldenburg_raw
iso_grid(x)
}
