library(tidyverse)
library(geojsonsf)
library(broom)
job_access_gap_sf <- geojson_sf( "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2021/04/15/job_access_gap.geojson" )

ggplot( job_access_gap_sf ) + 
  geom_sf()
# Seattle base map, no data
job_access_gap_sf_sea <- 
  job_access_gap_sf %>% 
  filter( MSA == "Seattle" )

mybreaks<-c(0,0.1,0.2,0.3)

ggplot( job_access_gap_sf_sea) + 
  geom_sf(color="white", mapping=aes(fill=spatialmismatch))+
  scale_fill_continuous(low="white",
                       high="red",
                        breaks=mybreaks,
                        labels = mybreaks)
#make lines thinner
#make 0 blue? for water