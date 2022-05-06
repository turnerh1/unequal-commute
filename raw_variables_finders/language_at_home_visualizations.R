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
language_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B1600"))
#using age by language spoken 5+

language_census <- language_census %>%
  select(c(GEOID, NAME, #ages 5-17:
           estimate_B16004_002,estimate_B16004_003,estimate_B16004_004, 
           estimate_B16004_009,estimate_B16004_014,estimate_B16004_019,
           #ages 18-64:
           estimate_B16004_024, estimate_B16004_025, estimate_B16004_026,
           estimate_B16004_031, estimate_B16004_036,estimate_B16004_041,
           #ages 65+:
           estimate_B16004_046, estimate_B16004_047, estimate_B16004_048,
           estimate_B16004_053, estimate_B16004_058, estimate_B16004_063))
language_census$population = language_census$estimate_B16004_002 + language_census$estimate_B16004_024 + language_census$estimate_B16004_046
language_census$english = language_census$estimate_B16004_003 + language_census$estimate_B16004_025 + language_census$estimate_B16004_047
language_census$spanish = language_census$estimate_B16004_004 + language_census$estimate_B16004_026 + language_census$estimate_B16004_048
language_census$indo_european = language_census$estimate_B16004_009 + language_census$estimate_B16004_031 + language_census$estimate_B16004_053
language_census$aapi = language_census$estimate_B16004_014 + language_census$estimate_B16004_036 + language_census$estimate_B16004_058
language_census$other = language_census$estimate_B16004_019 + language_census$estimate_B16004_041 + language_census$estimate_B16004_063


#join with marital status data
language_high<-left_join(high,language_census,by="GEOID") %>%
  select(GEOID, population, english, spanish, indo_european, aapi, other)
language_low<-left_join(low,language_census,by="GEOID")%>%
  select(GEOID, population, english, spanish, indo_european, aapi, other)

#clean and create totals
#high
h_total_english = sum(language_high$english)
h_total_spanish = sum(language_high$spanish)
h_total_indo = sum(language_high$indo_european)
h_total_aapi = sum(language_high$aapi)
h_total_other = sum(language_high$other)
h_total_population = sum(language_high$population)

htotals<-data.frame("language_at_home" = c("English", "Spanish", "Indo European", "AAPI", "Other", "Total"),
                    hcounts = c(h_total_english, h_total_spanish, h_total_indo, h_total_aapi, h_total_other, h_total_population ))
htotals$hprop = htotals$hcounts / htotals$hcounts[6]

#low
l_total_english = sum(language_low$english)
l_total_spanish = sum(language_low$spanish)
l_total_indo = sum(language_low$indo_european)
l_total_aapi = sum(language_low$aapi)
l_total_other = sum(language_low$other)
l_total_population = sum(language_low$population)
ltotals<-data.frame("language_at_home" = c("English", "Spanish", "Indo European", "AAPI", "Other", "Total"),
                    lcounts = c(l_total_english, l_total_spanish, l_total_indo, l_total_aapi, l_total_other, l_total_population ))
ltotals$lprop = ltotals$lcounts / ltotals$lcounts[6]

#join
totals <- left_join(htotals,ltotals, by = "language_at_home")
totals<-totals %>%
  pivot_longer(cols = c(lprop,hprop), names_to = "prop_type", values_to = "prop")
totals %>% 
  arrange(desc(prop)) %>%
  filter(language_at_home != "Total") %>%
  ggplot(aes(x=reorder(language_at_home,prop),y=prop,fill=forcats::fct_rev(prop_type)))+
  geom_col(position = position_dodge()) +
  xlab("Language Spoken at Home") + 
  ylab("Proportion of Population (ages 5+)")+
  labs(fill="Spatial Mismatch",title= "Language Spoken for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7')) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                    values=c("#9ecae1","#de2d26"))


#same graph but excluding english:

totals %>% 
  arrange(desc(prop)) %>%
  filter(language_at_home != "Total"& language_at_home != "English") %>%
  ggplot(aes(x=reorder(language_at_home,prop),y=prop,fill=forcats::fct_rev(prop_type)))+
  geom_col(position = position_dodge()) +
  xlab("Language Spoken at Home") + 
  ylab("Proportion of Population (ages 5+)")+
  labs(fill="Spatial Mismatch",title= "Language Spoken for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5)) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                      values=c("#9ecae1","#de2d26"))
