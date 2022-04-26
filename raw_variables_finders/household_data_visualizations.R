library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

# # load job_access_gap, but leave out the geometries
# job_access_gap <- read_csv("job_access_gap.csv",
#                            col_types = cols(geometry = col_skip()))
# 
# #convert job_access_gap data to have census tracts
# 
# job_access_gap <- job_access_gap %>%
#   rename("BG_GEOID"="GEOID")
# job_access_gap$BG_GEOID<-as.character(job_access_gap$BG_GEOID)
# 
# T_GEOID<-substr(job_access_gap$BG_GEOID,1,11)
# 
# job_access_gap <- cbind(job_access_gap,T_GEOID)
# 
# # import household size data by running file 'household_data.R"
# 
  household_size_data <- household_size_data %>%
    rename("T_GEOID" = "GEOID")

  household_geometry <- household_geometry %>%
    rename("T_GEOID" = "GEOID")
# 

household_size_data <-
  separate(household_size_data, col = NAME, into = c("Tract","County","State"), sep = ", ")

household_size_data$County <- str_remove_all(household_size_data$County," County")

household_size_data$est_housing_size_1lessoccup_prop <- household_size_data$est_housing_size_1lessoccup/household_size_data$est_housing_units_total
household_size_data$est_housing_size_1.5lessoccup_prop <- household_size_data$est_housing_size_1.5lessoccup/household_size_data$est_housing_units_total
household_size_data$est_housing_size_1.51moreoccup_prop <- household_size_data$est_housing_size_1.51moreoccup/household_size_data$est_housing_units_total

#Joining household and geometry
household_size <-right_join(household_geometry, household_size_data, by = "T_GEOID")

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(10,20,30,40,50)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")


# plot of occupants_per_room_1.51_more in King County

household_size %>%
  # filter(County == "King County") %>%
ggplot() +
  geom_sf(aes(fill = est_housing_size_1.5lessoccup_prop, geometry = geometry))

household_size %>%
ggplot() +
  geom_sf(aes(fill = est_housing_size_1.5lessoccup_prop, geometry = geometry), size=0.00001) +
  labs(title="Household Size by Tract Group",
       subtitle = "1.01 to 1.50 Occupants per Room")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Percentage of Occupied Housing")
