library(readr)

raw_land_area <- read_csv("./data/land_area/geocorr2018_2214303285.csv")

processed_land_area <- raw_land_area %>%
  slice(-1) %>% 
  mutate( tract_nodot = str_remove(tract, "[.]"),
          GEOID = paste(county, tract_nodot, bg, sep="")) %>% 
  select( GEOID, cntyname, LandSQMI)
  
acs_dataset <- read_csv("./data/acs_dataset.csv")

# population <- acs_dataset %>% 
#   select(GEOID,NAME,contains("B01001"))

