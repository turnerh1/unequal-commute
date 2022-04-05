library(tidyverse)
library(geojsonsf)
library(broom)

## read the geojson and convert to sf
job_access_gap_sf <- geojson_sf( "../data/job_access_gap.geojson" )

# plot all four cities on one map
# will take a bit to render
ggplot( job_access_gap_sf ) + 
  geom_sf()

# Seattle base map, no data
job_access_gap_sf_sea <- 
  job_access_gap_sf %>% 
  filter( MSA == "Seattle" )

ggplot( job_access_gap_sf_sea ) + 
  geom_sf()

# Baltimore base map, no data
job_access_gap_sf_bal <- 
  job_access_gap_sf %>% 
  filter( MSA == "Baltimore" )

ggplot( job_access_gap_sf_bal ) + 
  geom_sf()

# Lansing base map, no data
job_access_gap_sf_lan <- 
  job_access_gap_sf %>% 
  filter( MSA == "Lansing" )

ggplot( job_access_gap_sf_lan ) + 
  geom_sf()

# Nashville base map, no data
job_access_gap_sf_nas <- 
  job_access_gap_sf %>% 
  filter( MSA == "Nashville" )

ggplot( job_access_gap_sf_nas ) + 
  geom_sf()

