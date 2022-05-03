library(tidycensus)
library(tidyverse)
options(tigris_use_cache = TRUE)

# run all_census_data.R
# marital_status is already in percentages
marital_status<-all_census_data %>%
  select(c(GEOID, NAME, est_married, est_widow, est_divorced, est_separated,
                  est_single, `est_population_15+`, moe_married, moe_widow,
                  moe_divorced, moe_separated, moe_single, geometry))
marital_status$prop_married <- ((marital_status$est_married / 100))
marital_status$prop_single <- marital_status$est_single / 100
marital_status$prop_divorced <- marital_status$est_divorced / 100

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(0,0.25,0.5,0.75,1)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")


# plot of now married
marital_status%>%
ggplot() +
  geom_sf(color="#C0C0C0",aes(fill = prop_married, geometry=geometry), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent")+
  labs(title="Percent Married in Washington by Tract Group",
       subtitle = "15+ in age")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Percentage") 
###########################
library(tidycensus)
library(tidyverse)

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
marital_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B1200"))

#join with marital status data
marital_status_high<-left_join(high,marital_census,by="GEOID")

#clean and create new columns combining sex
marital_status_high$nevermarried = marital_status_high$estimate_B12001_003 + marital_status_high$estimate_B12001_012
marital_status_high$marriednow=marital_status_high$estimate_B12001_004+marital_status_high$estimate_B12001_013
marital_status_high$widowed=marital_status_high$estimate_B12001_009+marital_status_high$estimate_B12001_018
marital_status_high$divorced=marital_status_high$estimate_B12001_010+marital_status_high$estimate_B12001_019
total_single=sum(marital_status_high$nevermarried)
total_married=sum(marital_status_high$marriednow)
total_widowed=sum(marital_status_high$widowed)
total_divorced=sum(marital_status_high$divorced)
total_pop=sum(marital_status_high$nevermarried,total_married,total_widowed,total_divorced)

totals<-data.frame(marital_status = c("Single","Married","Widowed","Divorced","Total"),
               counts = c(total_single, total_married, total_widowed, total_divorced, total_pop))
totals$prop<- df$counts / df$counts[5]

#fun colors:
# https://r-graph-gallery.com/38-rcolorbrewers-palettes.html

totals %>%
  filter(marital_status != "Total") %>%
  ggplot()+
  geom_col(aes(x=marital_status,y=prop,fill=marital_status)) +
  xlab("Marital Status") + 
  ylab("Proportion of Population (ages 15+)")+
  labs(title= "Marital Status Proportions for Highest 10%\n(Worst) Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        legend.position = "none")+
  scale_fill_brewer(palette = "Set3")
