# Install tigris and rtidycensus packages

library(tidycensus)
library(tidyverse)

# load your data, but leave out the geometries
job_access_gap <- read_csv("job_access_gap.csv", 
                           col_types = cols(geometry = col_skip()))

options(tigris_use_cache = TRUE)

# Go to http://api.census.gov/data/key_signup.html to get census api key
# substitute your api key inside the quotes below:
#census_api_key("e56a55801fa54f1ee8de39689336aafa11a755ab", overwrite = TRUE, install = TRUE)

# download geometries for the state of washington for all census block groups:
wa_geometry <- get_acs(geography = "block group", variables = "B19013_001", 
                       state = "WA", geometry = T)

# the command above also gets estimates of median household income (that's "B19013_001")
# you have to download at least one variable to make it work

# mutate geometries to build map:
wa_geometry <- wa_geometry %>%
  mutate(GEOID = as.numeric(GEOID)) 

# join your data with geometries:
map_data <- left_join(wa_geometry, job_access_gap)

mybreaks<-c(0,0.1,0.2,0.3)
my_colors <- c("white","#fb6a4a","#de2d26","#a50f15")



# map of median household income for Seattle area:
ggplot(map_data) +
  geom_sf(color="#C0C0C0",aes(fill = spatialmismatch), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  labs(title="Spatial Mismatch By Census Block Group",
       subtitle = "Seattle, WA and Surrounding Areas")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Normalized\nSpatial\nMismatch")  


# filter the geometries to just the ones included in your data:
seattle_geometry <- wa_geometry %>%
  mutate(GEOID = as.numeric(GEOID)) %>%
filter(GEOID %in% job_access_gap$GEOID)

# join seattle data with geometries
seattle_map_data <- left_join(seattle_geometry, job_access_gap)

ggplot(seattle_map_data) +
  geom_sf(color="white",aes(fill = spatialmismatch), size=0.00001)+
  scale_fill_gradientn(colors=my_colors,
                       na.value = "transparent",
                       breaks=mybreaks,
                       labels = mybreaks)+
  labs(title="Spatial Mismatch By Census Block Group",
       subtitle = "Seattle, WA and Surrounding Areas")+
  theme(plot.title = element_text(hjust = 0.5, size=15)) +
  theme(plot.subtitle = element_text(hjust = 0.5, size=10))+
  labs(fill = "Normalized\nSpatial\nMismatch")
