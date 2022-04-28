#Joining all vars
# units of measurement:

#  https://data.census.gov/cedsci/
# marital status (S1201) - count of people (15+ age) var: 'est_population_15+'
# language (B16004)- number of people who speak per group (5+ age) var: 'estimate_age5andolder'
# num of household earners (B19121) - number of earners per family var: 'est_num_families'
# household data/occupancy char. (S2501) - by number of occupied housing units var: 'est_housing_units_total'
# work status (S2303) - count of people (16+ age) var: 'est_population_16to64'

# tidying on each table includes:
# select relevant vars, pivot wider on two columns, create meaningful names

library(tidycensus)
library(tidyverse)
library(stringr)

search_year <- 2019
search_geo <- "tract"

#household / occupancy characteristics data
household_size_table <- "S2501"

household_size_vars <- load_variables(year = search_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join 
  filter( str_detect( variable, household_size_table))

household_size_data <- get_acs(geography = search_geo, table = household_size_table, state = "WA", geometry = F, cache_table = TRUE) %>% 
  left_join( household_size_vars, by="variable") %>%
  select(-c(label,concept)) %>%
  filter(variable == "S2501_C01_001" | variable == "S2501_C01_002"| variable == "S2501_C01_003"| variable == "S2501_C01_004"|
           variable == "S2501_C01_005"|variable == "S2501_C01_006"|variable == "S2501_C01_007"|variable == "S2501_C01_008") %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) %>%
  rename("est_housing_units_total"="estimate_S2501_C01_001","moe_housing_units_total"="moe_S2501_C01_001",
         "est_housing_size_1p"="estimate_S2501_C01_002","moe_housing_size_1p"="moe_S2501_C01_002",
         "est_housing_size_2p"="estimate_S2501_C01_003","moe_housing_size_2p"="moe_S2501_C01_003",
         "est_housing_size_3p"="estimate_S2501_C01_004","moe_housing_size_3p"="moe_S2501_C01_004",
         "est_housing_size_4p"="estimate_S2501_C01_005","moe_housing_size_4p"="moe_S2501_C01_005",
         "est_housing_size_1lessoccup"="estimate_S2501_C01_006","moe_housing_size_1lessoccup"="moe_S2501_C01_006",
         "est_housing_size_1.5lessoccup"="estimate_S2501_C01_007","moe_housing_size_1.5lessoccup"="moe_S2501_C01_007",
         "est_housing_size_1.51moreoccup"="estimate_S2501_C01_008","moe_housing_size_1.51moreoccup"="moe_S2501_C01_008")

#marital status data
marital_status_table <- "S1201"
# haven't integrated these variable names yet
marital_status_variable_names = c("B12001_001","B12001_002","B12001_003","B12001_004","B12001_005","B12001_006","B12001_007","B12001_008","B12001_009","B12001_010","B12001_011","B12001_012","B12001_013","B12001_014","B12001_015","B12001_016","B12001_017","B12001_018","B12001_019")

marital_status_vars <- 
  load_variables(year = search_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( variable, marital_status_table) )

marital_status_data <- get_acs(geography = search_geo, table = marital_status_table, state = "WA", geometry = F, cache_table = T) %>% 
  left_join(marital_status_vars,by="variable") %>%
  select(-c(NAME,label,concept)) %>%
  filter(variable == "S1201_C01_001" | variable == "S1201_C02_001"| variable == "S1201_C03_001"| variable == "S1201_C04_001"|
           variable == "S1201_C05_001" |variable == "S1201_C06_001") %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) %>%
  rename("est_population_15+"="estimate_S1201_C01_001","moe_population_15+"="moe_S1201_C01_001",
         "est_married"="estimate_S1201_C02_001","moe_married"="moe_S1201_C02_001",
         "est_widow"="estimate_S1201_C03_001","moe_widow"="moe_S1201_C03_001",
         "est_divorced"="estimate_S1201_C04_001","moe_divorced"="moe_S1201_C04_001",
         "est_separated"="estimate_S1201_C05_001","moe_separated"="moe_S1201_C05_001",
         "est_single"="estimate_S1201_C06_001","moe_single"="moe_S1201_C06_001")
#join tables
all_census_data <- left_join(household_size_data,marital_status_data,by="GEOID")

#num household earners data
num_earners_prefix <- "B19121_"

acs5_vars <- load_variables(year = search_year, dataset = "acs5", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

num_earners_variables <- vector()

for( i in c(1:5) )
{
  num_earners_variables <- append(num_earners_variables, paste( num_earners_prefix, str_pad( i, 3, pad="0"), sep=""))
}

num_earners_data <- get_acs(geography = search_geo, variables=num_earners_variables , state = "WA", geometry = F) %>% 
  left_join(acs5_vars, by="variable") %>%
  select(-c(NAME,label,concept)) %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) %>%
  rename("est_num_families"="estimate_B19121_001","moe_num_families"="moe_B19121_001",
         "est_no_earner"="estimate_B19121_002","moe_no_earner"="moe_B19121_002",
         "est_single_earner"="estimate_B19121_003","moe_single_earner"="moe_B19121_003",
         "est_dual_earner"="estimate_B19121_004","moe_dual_earner"="moe_B19121_004",
         "est_three_earner"="estimate_B19121_005","moe_three_earner"="moe_B19121_005")

#join tables
all_census_data <- left_join(all_census_data,num_earners_data,by="GEOID")

#language at home data
#new vars
language_at_home_data <- get_acs(geography = "block group", state = "WA", geometry = F,
                    variables= c(age5andolder = "B16004_001",
                                 age5to17="B16004_002", age5to17_eng="B16004_003",
                                 age5to17_spanish="B16004_004",age5to17_european="B16004_009",
                                 age5to17_aapi="B16004_014",
                                 age18to64="B16004_024", age18to64_eng="B16004_025",
                                 age18to64_spanish="B16004_026",age18to64_european="B16004_031",
                                 age18to64_aapi="B16004_035",
                                 age65andolder="B16004_046",
                                 age65andolder_eng="B16004_047", age65andolder_spanish="B16004_048",
                                 age65andolder_european="B16004_053",age65andolder_aapi="B16004_058")) %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) 
#combining across age groups
language_at_home_data$estimate_eng = language_at_home_data$estimate_age5to17_eng +language_at_home_data$estimate_age18to64_eng+language_at_home_data$estimate_age65andolder_eng
language_at_home_data$moe_eng = language_at_home_data$moe_age5to17_eng +language_at_home_data$moe_age18to64_eng+language_at_home_data$moe_age65andolder_eng
language_at_home_data$estimate_spanish = language_at_home_data$estimate_age5to17_spanish +language_at_home_data$estimate_age18to64_spanish+language_at_home_data$estimate_age65andolder_spanish
language_at_home_data$moe_spanish = language_at_home_data$moe_age5to17_spanish +language_at_home_data$moe_age18to64_spanish+language_at_home_data$moe_age65andolder_spanish
language_at_home_data$estimate_european = language_at_home_data$estimate_age5to17_european +language_at_home_data$estimate_age18to64_european+language_at_home_data$estimate_age65andolder_european
language_at_home_data$moe_european = language_at_home_data$moe_age5to17_european +language_at_home_data$moe_age18to64_european+language_at_home_data$moe_age65andolder_european
language_at_home_data$estimate_aapi = language_at_home_data$estimate_age5to17_aapi +language_at_home_data$estimate_age18to64_aapi+language_at_home_data$estimate_age65andolder_aapi
language_at_home_data$moe_aapi = language_at_home_data$moe_age5to17_aapi +language_at_home_data$moe_age18to64_aapi+language_at_home_data$moe_age65andolder_aapi
language_at_home_data <- language_at_home_data %>%
  select(c("GEOID", "NAME","estimate_age5andolder","moe_age5andolder","estimate_eng",
           "moe_eng", "estimate_spanish", "moe_spanish", "estimate_european", "moe_european",
           "estimate_aapi", "moe_aapi"))

#join tables
all_census_data <- left_join(all_census_data,language_at_home_data,by="GEOID")

# work status data
work_status_table <- "S2303"

work_status_vars <- 
  load_variables(year = search_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( variable, work_status_table) )

work_status_data <- get_acs(geography = search_geo, table = work_status_table, state = "WA", geometry = F, cache_table = T ) %>% 
  left_join(work_status_vars,by="variable") %>%
  select(-c(NAME,label,concept)) %>%
  filter(variable == "S2303_C01_001" | variable == "S2303_C01_031"| variable == "S2303_C01_030"| variable == "S2303_C01_023"|
           variable == "S2303_C01_016"|variable == "S2303_C01_009") %>%
  pivot_wider( names_from = variable, values_from = c(estimate,moe)) %>%
  rename( "est_population_16to64"="estimate_S2303_C01_001",
          "moe_population_16-64"="moe_S2303_C01_001",
          "est_mean_hrsworked"="estimate_S2303_C01_031",
          "moe_mean_hrsworked"="moe_S2303_C01_031",
          "est_not_worked"="estimate_S2303_C01_030",
          "moe_not_worked"="moe_S2303_C01_030",
          "est_worked_1to14hrs"="estimate_S2303_C01_023",
          "moe_worked_1to14hrs"="moe_S2303_C01_023",
          "est_worked_15to34hrs"="estimate_S2303_C01_016",
          "moe_worked_15to34hrs"="moe_S2303_C01_016",
          "est_worked_35+hrs"="estimate_S2303_C01_009",
          "moe_worked_35+hrs"="moe_S2303_C01_009")

#join tables
all_census_data <- left_join(all_census_data,work_status_data,by="GEOID")

geography_data <-get_acs (geography = search_geo, variables = "B19013_001", 
                          state = "WA", geometry = T, cache_table = T) %>% 
  select( "GEOID", "geometry")

all_census_data <- left_join(all_census_data, geography_data, by="GEOID")



