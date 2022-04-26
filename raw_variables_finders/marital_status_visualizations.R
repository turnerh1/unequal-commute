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
  labs(title="Percent Married in Seattle by Tract Group",
       subtitle = "15+ in age")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Percentage") 
