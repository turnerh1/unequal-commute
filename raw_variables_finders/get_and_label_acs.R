library('plyr', include.only = 'join_all' )
library(dplyr)
# marital status (B12001) - count of people (15+ age) var: 'est_population_15+'
# language (B16004)- number of people who speak per group (5+ age) var: 'estimate_age5andolder'
# num of household earners (B19121) - number of earners per family var: 'est_num_families'
# household data/occupancy char. (B25009, B25014) - Tenure by household size and tenure by occupancy
# work status (B23022) - count of people (16+ age) var: 'est_population_16to64'


### this function needs acs5_vars to be defined
get_and_label_acs_data <- function( prefix, columns, search_geo="block group", get_sf=F )
{
  codes <- str_c( prefix, str_pad( c(1:columns), 3, pad="0" ), sep="_")
  metadata_table <- data.frame( "code" = codes )  %>% 
    left_join( acs5_vars, by=c("code" = "name") ) %>% 
    mutate( label = str_remove(label, "Estimate!!Total:") ) %>% 
    select( -"concept")
  
  data_table <- as.data.frame( get_acs(geography = search_geo, variables = metadata_table$code, state = "WA", geometry = get_sf) %>% 
    pivot_wider(names_from = variable, values_from = c(estimate,moe)) )
  
  # print( typeof( data_table ) )
  return( list( metadata_table, data_table ) )
}

fetch_year <- "2019"
acs5_vars <- load_variables(year = fetch_year, dataset = "acs5", cache = TRUE)


### Marital Status: B12001
marital_status <- get_and_label_acs_data( prefix="B12001", columns=19)
marital_status_metadata <- marital_status[[1]]
marital_status_data <- marital_status[[2]]

### Language at home: B16004
language_at_home <- get_and_label_acs_data( prefix="B16004", columns=67)
language_at_home_metadata <- language_at_home[[1]]
language_at_home_data <- language_at_home[[2]]

# Number of household earners is unavailable by block group
# ### Number of household earners: B19121
# num_earners <- get_and_label_acs_data( prefix="B19121", columns=5)
# num_earners_metadata <- num_earners[[1]]
# num_earners_data <- num_earners[[2]]

### Median household income B19013
household_income <- get_and_label_acs_data( prefix="B19013", columns=1)
household_income_metadata <- language_at_home[[1]]
household_income_data <- language_at_home[[2]]

### Tenure: B25009, B25014
tenure_by_household_size <- get_and_label_acs_data( prefix="B25009", columns=17)
tenure_by_occupants_per_room <- get_and_label_acs_data( prefix="B25014", columns=13)
tenure_metadata <- rbind( tenure_by_household_size[[1]], tenure_by_occupants_per_room[[1]] )
tenure_data <- full_join( tenure_by_household_size[[2]], tenure_by_occupants_per_room[[2]] )

### Work status: B23022
work_status <- get_and_label_acs_data( prefix="B23022", columns=49)
work_status_metadata <- work_status[[1]]
work_status_data <- work_status[[2]]

### Combine all tables
acs_dataframes <- list(marital_status_data, 
                       language_at_home_data, 
                       # num_earners_data, 
                       household_income_data,
                       tenure_data,
                       work_status_data)

all_acs_data <- join_all( acs_dataframes, by="GEOID", type="full" )
geography_data <-get_acs (geography = "block group", variables = "B19013_001", 
                          state = "WA", geometry = T, cache_table = T) %>% 
  select( "GEOID", "geometry")

all_acs_data <- left_join(all_acs_data, geography_data, by="GEOID")

