library(tidyverse)
library(geojsonsf)
library(broom)
job_access_gap_sf <- geojson_sf( "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2021/04/15/job_access_gap.geojson" )

#ggplot( job_access_gap_sf ) + 
#  geom_sf()
# Seattle map by spatialmismatch
job_access_gap_sf_sea <- 
  job_access_gap_sf %>% 
  filter( MSA == "Seattle" )

# choose colors: http://colorbrewer2.org/ 
mybreaks<-c(0,0.1,0.2,0.3)
my_colors <- c("white","#fb6a4a","#de2d26","#a50f15")

ggplot( job_access_gap_sf_sea) + 
  geom_sf(color="#fee5d9", mapping=aes(fill=spatialmismatch), size=0.001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "#253494",
                        breaks=mybreaks,
                        labels = mybreaks)+
  labs(title="Normalized Spatial Mismatch",
       subtitle = "Measured in Seattle and Surrounding Areas")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5))+
  labs(fill = "Normalized Spatial Mismatch")
#make lines thinner
#make 0 blue? for water