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

# import work status data by running file 'work_status_data.R"

work_status_data <- work_status_data %>%
  rename("T_GEOID" = "GEOID")

# household size and job access data

work_status_jobaccess <-left_join(work_status_data,job_access_gap, by = "T_GEOID") 
work_status_jobaccess$T_GEOID<-as.numeric(as.character(work_status_jobaccess$T_GEOID))

work_status_jobaccess <-
  separate(work_status_jobaccess, col = NAME, into = c("Tract","County","State"), sep = ", ")

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mycutpoints <- c(20,30,40,50,60,70,80)
mylabels <- c("20-30 hours worked","30-40 hours worked","40-50 hours worked",
              "50-60 hours worked","60-70 hours worked","70-80 hours worked")
mycolors <- c('#fee5d9','#fcbba1','#fc9272','#fb6a4a','#ef3b2c','#cb181d','#99000d')

#Population estimates from 16-64
population_work_status <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_001",variable))

#Mean hours worked (consider also looking at gender)
mean_hours_worked <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_031",variable)) %>%
  mutate(mean_hours = cut(estimate, breaks = mycutpoints, label = mylabels))

mean_hours_worked$County <- str_remove_all(mean_hours_worked$County," County")

#Usual hours worked
not_worked <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_030",variable))
hours_1to14_worked <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_023",variable))
hours_15to34_worked <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_016",variable))
hours_35_or_more_worked <- work_status_jobaccess %>%
  filter(grepl("S2303_C01_009",variable))

# plot mean hours worked

ggplot(data = mean_hours_worked) +
  geom_sf(aes(fill = mean_hours), size=0.00001) +
  scale_fill_manual("Hours worked per week", values = mycolors)+
labs(title="Mean Hours worked by Tract Group")+
theme(plot.title = element_text(hjust = 0.5, size=15)) +
theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
labs(fill = "estimate")+
   theme(panel.background = element_blank(),
         axis.text = element_blank(),
         axis.ticks = element_blank(),
         axis.title = element_blank())

mean_hours_worked %>%
  filter(County == "Whatcom"|County == "Skagit"|County == "Snohomish"|County == "King"|
           County == "Pierce"|County == "Kitsap") %>%
  ggplot() +
  geom_sf(aes(fill = mean_hours), size=0.00001) +
  scale_fill_manual("Hours worked per week", values = mycolors)+
  labs(title="Mean Hours worked by Tract Group")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "estimate")+
  theme(panel.background = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_blank())
