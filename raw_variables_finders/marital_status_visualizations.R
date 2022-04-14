library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load job_access_gap, but leave out the geometries
job_access_gap <- read_csv("job_access_gap.csv", 
                           col_types = cols(geometry = col_skip()))

get_variables = c("B12001_001","B12001_002","B12001_003","B12001_004","B12001_005","B12001_006","B12001_007","B12001_008","B12001_009","B12001_010","B12001_011","B12001_012","B12001_013","B12001_014","B12001_015","B12001_016","B12001_017","B12001_018","B12001_019")

marital_census <- get_acs(geography = "block group", variables = get_variables, state = "WA", geometry = T)

marital_census <- marital_census%>%
  mutate(GEOID = as.numeric(GEOID)) 

# import variables_2019 
variables_2019 <- read_csv("variables_2019.csv")

# rename variable code to be able to join
variables_2019<-rename(variables_2019,"variable"="name")

# join to get variable names for census code
marital_variables<-left_join(marital_census,variables_2019,by="variable") %>%
  select(-"...1")


marital_status<-left_join(marital_variables,job_access_gap,by="GEOID")

#need to do filter into specific marraige types before able to plot
never_married_male <- marital_status %>%
  filter(grepl("Estimate!!Total:!!Male:!!Never married",label))


# plot of never married males in sea
ggplot(never_married_male) +
  geom_sf(color="#C0C0C0",aes(fill = estimate), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  labs(title="Spatial Mismatch By Census Block Group",
       subtitle = "Seattle, WA and Surrounding Areas")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Normalized\nSpatial\nMismatch") 
