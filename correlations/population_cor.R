library(tidycensus)
library(tidyverse)
library(openintro)
library(corrplot)

pop_density <- read_csv("land_area/pop_density.csv")
job_access_gap <- read_csv("job_access_gap.csv")
pop_spatial <- left_join(job_access_gap, pop_density,by = "GEOID")%>%
  filter(MSA=="Seattle") %>%
  select(spatialmismatch, people_per_sqmi)%>%
  drop_na()
correlations <- cor(pop_spatial, use = "complete.obs")
corrplot(correlations, order = "original", 
         tl.col = "black", tl.srt = 45)
m1 <- lm(spatialmismatch~people_per_sqmi, data = pop_spatial)
summary(m1)
plot(spatialmismatch~people_per_sqmi, data = pop_spatial)
