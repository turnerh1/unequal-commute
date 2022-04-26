#Joining all vars
# units of measurement:

#  https://data.census.gov/cedsci/
# marital status (S1201) - count of people (15+ age) var: 'est_population_15+'
# language (S1601)- number of people who speak per group (5+ age) var: 'est_population_5+'
# num of household earners (B19121) - number of earners per family var: 'est_num_families'
# household data/occupancy char. (S2501) - by number of occupied housing units var: 'est_housing_units_total'
# work status (S2303) - count of people (16+ age) var: 'est_population_16to64'

# tidying on each table includes:
# select relevant vars, pivot wider on two columns, create meaningful names

library(tidycensus)
library(tidyverse)
library(stringr)

use_year <- 2019

#household / occupancy characteristics data
household_size_table <- "S2501"

household_size_vars <- load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join 
  filter( str_detect( variable, household_size_table))

household_size_data <- get_acs(geography = "tract", table = household_size_table, state = "WA", geometry = F, cache_table = TRUE) %>% 
  left_join( household_size_vars, by="variable") %>%
  select(-c(label,concept)) %>%
  filter(variable == "S2501_C01_001" | variable == "S2501_C01_002"| variable == "S2501_C01_003"| variable == "S2501_C01_004"|
           variable == "S2501_C01_005") %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) %>%
  rename("est_housing_units_total"="estimate_S2501_C01_001","moe_housing_units_total"="moe_S2501_C01_001",
         "est_housing_size_1p"="estimate_S2501_C01_002","moe_housing_size_1p"="moe_S2501_C01_002",
         "est_housing_size_2p"="estimate_S2501_C01_003","moe_housing_size_2p"="moe_S2501_C01_003",
         "est_housing_size_3p"="estimate_S2501_C01_004","moe_housing_size_3p"="moe_S2501_C01_004",
         "est_housing_size_4p"="estimate_S2501_C01_005","moe_housing_size_4p"="moe_S2501_C01_005")

#marital status data
marital_status_table <- "S1201"

marital_status_vars <- 
  load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( variable, marital_status_table) )

marital_status_data <- get_acs(geography = "tract", table = marital_status_table, state = "WA", geometry = F, cache_table = T) %>% 
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

acs5_vars <- load_variables(year = use_year, dataset = "acs5", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

num_earners_variables <- vector()

for( i in c(1:5) )
{
  num_earners_variables <- append(num_earners_variables, paste( num_earners_prefix, str_pad( i, 3, pad="0"), sep=""))
}

num_earners_data <- get_acs(geography = "tract", variables=num_earners_variables , state = "WA", geometry = F) %>% 
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
language_at_home_table <- "S1601"

acs5_vars <- load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") # rename variable code to be able to join

language_at_home_vars <- acs5_vars %>% 
  filter( str_detect( acs5_vars$variable, language_at_home_table))

language_at_home_data <- get_acs(geography = "tract", table = language_at_home_table, state = "WA", geometry = F, cache_table = TRUE) %>% 
  left_join( language_at_home_vars, by="variable")%>%
  select(-c(NAME,label,concept)) %>%
  filter(variable == "S1601_C01_001" | variable == "S1601_C01_002"| variable == "S1601_C01_003"| variable == "S1601_C01_004"|
           variable == "S1601_C01_008"|variable == "S1601_C01_012"|variable == "S1601_C01_016") %>%
  pivot_wider(names_from = variable, values_from = c(estimate,moe)) %>%
  rename("est_population_5+"="estimate_S1601_C01_001","moe_population_5+"="moe_S1601_C01_001",
         "est_english"="estimate_S1601_C01_002","moe_english"="moe_S1601_C01_002",
         "est_non_english"="estimate_S1601_C01_003","moe_non_english"="moe_S1601_C01_003",
         "est_spanish"="estimate_S1601_C01_004","moe_spanish"="moe_S1601_C01_004",
         "est_indoeuro_lang"="estimate_S1601_C01_008","moe_indoeuro_lang"="moe_S1601_C01_008",
         "est_aapi_lang"="estimate_S1601_C01_012","moe_aapi_lang"="moe_S1601_C01_012",
         "est_other_lang"="estimate_S1601_C01_016","moe_other_lang"="moe_S1601_C01_016")

#join tables
all_census_data <- left_join(all_census_data,language_at_home_data,by="GEOID")

# work status data
work_status_table <- "S2303"

work_status_vars <- 
  load_variables(year = use_year, dataset = "acs5/subject", cache = TRUE) %>% 
  rename("variable"="name") %>%  # rename variable code to be able to join
  filter( str_detect( variable, work_status_table) )

work_status_data <- get_acs(geography = "tract", table = work_status_table, state = "WA", geometry = F, cache_table = T ) %>% 
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

geography_data <-get_acs (geography = "tract", variables = "B19013_001", 
                     state = "WA", geometry = T, cache_table = T) %>% 
  select( "GEOID", "geometry")

all_census_data <- left_join(all_census_data, geography_data, by="GEOID")



