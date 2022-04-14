library(tidycensus)
library(tidyverse)

get_variables = c("B12001_001","B12001_002","B12001_003","B12001_004","B12001_005","B12001_006","B12001_007","B12001_008","B12001_009","B12001_010","B12001_011","B12001_012","B12001_013","B12001_014","B12001_015","B12001_016","B12001_017","B12001_018","B12001_019")

marital_census <- get_acs(geography = "block group", variables = get_variables, state = "WA", geometry = T)

# import variables_2019 
variables_2019 <- read_csv("College/2021-22/Spring/Data & Society/unequal-commute/data/variables_2019.csv")

# rename variable code to be able to join
variables_2019<-rename(variables_2019,"variable"="name")

# join to get variable names for census code
marital_variables<-left_join(marital_census,variables_2019,by="variable") %>%
  select(-"...1")

# convert GEOID to numeric
marital_variables <- marital_variables %>%
  mutate(GEOID = as.numeric(GEOID))%>%
  filter(GEOID %in% job_access_gap$GEOID)

job_access_gap <- read_csv("College/2021-22/Spring/Data & Society/unequal-commute/data/job_access_gap.csv")

marital_status<-left_join(job_access_gap,marital_variables,by="GEOID")
