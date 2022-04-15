library(tidycensus)
library(tidyverse)
library(stringr)


# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

marital_status_table <- "S1201"
marital_status_vars <- 
  load_variables(year = my_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( acs5_vars$variable, marital_status_table) )

marital_status_data <- get_acs(geography = "tract", table = marital_status_table, state = "WA", geometry = T) %>% 
  left_join(acs5_vars,by="variable") 
