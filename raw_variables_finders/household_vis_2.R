#RUN 'all_census_data.R' file first


#temporary work around for geometries until we get them pulled
geome<-select(work_status_data,c(GEOID, geometry))

#select variables for which proportions you want
household <- household_size_data %>%
  select(GEOID, NAME, est_housing_units_total, est_housing_size_4p)
#create proportions
household$prop_est_4p <- household$est_housing_size_4p / household$est_housing_units_total

# choose colors: http://colorbrewer2.org/ 
#colors and breaks
mybreaks<-c(0.15,0.3,0.45,0.6)
my_colors <- c("white","#fcae91","#fb6a4a","#de2d26","#a50f15")

household %>%
  ggplot() +
  geom_sf(aes(fill = prop_est_4p, geometry = geome$geometry), size=0.00001) +
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks)+
  labs(title="Household Size by Tract Group",
       subtitle = "4+ people per household")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Proportion of Occupied Housing")
