library(tidycensus)
library(tidyverse)

job_access_gap <- read_csv("job_access_gap.csv")

sea_gap <- job_access_gap %>%
  filter(MSA == "Seattle")
#join table

#calculate how many are in 10% of data
quantity<-round(.1*dim(sea_gap)[1])

high<-sea_gap %>%
  arrange(desc(spatialmismatch))%>%
  head(quantity)

low<-sea_gap %>%
  arrange((spatialmismatch))%>%
  head(quantity)

#import big data CSV
library(readr)
acs_dataset <- read_csv("acs_dataset.csv")
View(acs_dataset)

#select the columns you want



