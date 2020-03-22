# https://hifld-geoplatform.opendata.arcgis.com/
# https://hifld-geoplatform.opendata.arcgis.com/datasets/natural-gas-pipelines
# original downloaded 2020-03-21: "https://opendata.arcgis.com/datasets/f44e00fce8b943f69a40a2324cf49dfd_0.geojson"
ngp <- read_sf("data-raw/ngp.geojson")

# Get rid of Alaskan pipeline
ngp <- ngp %>%
  st_semi_join(st_extent(states_map)) %>%
  rmapshaper::ms_simplify()