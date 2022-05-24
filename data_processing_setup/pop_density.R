library(readr)

raw_land_area <- read_csv("./data/land_area/geocorr2018_2214303285.csv")

processed_land_area <- raw_land_area %>%
  slice(-1) %>% 
  mutate( tract_nodot = str_remove(tract, "[.]"),
          GEOID = paste(county, tract_nodot, bg, sep=""),
          LandSQMI = as.numeric( LandSQMI )) %>% 
  select( GEOID, LandSQMI)
  
# note: this should work once the population data is in the dataset
# acs_dataset <- read_csv("./data/acs_dataset.csv")
# population <- acs_dataset %>% 
#   select(GEOID,NAME,contains("B01001"))

# interim solution: run the population section of get_and_label_acs. not as good as what's above

processed_land_area <- processed_land_area %>%
  left_join( population, by="GEOID") %>% 
  mutate( people_per_sqmi = ( estimate_B01001_001 / LandSQMI ) )
  
write_csv(processed_land_area, "./data/land_area/pop_density.csv")
