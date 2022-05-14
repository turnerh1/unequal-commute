library(dplyr)
library(openintro)

edu_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B15003"))

#using education by for 25+ age
edu_census <- edu_census %>%
  select(c(GEOID, NAME, 
           estimate_B15003_001, #total
           estimate_B15003_002, #no education
           estimate_B15003_016, #12th grade no diploma
           estimate_B15003_017, #high school diploma
           estimate_B15003_018, #GED
           estimate_B15003_019, #some college, <1 year
           estimate_B15003_020, #some college >1 year, no degree
           estimate_B15003_021, #associate degree,
           estimate_B15003_022, #bachelor degree
           estimate_B15003_023, #master degree
           estimate_B15003_024, #professional school degree
           estimate_B15003_025)) #doctoral degree

#some college, <1 year AND  #some college >1 year, no degree
edu_census$somecollege = edu_census$estimate_B15003_019 +
  edu_census$estimate_B15003_020 

# associate, bachelor, master, professional school, doctorate
edu_census$higher_ed = edu_census$estimate_B15003_021 + 
  edu_census$estimate_B15003_022 + 
  edu_census$estimate_B15003_023 + 
  edu_census$estimate_B15003_024 + 
  edu_census$estimate_B15003_025

# master, professional, doctorate
edu_census$post_grad = edu_census$estimate_B15003_023 + 
  edu_census$estimate_B15003_024 + 
  edu_census$estimate_B15003_025

edu_spatial <- left_join(job_access_gap, edu_census,by = "GEOID")%>%
  select(7,22:24)

cor(edu_spatial[,(1:4)])

pairs(edu_spatial[,(1:4)])
plot(spatialmismatch~somecollege, data = edu_spatial)
m1 <- lm(spatialmismatch~somecollege, data = edu_spatial)
summary(m1)
