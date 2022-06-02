library(dplyr)
library(openintro)
library(corrplot)
library(tidyverse)
library(readr)

# get job access and acs data 
job_access_gap <- read_csv("data/job_access_gap.csv")
acs_dataset <- read_csv("data/acs_dataset.csv")



work_status_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B23022"))


#clean and create new columns combining sex
work_status_census$total_pop <- work_status_census$estimate_B23022_002 + work_status_census$estimate_B23022_026
work_status_census$total_worked <- work_status_census$estimate_B23022_003 + work_status_census$estimate_B23022_027
work_status_census$total_35more <- work_status_census$estimate_B23022_004 + work_status_census$estimate_B23022_028
work_status_census$total_15to34 <- work_status_census$estimate_B23022_011 + work_status_census$estimate_B23022_035
work_status_census$total_1to14 <- work_status_census$estimate_B23022_018 + work_status_census$estimate_B23022_042
work_status_census$total_notworked <- work_status_census$estimate_B23022_025 + work_status_census$estimate_B23022_049

work_spatial <- left_join(job_access_gap, work_status_census,by = "GEOID")%>%
  select(spatialmismatch,total_pop,total_worked,total_notworked,total_1to14,total_15to34,total_35more)

#create proportions

work_spatial$prop_worked <- work_spatial$total_worked/work_spatial$total_pop
work_spatial$prop_not_worked <- work_spatial$total_notworked/work_spatial$total_pop
work_spatial$prop_1to14 <- work_spatial$total_1to14/work_spatial$total_pop
work_spatial$prop_15to34 <- work_spatial$total_15to34/work_spatial$total_pop
work_spatial$prop_35more <- work_spatial$total_35more/work_spatial$total_pop

work_spatial_prop <- work_spatial %>%
  select(spatialmismatch,prop_worked,prop_not_worked,prop_1to14,prop_15to34,prop_35more)


#plotting all categories vs only upper
m.all <- lm(spatialmismatch~prop_worked + prop_not_worked+ prop_1to14 + prop_15to34 + prop_35more, data = work_spatial_prop)
m.all <- lm(spatialmismatch~prop_1to14 + prop_15to34 + prop_35more, data = work_spatial_prop)
m.higher_edu <- lm(spatialmismatch~prop_BS+prop_MD+prop_pro+prop_PhD, data = edu_spatial)

summary(m.all)
summary(m.higher_edu)
anova(m.all, m.higher_edu)

# basic correlations
work_correlation = cor(work_spatial_prop[,(1:6)], use = "complete.obs")

#  Positive correlations are displayed in blue and negative correlations in red color. 
# Color intensity and the size of the circle are proportional to the correlation coefficients. 
# In the right side of the correlogram, the legend color shows the correlation 
# coefficients and the corresponding colors.
corrplot(work_correlation, order = "hclust", 
         tl.col = "black", tl.srt = 45)

pairs(work_spatial_prop[,(1:6)])

