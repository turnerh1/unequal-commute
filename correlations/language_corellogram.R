## run the visualization setup first
library(corrplot)

### get the variables for each category we're interested in
language_dict <- read_csv("./data/dictionaries/language_metadata.csv")

# var name for total population of this table
total_pop <- paste( "estimate_", (language_dict %>% head( 1 ))$code, sep ="")

# these categories should add up to the total population
english_only <- language_dict %>% filter( grepl( "Speak only English", label) )
english_only$varname <- paste( "estimate_", english_only$code, sep="")

english_verywell <- language_dict %>% filter( grepl( "Speak English \"very well\"", label) )
english_verywell$varname <- paste( "estimate_", english_verywell$code, sep="")

english_well <- language_dict %>% filter( grepl( "Speak English \"well\"", label) )
english_well$varname <- paste( "estimate_", english_well$code, sep="")

english_notwell <- language_dict %>% filter( grepl( "Speak English \"not well\"", label) )
english_notwell$varname <- paste( "estimate_", english_notwell$code, sep="")

english_notatall <- language_dict %>% filter( grepl( "Speak English \"not at all\"", label) )
english_notatall$varname <- paste( "estimate_", english_notatall$code, sep="")

language_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B1600"))

english_ability <- language_census %>% select(GEOID, total_pop) %>% rename( "total"=total_pop)

english_ability_filled <- english_ability %>% 
  mutate( english_only     = rowSums( language_census %>% select( english_only$varname ), na.rm=T ),
          english_verywell = rowSums( language_census %>% select( english_verywell$varname ), na.rm=T ),
          english_well     = rowSums( language_census %>% select( english_well$varname ), na.rm=T ),
          english_notwell  = rowSums( language_census %>% select( english_notwell$varname ), na.rm=T ),
          english_notatall = rowSums( language_census %>% select( english_notatall$varname ), na.rm=T )) %>% 
  mutate( english_better = english_only + english_verywell +english_well,
          english_worse = english_notwell + english_notatall ) %>% 
  mutate( english_only     = english_only / total,
          english_verywell = english_verywell / total,
          english_well     = english_well / total,
          english_notwell  = english_notwell / total,
          english_notatall = english_notatall / total,
          english_better = english_better / total,
          english_worse = english_worse / total) %>% 
  left_join( job_access_gap %>% 
               filter(MSA=="Seattle") %>% 
               select( GEOID, spatialmismatch ) ) 

write_csv( english_ability_filled, "./data/english_speaking_ability.csv")

# %>% 
#   select( -GEOID )

correlations <- cor(english_ability_filled, use = "complete.obs")

#  Positive correlations are displayed in blue and negative correlations in red color. 
# Color intensity and the size of the circle are proportional to the correlation coefficients. 
# In the right side of the correlogram, the legend color shows the correlation 
# coefficients and the corresponding colors.
corrplot(correlations, order = "hclust", 
         tl.col = "black", tl.srt = 45)
