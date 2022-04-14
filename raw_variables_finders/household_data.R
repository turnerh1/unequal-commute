library(tidycensus)
library(tidyverse)


# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

acs5_vars <- load_variables(year = my_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

household_size_data <- get_acs(geography = "tract", table = "S2501", state = "WA", geometry = T) %>% 
  left_join( acs5_vars, by="variable", cache_table = TRUE)
