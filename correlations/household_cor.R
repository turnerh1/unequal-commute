library(dplyr)
library(openintro)
library(corrplot)
library(tidyverse)
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
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, total_pop, contains("size"))

cor(household_spatial[,(1:9)])

pairs(household_spatial[,(1:9)])
plot(spatialmismatch~size5, data = household_spatial)
#m1 <- lm(spatialmismatch~size5, data = household_spatial)
#summary(m1)


#combine proportions
household_census$size1or2 = household_census$size1 + household_census$size2
household_census$size3or4 = household_census$size3 + household_census$size4
household_census$size5more = household_census$size5 + household_census$size6 + household_census$size7more
household_census <- household_census %>%
  select(-c("size1", "size2", "size3", "size4","size5", "size6", "size7more"))
household_spatial <- left_join(job_access_gap, household_census,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, contains("size")) %>%
  drop_na()

#corellogram

cor(household_spatial[,(1:4)])

pairs(household_spatial[,(1:4)])
plot(spatialmismatch~size1or2, data = household_spatial)
plot(spatialmismatch~size3or4, data = household_spatial)
plot(spatialmismatch~size5more, data = household_spatial)

correlations <- cor(household_spatial, use = "complete.obs")

#  Positive correlations are displayed in blue and negative correlations in red color. 
# Color intensity and the size of the circle are proportional to the correlation coefficients. 
# In the right side of the correlogram, the legend color shows the correlation 
# coefficients and the corresponding colors.
corrplot(correlations, order = "hclust", 
         tl.col = "black", tl.srt = 45)


