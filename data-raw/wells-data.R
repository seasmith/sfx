# https://hifld-geoplatform.opendata.arcgis.com/
# https://hifld-geoplatform.opendata.arcgis.com/datasets/oil-and-natural-gas-wells
# originally downloaded 2020-03-28
# from: https://opendata.arcgis.com/datasets/17c5ed5a6bd44dd0a52c616a5b0cacca_0.geojson
# download.file("https://opendata.arcgis.com/datasets/17c5ed5a6bd44dd0a52c616a5b0cacca_0.geojson",
#               "data-raw/wells.geojson")

wells <- st_read("data-raw/Oil_and_Natural_Gas_Wells.csv", stringsAsFactors = FALSE,
                 options = c("X_POSSIBLE_NAMES=SURF_LONG", "Y_POSSIBLE_NAMES=SURF_LAT"))

wells <- read_csv("data-raw/Oil_and_Natural_Gas_Wells.csv", n_max = 10e3)

txt <- readLines("data-raw/Oil_and_Natural_Gas_Wells.csv", n = 300e3)
txt_con <- textConnection(txt[c(1, 115000:300e3)])

wells <- as_tibble(read.csv(txt_con, stringsAsFactors = FALSE))

wells %>%
  filter(STATE == "PA") %>%
  janitor::clean_names() %>%
  write_csv("data-raw/pa-wells.csv")

wells <-wells %>%
  filter(STATE == "PA") %>%
  st_as_sf(coords = c("SURF_LONG", "SURF_LAT"),
           crs = st_crs(4326),
           agr = "identity",
           remove = FALSE) %>%
  janitor::clean_names() %>%
  select(state, county, latitude, longitude, status, operator, name)

