# get job access and acs data from visualization_setup.R

work_status_census <- acs_dataset %>%
  select(GEOID,NAME,contains("B23022"))

work_status_census$GEOID <- as.numeric(work_status_census$GEOID)

#join with work status data
work_status_high<-left_join(high,work_status_census,by="GEOID")

work_status_low<-left_join(low,work_status_census,by="GEOID")

#clean and create new columns combining sex
work_status_census$total_pop <- work_status_census$estimate_B23022_002 + work_status_census$estimate_B23022_026
work_status_census$total_worked <- work_status_census$estimate_B23022_003 + work_status_census$estimate_B23022_027
work_status_census$total_35more <- work_status_census$estimate_B23022_004 + work_status_census$estimate_B23022_028
work_status_census$total_15to34 <- work_status_census$estimate_B23022_011 + work_status_census$estimate_B23022_035
work_status_census$total_1to14 <- work_status_census$estimate_B23022_018 + work_status_census$estimate_B23022_042
work_status_census$total_notworked <- work_status_census$estimate_B23022_025 + work_status_census$estimate_B23022_049

work_status_high$total_pop <- work_status_high$estimate_B23022_002 + work_status_high$estimate_B23022_026
work_status_high$total_worked <- work_status_high$estimate_B23022_003 + work_status_high$estimate_B23022_027
work_status_high$total_35more <- work_status_high$estimate_B23022_004 + work_status_high$estimate_B23022_028
work_status_high$total_15to34 <- work_status_high$estimate_B23022_011 + work_status_high$estimate_B23022_035
work_status_high$total_1to14 <- work_status_high$estimate_B23022_018 + work_status_high$estimate_B23022_042
work_status_high$total_notworked <- work_status_high$estimate_B23022_025 + work_status_high$estimate_B23022_049

work_status_low$total_pop <- work_status_low$estimate_B23022_002 + work_status_low$estimate_B23022_026
work_status_low$total_worked <- work_status_low$estimate_B23022_003 + work_status_low$estimate_B23022_027
work_status_low$total_35more <- work_status_low$estimate_B23022_004 + work_status_low$estimate_B23022_028
work_status_low$total_15to34 <- work_status_low$estimate_B23022_011 + work_status_low$estimate_B23022_035
work_status_low$total_1to14 <- work_status_low$estimate_B23022_018 + work_status_low$estimate_B23022_042
work_status_low$total_notworked <- work_status_low$estimate_B23022_025 + work_status_low$estimate_B23022_049

htotal_1to14=sum(work_status_high$total_1to14)
htotal_15to34=sum(work_status_high$total_15to34)
htotal_35more=sum(work_status_high$total_35more)
htotal_worked=sum(work_status_high$total_worked)
htotal_notworked=sum(work_status_high$total_notworked)
htotal_pop=sum(work_status_high$total_pop)

ltotal_1to14=sum(work_status_low$total_1to14)
ltotal_15to34=sum(work_status_low$total_15to34)
ltotal_35more=sum(work_status_low$total_35more)
ltotal_worked=sum(work_status_low$total_worked)
ltotal_notworked=sum(work_status_low$total_notworked)
ltotal_pop=sum(work_status_low$total_pop)


totals_high<-data.frame(work_status = factor( c("Not Worked", "1-14 hours","15-35 hours","35+ hours","Worked","Total"),
                                              levels=c("Not Worked", "1-14 hours","15-35 hours","35+ hours","Worked","Total")),
                        high_count = c(htotal_notworked, htotal_1to14, htotal_15to34, htotal_35more, htotal_worked, htotal_pop))
totals_high$high_prop<- totals_high$high_count / totals_high$high_count[6]

totals_low<-data.frame(work_status = factor( c("Not Worked","1-14 hours","15-35 hours","35+ hours","Worked","Total"),
                                             levels=c("Not Worked", "1-14 hours","15-35 hours","35+ hours","Worked","Total")),
                       low_count = c(ltotal_notworked, ltotal_1to14, ltotal_15to34, ltotal_35more, ltotal_worked, ltotal_pop))
totals_low$low_prop<- totals_low$low_count / totals_low$low_count[6]

totals <- left_join(totals_high,totals_low, by = "work_status")

totals %>%
  pivot_longer(cols = c(low_prop,high_prop), names_to = "prop_type", values_to = "prop") %>%
  filter(work_status!= "Worked" & work_status != "Total") %>%
  ggplot(aes(x=work_status,y=prop,fill=prop_type))+
  geom_col(position = position_dodge()) +
  xlab("Work Status") + 
  ylab("Proportion of Population (ages 16-64)")+
  labs(fill="Spatial Mismatch", title= "Work Status Proportions for Highest and Lowest \n 10% Spatial Mismatch in Seattle") +
  theme(plot.title = element_text(hjust = 0.5),
        panel.background = element_rect(fill = '#f7f7f7'),
        axis.text.x = element_text(angle = 45, hjust=1)) + 
  scale_fill_manual(labels = c( "Low/Best","High/Worst"),
                    values=c("#9ecae1","#de2d26"))

#Seperate plots for high and low (not suggested due as its harder to compare)
# totals_high %>%
#   filter(work_status!= "Worked" & work_status != "Total") %>%
#   ggplot()+
#   geom_col(aes(x=work_status,y=prop,fill=work_status)) +
#   xlab("Work Status") + 
#   ylab("Proportion of Population (ages 16-64)")+
#   labs(title= "Work Status Proportions for Highest 10%\n(Worst) Spatial Mismatch in Seattle") +
#   theme(plot.title = element_text(hjust = 0.5),
#         panel.background = element_rect(fill = '#f7f7f7'),
#         legend.position = "none")+
#   scale_fill_brewer(palette = "Set3")
# 
# 
# totals_low %>%
#   filter(work_status!= "Worked" & work_status != "Total") %>%
#   ggplot()+
#   geom_col(aes(x=work_status,y=prop,fill=work_status)) +
#   xlab("Work Status") + 
#   ylab("Proportion of Population (ages 16-64)")+
#   labs(title= "Work Status Proportions for Lowest 10%\n(Best) Spatial Mismatch in Seattle") +
#   theme(plot.title = element_text(hjust = 0.5),
#         panel.background = element_rect(fill = '#f7f7f7'),
#         legend.position = "none")+
#   scale_fill_brewer(palette = "Set3")
