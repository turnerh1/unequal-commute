# Install tigris and rtidycensus packages

library(tidycensus)
library(tidyverse)

# load your data, but leave out the geometries
job_access_gap <- read_csv("job_access_gap.csv", 
                           col_types = cols(geometry = col_skip()))

options(tigris_use_cache = TRUE)

#all variables avaiable for access
vars <- load_variables(year = 2019,
                       dataset = "acs5",
                       cache = TRUE)

# Go to http://api.census.gov/data/key_signup.html to get census api key
# substitute your api key inside the quotes below:
census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = FALSE)

# download geometries for the state of washington for all census block groups:
wa_geometry <- get_acs(geography = "block group", variables = "B19013_001", 
                       state = "WA", geometry = T)

# the command above also gets estimates of median household income (that's "B19013_001")
# you have to download at least one variable to make it work

# filter the geometries to just the ones included in your data:
wa_geometry <- wa_geometry %>%
  mutate(GEOID = as.numeric(GEOID)) %>%
  filter(GEOID %in% job_access_gap$GEOID)

# join your data with geometries:
map_data <- left_join(wa_geometry, job_access_gap)

# map of median household income for Seattle area:
ggplot(map_data) +
  geom_sf(aes(fill = estimate), size=0.1)
