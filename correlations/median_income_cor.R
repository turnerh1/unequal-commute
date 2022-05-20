library('plyr', include.only = 'join_all' )
library(dplyr)
library(stringr)
library(tidycensus)
library(tidyr)
library(openintro)
library(corrplot)
#load acs data

############################################################
#income is not in the csv, so run code from get_and_label_acs.R

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

### Median household income B19013
household_income <- get_and_label_acs_data( prefix="B19013", columns=1)
household_income_metadata <- household_income[[1]]
household_income_data <- household_income[[2]]
household_income_data$GEOID = as.numeric(household_income_data$GEOID)

#############################################################
income_spatial <- left_join(job_access_gap, household_income_data,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, estimate_B19013_001)%>%
  drop_na()
income_spatial$median_household_income <-income_spatial$estimate_B19013_001
income_spatial<-income_spatial %>%
  select(spatialmismatch, median_household_income)

# basic correlations
correlations <- cor(income_spatial, use = "complete.obs")


pairs(income_spatial[,(1:2)])
plot(spatialmismatch~median_household_income, data = income_spatial)
m1 <- lm(spatialmismatch~median_household_income, data = income_spatial)
summary(m1)


#correlogram

corrplot(correlations, order = "hclust", 
         tl.col = "black", tl.srt = 45)
