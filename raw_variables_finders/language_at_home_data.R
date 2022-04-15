library(tidycensus)
library(tidyverse)


# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

language_at_home_table <- "S1601"
acs5_vars <- load_variables(year = my_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

language_at_home_vars <- acs5_vars %>% 
  filter( str_detect( acs5_vars$variable, language_at_home_table))

language_at_home_data <- get_acs(geography = "tract", table = language_at_home_table, state = "WA", geometry = T) %>% 
  left_join( language_at_home_vars, by="variable", cache_table = TRUE)
