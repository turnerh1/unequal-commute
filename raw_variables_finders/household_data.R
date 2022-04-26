library(tidycensus)
library(tidyverse)
library(stringr)

# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

household_size_table <- "S2501"
use_year <- 2019

household_size_vars <- load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join 
  filter( str_detect( variable, household_size_table))

household_geometry <- get_acs(geography = "tract", table = household_size_table, state = "WA", geometry = T, cache_table = TRUE) %>% 
  left_join( household_size_vars, by="variable")%>%
  select(GEOID, NAME, geometry)

household_geometry <- get_acs(geography = "tract", table = household_size_table, state = "WA", geometry = T, cache_table = TRUE) %>% 
  left_join( household_size_vars, by="variable")%>%
  select(GEOID, geometry)
