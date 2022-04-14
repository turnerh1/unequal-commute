library(tidycensus)
library(tidyverse)

# census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = FALSE, install = TRUE)

get_variables = c("B12001_001","B12001_002","B12001_003","B12001_004","B12001_005","B12001_006","B12001_007","B12001_008","B12001_009","B12001_010","B12001_011","B12001_012","B12001_013","B12001_014","B12001_015","B12001_016","B12001_017","B12001_018","B12001_019")

sample <- get_acs(geography = "block group", variables = get_variables, state = "WA", geometry = T)

