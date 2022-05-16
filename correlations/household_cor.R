library(dplyr)
library(openintro)
library(corrplot)
#population - num of households
#could calculate prop of renter & owner occupied

#import census data
household_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B25009"))

#combine categories
household_census$total_pop <- household_census$estimate_B25009_002 + household_census$estimate_B25009_010
household_census$size1 <- (household_census$estimate_B25009_003 + household_census$estimate_B25009_011) / household_census$total_pop
household_census$size2 <- (household_census$estimate_B25009_004 + household_census$estimate_B25009_012) / household_census$total_pop
household_census$size3 <- (household_census$estimate_B25009_005 + household_census$estimate_B25009_013) / household_census$total_pop
household_census$size4 <- (household_census$estimate_B25009_006 + household_census$estimate_B25009_014) / household_census$total_pop
household_census$size5 <- (household_census$estimate_B25009_007 + household_census$estimate_B25009_015) / household_census$total_pop
household_census$size6 <- (household_census$estimate_B25009_008 + household_census$estimate_B25009_016) / household_census$total_pop 
household_census$size7more <- (household_census$estimate_B25009_009 + household_census$estimate_B25009_017)/ household_census$total_pop

#import job access data
household_spatial <- left_join(job_access_gap, household_census,by = "GEOID")%>%
  select(spatialmismatch, total_pop, contains("size"))
cor(household_spatial[,(1:9)])

pairs(household_spatial[,(1:9)])
plot(spatialmismatch~size5, data = household_spatial)
#m1 <- lm(spatialmismatch~size5, data = household_spatial)
#summary(m1)

#next steps: get average household size?
