library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

#Correlation visualizations

job_access_gap <- read_csv("job_access_gap.csv")

sea_gap <- job_access_gap %>%
  filter(MSA == "Seattle")

#calculate how many are in 10% of data
quantity<-round(.1*dim(sea_gap)[1])

high<-sea_gap %>%
  arrange(desc(spatialmismatch))%>%
  head(quantity)

low<-sea_gap %>%
  arrange((spatialmismatch))%>%
  head(quantity)

#import big data CSV
library(readr)
#acs_dataset <- read_csv("acs_dataset.csv")

#grab data
occupancy_census <- all_acs_data %>%
  select(GEOID,NAME,contains("B25014"))
occupancy_census$GEOID <- as.numeric(occupancy_census$GEOID)

household_size_census <- all_acs_data %>%
  select(GEOID,NAME,contains("B25009"))
household_size_census$GEOID <- as.numeric(household_size_census$GEOID)

#clean and create new columns combining sex
occupancy_census$total_pop <- occupancy_census$estimate_B25014_002 + occupancy_census$estimate_B25014_008
occupancy_census$total_.5orless <- occupancy_census$estimate_B25014_003 + occupancy_census$estimate_B25014_009
occupancy_census$total_.51to1 <- occupancy_census$estimate_B25014_004 + occupancy_census$estimate_B25014_010
occupancy_census$total_1.01to1.5 <- occupancy_census$estimate_B25014_005 + occupancy_census$estimate_B25014_011
occupancy_census$total_1.51to2 <- occupancy_census$estimate_B25014_006 + occupancy_census$estimate_B25014_012
occupancy_census$total_2.01ormore <- occupancy_census$estimate_B25014_007 + occupancy_census$estimate_B25014_013

household_size_census$total_pop <- household_size_census$estimate_B25009_002 + household_size_census$estimate_B25009_010
household_size_census$size1 <- household_size_census$estimate_B25009_003 + household_size_census$estimate_B25009_011
household_size_census$size2 <- household_size_census$estimate_B25009_004 + household_size_census$estimate_B25009_012
household_size_census$size3 <- household_size_census$estimate_B25009_005 + household_size_census$estimate_B25009_013
household_size_census$size4 <- household_size_census$estimate_B25009_006 + household_size_census$estimate_B25009_014
household_size_census$size5 <- household_size_census$estimate_B25009_007 + household_size_census$estimate_B25009_015
household_size_census$size6 <- household_size_census$estimate_B25009_008 + household_size_census$estimate_B25009_016
household_size_census$size7more <- household_size_census$estimate_B25009_009 + household_size_census$estimate_B25009_017
  
  
# Join spatial mismatch data with tables
occupancy_high<-left_join(high,occupancy_census,by="GEOID")
occupancy_low<-left_join(low,occupancy_census,by="GEOID")

household_size_high <- left_join(high,household_size_census,by="GEOID")
household_size_low <- left_join(low,household_size_census,by="GEOID")

# Occupancy per room data
htotal_.5orless=sum(occupancy_high$total_.5orless)
htotal_.51to1=sum(occupancy_high$total_.51to1)
htotal_1.01to1.5=sum(occupancy_high$total_1.01to1.5)
htotal_1.51to2=sum(occupancy_high$total_1.51to2)
htotal_2.01ormore=sum(occupancy_high$total_2.01ormore)
htotal_pop=sum(occupancy_high$total_pop)

ltotal_.5orless=sum(occupancy_low$total_.5orless)
ltotal_.51to1=sum(occupancy_low$total_.51to1)
ltotal_1.01to1.5=sum(occupancy_low$total_1.01to1.5)
ltotal_1.51to2=sum(occupancy_low$total_1.51to2)
ltotal_2.01ormore=sum(occupancy_low$total_2.01ormore)
ltotal_pop=sum(occupancy_low$total_pop)

total_occup_high<-data.frame(occupancy = c(".5orless",".51to1","1.01to1.5","1.51to2","2.01ormore","Total"),
                             high_count = c(htotal_.5orless, htotal_.51to1, htotal_1.01to1.5, htotal_1.51to2, htotal_2.01ormore, htotal_pop))
total_occup_high$high_prop<- total_occup_high$high_count / total_occup_high$high_count[6]

total_occup_low<-data.frame(occupancy = c(".5orless",".51to1","1.01to1.5","1.51to2","2.01ormore","Total"),
                            low_count = c(ltotal_.5orless, ltotal_.51to1, ltotal_1.01to1.5, ltotal_1.51to2, ltotal_2.01ormore, ltotal_pop))
total_occup_low$low_prop<- total_low$low_count / total_low$low_count[6]

total_occup <- left_join(total_high,total_low, by = "occupancy")

# Household size data
htotal_size1=sum(household_size_high$size1)
htotal_size2=sum(household_size_high$size2)
htotal_size3=sum(household_size_high$size3)
htotal_size4=sum(household_size_high$size4)
htotal_size5=sum(household_size_high$size5)
htotal_size6=sum(household_size_high$size6)
htotal_size7more=sum(household_size_high$size7more)
htotal_size_pop=sum(household_size_high$total_pop)

ltotal_size1=sum(household_size_low$size1)
ltotal_size2=sum(household_size_low$size2)
ltotal_size3=sum(household_size_low$size3)
ltotal_size4=sum(household_size_low$size4)
ltotal_size5=sum(household_size_low$size5)
ltotal_size6=sum(household_size_low$size6)
ltotal_size7more=sum(household_size_low$size7more)
ltotal_size_pop=sum(household_size_low$total_pop)


total_size_high <- data.frame(size = c("1 person","2 person","3 person","4 person","5 person","6 person","7 or more person","Total"),
              high_count = c(htotal_size1, htotal_size2, htotal_size3, htotal_size4, htotal_size5, htotal_size6, htotal_size7more, htotal_size_pop))
total_size_high$high_prop<- total_size_high$high_count / total_size_high$high_count[8]

total_size_low <- data.frame(size = c("1 person","2 person","3 person","4 person","5 person","6 person","7 or more person","Total"),
              low_count = c(ltotal_size1, ltotal_size2, ltotal_size3, ltotal_size4, ltotal_size5, ltotal_size6, ltotal_size7more, ltotal_size_pop))
total_size_low$low_prop <- total_size_low$low_count / total_size_low$low_count[8]

total_household_size <- left_join(total_size_high,total_size_low, by = "size")


#fun colors:
# https://r-graph-gallery.com/38-rcolorbrewers-palettes.html

#Plot graphs
total_occup %>%
  pivot_longer(cols = c(low_prop,high_prop), names_to = "prop_type", values_to = "prop") %>%
  filter(occupancy != "Total") %>%
  ggplot(aes(x=occupancy,y=prop,fill=prop_type))+
  geom_col(position = position_dodge(), stat = "identity") +
  xlab("Occupancy Level") + 
  ylab("Proportion of Households")+
  labs(title= "Occupancy Proportions for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'))

total_household_size %>%
  pivot_longer(cols = c(low_prop,high_prop), names_to = "prop_type", values_to = "prop") %>%
  filter(size != "Total") %>%
  ggplot(aes(x=size,y=prop,fill=prop_type))+
  geom_col(position = position_dodge(), stat = "identity") +
  xlab("Household Size") + 
  ylab("Proportion of Households")+
  labs(title= "Household Size Proportions for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'))



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
