library(tidycensus)
library(tidyverse)
library(stringr)



# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

household_size_table <- "S2501"

household_size_vars <- load_variables(year = my_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join 
  filter( str_detect( acs5_vars$variable, household_size_table))

household_size_data <- get_acs(geography = "tract", table = household_size_table, state = "WA", geometry = T) %>% 
  left_join( acs5_vars, by="variable", cache_table = TRUE)