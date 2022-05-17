library(dplyr)
library(openintro)
library(corrplot)
#load acs data

language_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B16004"))

language_census$population = language_census$estimate_B16004_002 + language_census$estimate_B16004_024 + language_census$estimate_B16004_046
language_census$english = (language_census$estimate_B16004_003 + language_census$estimate_B16004_025 + language_census$estimate_B16004_047) / language_census$population
language_census$spanish = (language_census$estimate_B16004_004 + language_census$estimate_B16004_026 + language_census$estimate_B16004_048) / language_census$population
language_census$indo_european = (language_census$estimate_B16004_009 + language_census$estimate_B16004_031 + language_census$estimate_B16004_053) / language_census$population
language_census$aapi = (language_census$estimate_B16004_014 + language_census$estimate_B16004_036 + language_census$estimate_B16004_058) / language_census$population
language_census$other = (language_census$estimate_B16004_019 + language_census$estimate_B16004_041 + language_census$estimate_B16004_063) / language_census$population

# basic correlations

language_spatial <- left_join(job_access_gap, language_census,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, population, english, spanish, indo_european, aapi, other)%>%
  drop_na()
#correlation scatterplots 
# basic correlations
correlations <- cor(language_spatial, use = "complete.obs")


pairs(language_spatial[,(1:7)])
plot(spatialmismatch~spanish, data = language_spatial)
m1 <- lm(spatialmismatch~aapi, data = language_spatial)
summary(m1)


#correlogram

#  Positive correlations are displayed in blue and negative correlations in red color. 
# Color intensity and the size of the circle are proportional to the correlation coefficients. 
# In the right side of the correlogram, the legend color shows the correlation 
# coefficients and the corresponding colors.
corrplot(correlations, order = "hclust", 
         tl.col = "black", tl.srt = 45)
