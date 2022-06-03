library(tidycensus)
library(tidyverse)
library(openintro)
library(corrplot)
library(readr)

# get job access and acs data 
job_access_gap <- read_csv("data/job_access_gap.csv")
acs_dataset <- read_csv("data/acs_dataset.csv")
#load acs_dataset
household_income_data <- acs_dataset %>%
  select(GEOID,NAME,contains("B19013"))
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
         tl.col = "black", tl.srt = 90)

