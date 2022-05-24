library(tidycensus)
library(tidyverse)
library(openintro)
library(corrplot)

#load race data from 'get_and_label_acs.R'
#note that race data is not yet in CSV ^ so use the function in the above file
race_data <- acs_dataset %>%
  select(GEOID,NAME,contains("B02001"))
race_spatial <- left_join(job_access_gap, race_data,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, contains("est"))%>%
  drop_na()

#hispanic not included?? should we pull in a separate var?

#totals are for one race only unless specified elsewhere
race_spatial$total = race_spatial$estimate_B02001_001
race_spatial$white = race_spatial$estimate_B02001_002 / race_spatial$estimate_B02001_001
race_spatial$black = race_spatial$estimate_B02001_003 / race_spatial$estimate_B02001_001
race_spatial$nativeamerican = race_spatial$estimate_B02001_004 / race_spatial$estimate_B02001_001 
race_spatial$asian = race_spatial$estimate_B02001_005 / race_spatial$estimate_B02001_001
race_spatial$pacificislander = race_spatial$estimate_B02001_006 / race_spatial$estimate_B02001_001
#other but not multiple races:
race_spatial$other = race_spatial$estimate_B02001_007 / race_spatial$estimate_B02001_001
#multiple races:
race_spatial$multiple = race_spatial$estimate_B02001_008 / race_spatial$estimate_B02001_001

#combine pacific islander & asian, move native to 'other'

race_spatial$aapi = race_spatial$asian + race_spatial$pacificislander
race_spatial$other = race_spatial$other + race_spatial$nativeamerican


# basic correlations
race_spatial <- race_spatial %>%
  select(spatialmismatch, white, black, aapi, multiple,other)
correlations <- cor(race_spatial, use = "complete.obs")


pairs(race_spatial[,(1:6)])
plot(spatialmismatch~aapi, data = race_spatial)
m1 <- lm(spatialmismatch~white, data = race_spatial)
summary(m1)


#correlogram

corrplot(correlations, order = "original", 
         tl.col = "black", tl.srt = 45)


#white vs nonwhite

white_spatial <- race_spatial
white_spatial$nonwhite = white_spatial$black + white_spatial$aapi + white_spatial$other + white_spatial$multiple
white_spatial <- white_spatial %>%
  select(spatialmismatch, white, nonwhite)
correlations_white <- cor(white_spatial, use = "complete.obs")
corrplot(correlations_white, order = "hclust", 
         tl.col = "black", tl.srt = 45)
