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

# import num_earners_data by running file 'household_data.R"

household_size_data <- household_size_data %>%
  rename("T_GEOID" = "GEOID")

# join to earners and job access data

household_jobaccess <-left_join(household_size_data,job_access_gap, by = "T_GEOID") 
household_jobaccess$T_GEOID<-as.numeric(as.character(household_jobaccess$T_GEOID))

household_jobaccess <-
  separate(household_jobaccess, col = NAME, into = c("Tract","County","State"), sep = ", ")

# # total no earners
# no_earners <- num_earners_data %>%
#   filter(grepl("B19121_002",variable))

# same thing but for one earner, two earners, three or more earners:
single_person_household <- household_jobaccess %>%
  filter(grepl("S2501_C01_002",variable))
two_person_household <- household_jobaccess %>%
  filter(grepl("S2501_C01_003",variable))
three_person_household <- household_jobaccess %>%
  filter(grepl("S2501_C01_004",variable))
four_person_household <- household_jobaccess %>%
  filter(grepl("S2501_C01_005",variable))
occupants_per_room_1_or_less <- household_jobaccess %>%
  filter(grepl("S2501_C01_006",variable))
occupants_per_room_1.01_1.50 <- household_jobaccess %>%
  filter(grepl("S2501_C01_007",variable))
occupants_per_room_1.51_more <- household_jobaccess %>%
  filter(grepl("S2501_C01_008",variable))

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

occupants_per_room_1.51_more %>%
  filter(County == "King County") %>%
ggplot() +
  geom_sf(aes(fill = estimate))

ggplot(data = household_jobaccess) +
  geom_sf(aes(fill = estimate), size=0.00001)

  # scale_fill_gradientn(colors=my_colors,
  #                      na.value = "transparent",
  #                      breaks=mybreaks,
  #                      labels = mybreaks)+
  # labs(title="Household Size by Tract Group",
  #      subtitle = "")+
  # theme(plot.title = element_text(hjust = 0.5, size=15)) +
  # theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  # labs(fill = "estimate") 
