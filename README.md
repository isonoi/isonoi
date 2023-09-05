
<!-- README.md is generated from README.Rmd. Please edit that file -->

# isonoi

<!-- badges: start -->

[![R-CMD-check](https://github.com/streetvoronoi/isonoi/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/streetvoronoi/isonoi/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of isonoi is to provide example data and functions to
demonstrate the concept of ‘iso voronoi’ polygons.

Give it a spin with the reproducible examples shown below.

``` r
remotes::install_github("isonoi/isonoi")
```

``` r
library(isonoi)
library(sf)
#> Linking to GEOS 3.11.1, GDAL 3.6.4, PROJ 9.1.1; sf_use_s2() is TRUE
x = net_oldenburg_raw
hex = iso_grid(x)
plot(hex)
plot(x, add = TRUE)
#> Warning in plot.sf(x, add = TRUE): ignoring all but the first attribute
```

![](README_files/figure-gfm/inputs-1.png)<!-- -->
