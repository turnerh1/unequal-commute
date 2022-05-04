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
acs_dataset <- read_csv("acs_dataset.csv")
work_status_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B23022"))

work_status_census$GEOID <- as.numeric(work_status_census$GEOID)

#join with work status data
work_status_high<-left_join(high,work_status_census,by="GEOID")

work_status_low<-left_join(low,work_status_census,by="GEOID")

#clean and create new columns combining sex
work_status_census$total_pop <- work_status_data$estimate_B23022_002 + work_status_data$estimate_B23022_026
work_status_census$total_worked <- work_status_data$estimate_B23022_003 + work_status_data$estimate_B23022_027
work_status_census$total_35more <- work_status_data$estimate_B23022_004 + work_status_data$estimate_B23022_028
work_status_census$total_15to34 <- work_status_data$estimate_B23022_011 + work_status_data$estimate_B23022_035
work_status_census$total_1to14 <- work_status_data$estimate_B23022_018 + work_status_data$estimate_B23022_042
work_status_census$total_notworked <- work_status_data$estimate_B23022_025 + work_status_data$estimate_B23022_049

htotal_1to14=sum(work_status_high$total_1to14)
htotal_15to34=sum(work_status_high$total_15to34)
htotal_35more=sum(work_status_high$total_35more)
htotal_worked=sum(work_status_high$total_worked)
htotal_notworked=sum(work_status_high$total_notworked)
htotal_pop=sum(work_status_high$total_pop)

ltotal_1to14=sum(work_status_low$total_1to14)
ltotal_15to34=sum(work_status_low$total_15to34)
ltotal_35more=sum(work_status_low$total_35more)
ltotal_worked=sum(work_status_low$total_worked)
ltotal_notworked=sum(work_status_low$total_notworked)
ltotal_pop=sum(work_status_low$total_pop)


totals_high<-data.frame(work_status = c("1to14_hours","15to35_hours","35more_hours","Worked","Not_Worked","Total"),
                        high_count = c(htotal_1to14, htotal_15to34, htotal_35more, htotal_worked, htotal_notworked, htotal_pop))
totals_high$high_prop<- totals_high$high_count / totals_high$high_count[6]

totals_low<-data.frame(work_status = c("1to14_hours","15to35_hours","35more_hours","Worked","Not_Worked","Total"),
                       low_count = c(ltotal_1to14, ltotal_15to34, ltotal_35more, ltotal_worked, ltotal_notworked, ltotal_pop))
totals_low$low_prop<- totals_low$low_count / totals_low$low_count[6]

totals <- left_join(totals_high,totals_low, by = "work_status")


#fun colors:
# https://r-graph-gallery.com/38-rcolorbrewers-palettes.html

totals_high %>%
  filter(work_status!= "Worked" & work_status != "Total") %>%
  ggplot()+
  geom_col(aes(x=work_status,y=prop,fill=work_status)) +
  xlab("Work Status") + 
  ylab("Proportion of Population (ages 16-64)")+
  labs(title= "Work Status Proportions for Highest 10%\n(Worst) Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        legend.position = "none")+
  scale_fill_brewer(palette = "Set3")


totals_low %>%
  filter(work_status!= "Worked" & work_status != "Total") %>%
  ggplot()+
  geom_col(aes(x=work_status,y=prop,fill=work_status)) +
  xlab("Work Status") + 
  ylab("Proportion of Population (ages 16-64)")+
  labs(title= "Work Status Proportions for Lowest 10%\n(Best) Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        legend.position = "none")+
  scale_fill_brewer(palette = "Set3")

totals %>%
  pivot_longer(cols = c(low_prop,high_prop), names_to = "prop_type", values_to = "prop") %>%
  filter(work_status!= "Worked" & work_status != "Total") %>%
  ggplot(aes(x=work_status,y=prop,fill=prop_type))+
  geom_col(position = position_dodge()) +
  xlab("Work Status") + 
  ylab("Proportion of Population (ages 16-64)")+
  labs(title= "Work Status Proportions for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'))








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
