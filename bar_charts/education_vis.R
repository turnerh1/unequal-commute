# get job access and acs data from visualization_setup.R

edu_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B15003"))

#using education by for 25+ age
edu_census <- edu_census %>%
  select(c(GEOID, NAME, 
           estimate_B15003_001, #total
           estimate_B15003_002, #no education
           estimate_B15003_016, #12th grade no diploma
           estimate_B15003_017, #high school diploma
           estimate_B15003_018, #GED
           estimate_B15003_019, #some college, <1 year
           estimate_B15003_020, #some college >1 year, no degree
           estimate_B15003_021, #associate degree,
           estimate_B15003_022, #bachelor degree
           estimate_B15003_023, #master degree
           estimate_B15003_024, #professional school degree
           estimate_B15003_025)) #doctoral degree

#some college, <1 year AND  #some college >1 year, no degree
edu_census$somecollege = edu_census$estimate_B15003_019 +
                         edu_census$estimate_B15003_020 

# associate, bachelor, master, professional school, doctorate
edu_census$higher_ed = edu_census$estimate_B15003_021 + 
                       edu_census$estimate_B15003_022 + 
                       edu_census$estimate_B15003_023 + 
                       edu_census$estimate_B15003_024 + 
                       edu_census$estimate_B15003_025

# master, professional, doctorate
edu_census$post_grad = edu_census$estimate_B15003_023 + 
                       edu_census$estimate_B15003_024 + 
                       edu_census$estimate_B15003_025

#join with edu_census data
edu_high <- left_join(high, edu_census, by="GEOID")
edu_low <- left_join(low, edu_census, by="GEOID")

#create data frames
#high
htotal_noedu = sum(edu_high$estimate_B15003_002)
htotal_nodiploma=sum(edu_high$estimate_B15003_016)
htotal_hsdiploma=sum(edu_high$estimate_B15003_017)
htotal_GED=sum(edu_high$estimate_B15003_018)
htotal_somecollege=sum(edu_high$somecollege)
htotal_associate = sum(edu_high$estimate_B15003_021)
htotal_bachelor = sum(edu_high$estimate_B15003_022)
htotal_master = sum(edu_high$estimate_B15003_023)
htotal_professional = sum(edu_high$estimate_B15003_024)
htotal_doctoral = sum(edu_high$estimate_B15003_025)
htotal_highered = sum(edu_high$higher_ed)
htotal_postgrad = sum(edu_high$post_grad)
htotal_population = sum(htotal_noedu, htotal_nodiploma, htotal_hsdiploma, htotal_GED, htotal_somecollege, htotal_highered)

htotals<-data.frame("education_level"=c("None","HS, No Diploma", "HS Diploma", "GED", "Some College", "Associates",
                                        "Bachelors", "Masters", "Professional school","Doctoral","Higher Ed Degree", "Post Grad Degree","Total"),
                    "hcounts" = c(htotal_noedu, htotal_nodiploma, htotal_hsdiploma, htotal_GED, htotal_somecollege, htotal_associate,
                                  htotal_bachelor, htotal_master, htotal_professional,htotal_doctoral, htotal_highered, htotal_postgrad,htotal_population),
                    "order"=c(1,2,3,4,5,6,7,8,9,10,11,12,13))
htotals$hprop<-htotals$hcounts / htotals$hcounts[13]

#low
ltotal_noedu = sum(edu_low$estimate_B15003_002)
ltotal_nodiploma=sum(edu_low$estimate_B15003_016)
ltotal_hsdiploma=sum(edu_low$estimate_B15003_017)
ltotal_GED=sum(edu_low$estimate_B15003_018)
ltotal_somecollege=sum(edu_low$somecollege)
ltotal_associate = sum(edu_low$estimate_B15003_021)
ltotal_bachelor = sum(edu_low$estimate_B15003_022)
ltotal_master = sum(edu_low$estimate_B15003_023)
ltotal_professional = sum(edu_low$estimate_B15003_024)
ltotal_doctoral = sum(edu_low$estimate_B15003_025)
ltotal_highered = sum(edu_low$higher_ed)
ltotal_postgrad = sum(edu_low$post_grad)
ltotal_population = sum(ltotal_noedu, ltotal_nodiploma, ltotal_hsdiploma, ltotal_GED, ltotal_somecollege, ltotal_highered)
ltotals<-data.frame("education_level"=c("None","HS, No Diploma", "HS Diploma", "GED", "Some College", "Associates",
                                        "Bachelors", "Masters", "Professional school","Doctoral","Higher Ed Degree", "Post Grad Degree","Total"),
                    "lcounts" = c(ltotal_noedu, ltotal_nodiploma, ltotal_hsdiploma, ltotal_GED, ltotal_somecollege, ltotal_associate,
                                  ltotal_bachelor, ltotal_master, ltotal_professional,ltotal_doctoral, ltotal_highered, ltotal_postgrad,ltotal_population))
ltotals$lprop<-ltotals$lcounts / ltotals$lcounts[13]

#join
totals<-left_join(htotals,ltotals, by = "education_level") %>%
  pivot_longer(cols = c(lprop,hprop), names_to = "prop_type", values_to = "prop")

totals %>% 
  arrange(desc(prop)) %>%
  filter(education_level != "Total" & education_level != "Higher Ed Degree" & education_level != "Post Grad Degree") %>%
  ggplot(aes(x=reorder(education_level,order),y=prop,fill=forcats::fct_rev(prop_type)))+
  geom_col(position = position_dodge()) +
  xlab("Education Level") + 
  ylab("Proportion of Population (ages 25+)")+
  labs(fill="Spatial Mismatch",title= "Education Level for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                    values=c("#9ecae1","#de2d26"))
totals %>% 
  arrange(desc(prop)) %>%
  filter(education_level != "Total" & education_level != "Bachelors" & education_level != "Associates"
         & education_level != "Professional school" & education_level != "Masters" & education_level != "Doctoral") %>%
  ggplot(aes(x=reorder(education_level,order),y=prop,fill=forcats::fct_rev(prop_type)))+
  geom_col(position = position_dodge()) +
  xlab("Education Level") + 
  ylab("Proportion of Population (ages 25+)")+
  labs(fill="Spatial Mismatch",title= "Education Level for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                    values=c("#9ecae1","#de2d26"))

