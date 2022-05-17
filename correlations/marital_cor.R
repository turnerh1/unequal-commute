library(dplyr)
library(openintro)
library(corrplot)
library(tidyverse)
#marital population is 15+ in age
marital_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B12001"))

marital_census$total = marital_census$estimate_B12001_001
marital_census$nevermarried = (marital_census$estimate_B12001_003 + marital_census$estimate_B12001_012) / marital_census$estimate_B12001_001 
marital_census$marriednow = (marital_census$estimate_B12001_004+marital_census$estimate_B12001_013) / marital_census$estimate_B12001_001
marital_census$separated = (marital_census$estimate_B12001_005+marital_census$estimate_B12001_014 + marital_census$estimate_B12001_006+marital_census$estimate_B12001_015 +
                              marital_census$estimate_B12001_007+marital_census$estimate_B12001_016 + marital_census$estimate_B12001_008+marital_census$estimate_B12001_017) / marital_census$estimate_B12001_001
marital_census$widowed = (marital_census$estimate_B12001_009+marital_census$estimate_B12001_018) / marital_census$estimate_B12001_001
marital_census$divorced = (marital_census$estimate_B12001_010+marital_census$estimate_B12001_019) / marital_census$estimate_B12001_001

#import job access data
marital_spatial <- left_join(job_access_gap, marital_census,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, total, nevermarried, marriednow, separated, widowed, divorced)%>%
  drop_na()

#correlation scatterplots 
cor(marital_spatial[,(1:7)])

pairs(marital_spatial[,(1:7)])
plot(spatialmismatch~marriednow, data = marital_spatial)
m1 <- lm(spatialmismatch~marriednow, data = marital_spatial)
summary(m1)


#correlogram
correlations <- cor(marital_spatial, use = "complete.obs")

#  Positive correlations are displayed in blue and negative correlations in red color. 
# Color intensity and the size of the circle are proportional to the correlation coefficients. 
# In the right side of the correlogram, the legend color shows the correlation 
# coefficients and the corresponding colors.
corrplot(correlations, order = "hclust", 
         tl.col = "black", tl.srt = 45)
