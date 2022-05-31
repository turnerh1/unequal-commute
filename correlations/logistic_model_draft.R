model_data_na <- na.omit(model_data)

summary(model_data_na$spatialmismatch)
boxplot(model_data_na$spatialmismatch)

#cut off at 3rd quartile (.1)
cat_data <- model_data_na %>%
  mutate(high = spatialmismatch>.1)

cat_data$high <- as.numeric(cat_data$high)

plot(jitter(high,amount=.05) ~ spanish, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ median_household_income, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ above_bach, data = cat_data, family = "binomial")
plot(high~above_bach, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ below_bach, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ bach_interact, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ phd, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ white, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ nonwhite, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ people_per_sqmi, data = cat_data, family = "binomial")
plot(jitter(high,amount=.05) ~ english_better, data = cat_data, family = "binomial")

m1 <- glm(high~spanish + median_household_income + below_bach + above_bach + bach_interact + phd + white + nonwhite 
          + people_per_sqmi + english_better, data = cat_data, family = "binomial")
summary(m1)

m2 <- glm(high~median_household_income + above_bach + bach_interact + phd + white, data = cat_data, family = "binomial")
summary(m2)

G = m2$deviance - m1$deviance
Gdf = m2$df.residual - m1$df.residual
pchisq(G, df = Gdf, lower.tail = F)

addmargins(table(cat_data$high, as.numeric(m2$fitted.values >= .5)))
1872/2441
#model correctly categorizes 76.69% of data?