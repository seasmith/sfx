
# Extra ‘sf’ Simple Features manipulations

[![CRAN](http://www.r-pkg.org/badges/version/sfx)](https://cran.r-project.org/package=sfx)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-red.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![License](http://img.shields.io/badge/license-GPL%20%28%3E=%202%29-brightgreen.svg?style=flat)](http://www.gnu.org/licenses/gpl-2.0.html)

``` r
library(dplyr)
library(sfx)

nc <- sf::read_sf(system.file("shape/nc.shp", package = "sf"))
data(ngp, package = "sfx")
```

The `sfx::st_any_*()` functions return a logical vector which may be
used in `dplyr::filter()` (and possibly `[.data.table`).

``` r
nrow(ngp)
## [1] 33642

# Filter rows that intersect with nc
ngp %>%
  filter(st_any_intersects(ngp, nc)) %>%
  nrow()
## CRS of 'y' does not match 'x'.
## Setting CRS of 'y' to match 'x'.
## 4326+proj=longlat +datum=WGS84 +no_defs
## although coordinates are longitude/latitude, st_intersects assumes that they are planar
## [1] 100
```

The `sfx::st_*_join()` functions mimic the `dplyr` equivalents and some
are just wrappers around `sf::st_join()`.

``` r
ngp %>%
  sf::st_transform(sf::st_crs(nc)) %>%
  st_semi_join(nc)
## although coordinates are longitude/latitude, st_intersects assumes that they are planar
## Simple feature collection with 100 features and 5 fields
## geometry type:  MULTILINESTRING
## dimension:      XY
## bbox:           xmin: -82.91061 ymin: 34.87358 xmax: -77.0256 ymax: 36.99636
## epsg (SRID):    4267
## proj4string:    +proj=longlat +datum=NAD27 +no_defs
## # A tibble: 100 x 6
##      FID TYPEPIPE Operator Shape_Leng Shape__Length
##  * <int> <chr>    <chr>         <dbl>         <dbl>
##  1  1904 Intrast~ Cardina~     1.29         149065.
##  2  2753 Interst~ Columbi~     0.0962        13218.
##  3  4635 Interst~ East Te~     0.0710         8924.
##  4  4636 Interst~ East Te~     1.34         156090.
##  5  3849 Interst~ Columbi~     0.0539         7373.
##  6  3850 Interst~ Columbi~     0.0962        13218.
##  7 27590 Interst~ Transco~     0.133         15471.
##  8 27591 Interst~ Transco~     0.414         48610.
##  9 27592 Interst~ Transco~     0.0686         8114.
## 10 27594 Interst~ Transco~     0.0950        13093.
## # ... with 90 more rows, and 1 more variable: geometry <MULTILINESTRING
## #   [°]>
```

The `sfx::st_ul_*()` functions provide unitless equivalents of the `sf`
functions.

``` r
# st_area would error in this case.
nc %>%
  filter(st_ul_area(nc) > 1e9)
## Simple feature collection with 66 features and 14 fields
## geometry type:  MULTIPOLYGON
## dimension:      XY
## bbox:           xmin: -84.32385 ymin: 33.88199 xmax: -75.7637 ymax: 36.58965
## epsg (SRID):    4267
## proj4string:    +proj=longlat +datum=NAD27 +no_defs
## # A tibble: 66 x 15
##     AREA PERIMETER CNTY_ CNTY_ID NAME  FIPS  FIPSNO CRESS_ID BIR74 SID74
##  * <dbl>     <dbl> <dbl>   <dbl> <chr> <chr>  <dbl>    <int> <dbl> <dbl>
##  1 0.114      1.44  1825    1825 Ashe  37009  37009        5  1091     1
##  2 0.143      1.63  1828    1828 Surry 37171  37171       86  3188     5
##  3 0.153      2.21  1832    1832 Nort~ 37131  37131       66  1421     9
##  4 0.118      1.42  1836    1836 Warr~ 37185  37185       93   968     4
##  5 0.124      1.43  1837    1837 Stok~ 37169  37169       85  1612     1
##  6 0.114      1.35  1838    1838 Casw~ 37033  37033       17  1035     2
##  7 0.153      1.62  1839    1839 Rock~ 37157  37157       79  4449    16
##  8 0.143      1.66  1840    1840 Gran~ 37077  37077       39  1671     4
##  9 0.109      1.32  1841    1841 Pers~ 37145  37145       73  1556     4
## 10 0.19       2.20  1846    1846 Hali~ 37083  37083       42  3608    18
## # ... with 56 more rows, and 5 more variables: NWBIR74 <dbl>, BIR79 <dbl>,
## #   SID79 <dbl>, NWBIR79 <dbl>, geometry <MULTIPOLYGON [°]>
```
