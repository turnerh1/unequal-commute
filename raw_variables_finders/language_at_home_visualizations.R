library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

# load job_access_gap, but leave out the geometries
job_access_gap <- read_csv("job_access_gap.csv", 
                           col_types = cols(geometry = col_skip()))
#convert job_access_gap data to have census tracts

job_access_gap <- job_access_gap %>%
  rename("BG_GEOID"="GEOID")
job_access_gap$BG_GEOID<-as.character(job_access_gap$BG_GEOID)

T_GEOID<-substr(job_access_gap$BG_GEOID,1,11)

job_access_gap <- cbind(job_access_gap,T_GEOID)

# import language at home by running file 'language_at_home_data.R"

language_at_home_data <- language_at_home_data %>%
  rename("T_GEOID" = "GEOID")

# join to earners and job access data

language_at_home_data <-left_join(language_at_home_data,job_access_gap, by = "T_GEOID") 
language_at_home_data$T_GEOID<-as.numeric(language_at_home_data$T_GEOID)

# total english_only, 5 years and over (can get more specific if needed)
english_only <- language_at_home_data %>%
  filter(grepl("S1601_C01_002",variable))


# same thing but for other languages:
spanish <- language_at_home_data %>%
  filter(grepl("S1601_C01_004",variable))
indo_european <- language_at_home_data %>%
  filter(grepl("S1601_C01_008",variable))
#asian and pacific islander 
aapi <- language_at_home_data %>%
  filter(grepl("S1601_C01_012",variable))
other_languages <- language_at_home_data %>%
  filter(grepl("S1601_C01_016",variable))

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(100,500,1000,2000)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")

spanish_seattle <- spanish %>%
  filter(grepl("Seattle",MSA))

# plot of spanish speaking at home
ggplot(spanish_seattle) +
  geom_sf(color="#C0C0C0",aes(fill = estimate), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  labs(title="Language Spoken At Home (Spanish) Estimate",
       subtitle = "Ages 5+")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "estimate") 
