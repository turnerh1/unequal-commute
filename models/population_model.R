library(readr)
library(tidyverse)

acs_dataset <- read_csv("acs_dataset.csv")
pop_density <- read_csv("land_area/pop_density.csv")
job_access_gap <- read_csv("job_access_gap.csv")

#create proportions on acs_dataset
acs_dataset
#select which variables you want to model (proportion vars, and GEOID):
var_data <- acs_dataset %>%
  select(GEOID,#[insert vars here])
         
#join
model_data<-left_join(var_data,job_access_gap,by=GEOID) %>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, #[insertvars here])%>%
  drop_na()
  
model_data <-left_join(model_data, pop_density, by=GEOID)