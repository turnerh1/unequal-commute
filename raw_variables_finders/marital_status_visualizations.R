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

# import marital_status_data by running file 'marital_status_all.R"

marital_status_data <- marital_status_data %>%
  rename("T_GEOID" = "GEOID")

# join to marital and job access data

marital_job_access<-left_join(marital_status_data,job_access_gap, by = "T_GEOID") 
marital_job_access$T_GEOID<-as.numeric(marital_job_access$T_GEOID)

# total now married not including separated
married_not_sep <- marital_job_access %>%
  filter(grepl("S1201_C02_001",variable))

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(0,25,50,75,100)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")


# plot of now married
ggplot(married_not_sep) +
  geom_sf(color="#C0C0C0",aes(fill = estimate), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  labs(title="Married in Seattle by Tract Group",
       subtitle = "15+ in age")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "estimate") 


# same thing but for widowed, divorced, separated, never married:
widowed <- marital_job_access %>%
  filter(grepl("S1201_C03_001",variable))
divorced <- marital_job_access %>%
  filter(grepl("S1201_C04_001",variable))
separated <- marital_job_access %>%
  filter(grepl("S1201_C05_001",variable))
nevermarried <- marital_job_access %>%
  filter(grepl("S1201_C06_001",variable))
population <- marital_job_access %>%
  filter(grepl("S1201_C01_001",variable))
