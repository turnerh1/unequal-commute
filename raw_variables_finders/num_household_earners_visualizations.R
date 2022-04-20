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

# import num_earners_data by running file 'num_household_earners.R"

num_earners_data <- num_earners_data %>%
  rename("T_GEOID" = "GEOID")

# join to earners and job access data

num_earners_data <-left_join(num_earners_data,job_access_gap, by = "T_GEOID") 
num_earners_data$T_GEOID<-as.numeric(num_earners_data$T_GEOID)

# total no earners
no_earners <- num_earners_data %>%
  filter(grepl("B19121_002",variable))

# same thing but for one earner, two earners, three or more earners:
single_earner <- num_earners_data %>%
  filter(grepl("B19121_003",variable))
dual_earner <- num_earners_data %>%
  filter(grepl("B19121_004",variable))
three_earner <- num_earners_data %>%
  filter(grepl("B19121_005",variable))
population <- num_earners_data %>%
  filter(grepl("B19121_001",variable))
# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(0,25,50,75,100)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")


# plot of single earner
three_earner %>%
filter(!is.na(spatialmismatch)) %>%
ggplot() +
  geom_sf(color="#C0C0C0",aes(fill = estimate), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  # labs(title="Median Family Income in Seattle by Tract Group",
  #      subtitle = "For single earner households")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "estimate")
