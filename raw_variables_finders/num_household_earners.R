library(tidycensus)
library(tidyverse)
library(stringr)

# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

num_earners_prefix <- "B19121_"
use_year <- 2019

acs5_vars <- load_variables(year = use_year, dataset = "acs5", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

num_earners_variables <- vector()

for( i in c(1:5) )
{
  num_earners_variables <- append(num_earners_variables, paste( num_earners_prefix, str_pad( i, 3, pad="0"), sep=""))
}

num_earners_data <- get_acs(geography = "tract", variables=num_earners_variables , state = "WA", geometry = T) %>% 
  left_join(acs5_vars, by="variable") 

#no geometry
num_earners_data_no_geo <- get_acs(geography = "tract", variables=num_earners_variables , state = "WA", geometry = F) %>% 
  left_join(acs5_vars, by="variable") 
