states_map <- map_data("state")
states_map <- states_map %>%
  st_as_sf(coords = c("long", "lat"),
           crs = st_crs(4326))

states_map <- states_map %>%
    group_by(group) %>%
    summarize(geometry = st_cast(st_combine(geometry), "MULTILINESTRING")) %>%
    ungroup()