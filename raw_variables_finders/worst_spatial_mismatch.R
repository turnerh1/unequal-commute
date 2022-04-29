library(tidyverse)

sea_gap <- job_access_gap %>%
  filter(MSA == "Seattle")
#join table


lower<-summary(sea_gap$spatialmismatch)[2]
higher<-summary(sea_gap$spatialmismatch)[5]

low_sea_gap <- sea_gap %>%
  filter(spatialmismatch <= lower)

high_sea_gap <- sea_gap %>%
  filter(spatialmismatch >= higher)
#table ideas