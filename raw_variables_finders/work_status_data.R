library(tidycensus)
library(tidyverse)
library(stringr)

# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

work_status_table <- "S2303"
use_year <- 2019

work_status_vars <- 
  load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( variable, work_status_table) )

work_status_data <- get_acs(geography = "tract", table = work_status_table, state = "WA", geometry = T, cache_table = T ) %>% 
  left_join(work_status_vars,by="variable") 
