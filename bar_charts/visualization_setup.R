library(tidycensus)
library(tidyverse)
library(readr)

## run this file before trying to create visualizations

job_access_gap <- read_csv("./data/job_access_gap.csv")

sea_gap <- job_access_gap %>%
  filter(MSA == "Seattle")

#calculate how many are in 10% of data
ten_pct_quantity<-round(.1*dim(sea_gap)[1])

high<-sea_gap %>%
  arrange(desc(spatialmismatch))%>%
  head(ten_pct_quantity)

low<-sea_gap %>%
  arrange((spatialmismatch))%>%
  head(ten_pct_quantity)

#import big data CSV
acs_dataset <- read_csv("./data/acs_dataset.csv")

high_tenpct <- left_join(high,acs_dataset,by="GEOID")
low_tenpct <- left_join(low,acs_dataset,by="GEOID")
