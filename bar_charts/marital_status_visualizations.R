
marital_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B1200"))

#join with marital status data
marital_status_high<-left_join(high,marital_census,by="GEOID")
marital_status_low<-left_join(low,marital_census,by="GEOID")

#clean and create new columns combining sex
marital_status_high$nevermarried = marital_status_high$estimate_B12001_003 + marital_status_high$estimate_B12001_012
marital_status_high$marriednow=marital_status_high$estimate_B12001_004+marital_status_high$estimate_B12001_013
marital_status_high$widowed=marital_status_high$estimate_B12001_009+marital_status_high$estimate_B12001_018
marital_status_high$divorced=marital_status_high$estimate_B12001_010+marital_status_high$estimate_B12001_019
htotal_single=sum(marital_status_high$nevermarried)
htotal_married=sum(marital_status_high$marriednow)
htotal_widowed=sum(marital_status_high$widowed)
htotal_divorced=sum(marital_status_high$divorced)
htotal_pop=sum(htotal_single,htotal_divorced,htotal_married,htotal_widowed)
marital_status_low$nevermarried = marital_status_low$estimate_B12001_003 + marital_status_low$estimate_B12001_012
marital_status_low$marriednow=marital_status_low$estimate_B12001_004+marital_status_low$estimate_B12001_013
marital_status_low$widowed=marital_status_low$estimate_B12001_009+marital_status_low$estimate_B12001_018
marital_status_low$divorced=marital_status_low$estimate_B12001_010+marital_status_low$estimate_B12001_019
ltotal_single=sum(marital_status_low$nevermarried)
ltotal_married=sum(marital_status_low$marriednow)
ltotal_widowed=sum(marital_status_low$widowed)
ltotal_divorced=sum(marital_status_low$divorced)
ltotal_pop=sum(ltotal_single,ltotal_divorced,ltotal_married,ltotal_widowed)

htotals<-data.frame(marital_status = c("Single","Married","Widowed","Divorced","Total"),
               hcounts = c(htotal_single, htotal_married, htotal_widowed, htotal_divorced, htotal_pop))
ltotals<-data.frame(marital_status = c("Single","Married","Widowed","Divorced","Total"),
                    lcounts = c(ltotal_single, ltotal_married, ltotal_widowed, ltotal_divorced, ltotal_pop))
htotals$hprop<- htotals$hcounts / htotals$hcounts[5]
ltotals$lprop<- ltotals$lcounts / ltotals$lcounts[5]
totals <- left_join(htotals,ltotals, by = "marital_status")

#fun colors:
# https://r-graph-gallery.com/38-rcolorbrewers-palettes.html

totals<-totals %>%
  pivot_longer(cols = c(lprop,hprop), names_to = "prop_type", values_to = "prop")

totals %>% 
  arrange(desc(prop)) %>%
  filter(marital_status != "Total") %>%
  ggplot(aes(x=reorder(marital_status,prop),y=prop,fill=forcats::fct_rev(prop_type)))+
  geom_col(position = position_dodge()) +
  xlab("Marital Status") + 
  ylab("Proportion of Population (ages 15+)")+
  labs(fill="Spatial Mismatch",title= "Marital Status Proportions for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7')) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                    values=c("#9ecae1","#de2d26"))

