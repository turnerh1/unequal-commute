library(tidyverse)
library(readr)
job_access_gap <- read_csv("data/job_access_gap.csv")
acs_dataset <- read_csv("data/acs_dataset.csv")
english_speaking_ability <- read_csv("data/english_speaking_ability.csv")

model_data <- left_join(job_access_gap,acs_dataset, by = "GEOID") %>%
  filter(MSA == "Seattle")
# language, median income, education stuff, racial identity, population

#languages
model_data$spanish = (model_data$estimate_B16004_004 + model_data$estimate_B16004_026 + model_data$estimate_B16004_048) / model_data$estimate_B16004_001

#income
model_data$median_household_income <-model_data$estimate_B19013_001

#education
#below_bach = associates degree or less
#above_bach = bachelor's degree or higher
model_data$below_bach <- (model_data$estimate_B15003_002 + model_data$estimate_B15003_016 + model_data$estimate_B15003_017 + 
  model_data$estimate_B15003_018 + model_data$estimate_B15003_019 + model_data$estimate_B15003_020 +
  model_data$estimate_B15003_021) / model_data$estimate_B15003_001
model_data$above_bach <- (model_data$estimate_B15003_022 + model_data$estimate_B15003_023 + model_data$estimate_B15003_024 +
  model_data$estimate_B15003_025) / model_data$estimate_B15003_001

#racial identity
#totals are for one race only unless specified elsewhere
model_data$total = model_data$estimate_B02001_001
model_data$white = model_data$estimate_B02001_002 / model_data$estimate_B02001_001
model_data$black = model_data$estimate_B02001_003 / model_data$estimate_B02001_001
model_data$nativeamerican = model_data$estimate_B02001_004 / model_data$estimate_B02001_001 
model_data$asian = model_data$estimate_B02001_005 / model_data$estimate_B02001_001
model_data$pacificislander = model_data$estimate_B02001_006 / model_data$estimate_B02001_001
#other but not multiple races:
model_data$other = model_data$estimate_B02001_007 / model_data$estimate_B02001_001
#multiple races:
model_data$multiple = model_data$estimate_B02001_008 / model_data$estimate_B02001_001
#combine pacific islander & asian, move native to 'other'

model_data$aapi = model_data$asian + model_data$pacificislander
model_data$other = model_data$other + model_data$nativeamerican
#total nonwhite
model_data$nonwhite = model_data$black + model_data$aapi + model_data$other + model_data$multiple


#select only necessary variables
model_data <- model_data %>%
  select(GEOID, spatialmismatch, spanish, median_household_income, below_bach, above_bach, white, nonwhite)

#english_well vs english not well
english_speaking_ability <- english_speaking_ability %>% select( GEOID, english_better)
model_data <- left_join( model_data, english_speaking_ability, by="GEOID" )

#pull in population
pop_density <- read_csv("data/land_area/pop_density.csv")
model_data <- left_join(model_data, pop_density, by = "GEOID") %>%
  select(GEOID, spatialmismatch, spanish, median_household_income, below_bach, above_bach, white, nonwhite, people_per_sqmi, english_better)

