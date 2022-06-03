library(readr)
model_data <- read_csv("models/model_data.csv")
m.all <- lm(spatialmismatch~ spanish + median_household_income + below_bach + above_bach + bach_interact + phd + white + nonwhite 
            + people_per_sqmi + english_better, data = model_data)

# backwards selection model, r^2 = 0.165, 7 predictors
MSE=(summary(m.all)$sigma)^2
step(m.all, scale=MSE, direction="backward")

m.back <- lm(formula = spatialmismatch ~ spanish + median_household_income + 
            above_bach + bach_interact + phd + white + english_better, 
          data = model_data)
summary(m.back)

plot(m.back$resid~m.back$fitted)
abline(0,0)
plot(m.back)

#omit na's so that foward selection can occur, removed 42 rows
#this assignment must be run twice in order to create model_data_na
model_data_na <- na.omit(model_data)

# forward selection model, r^2 = 0.1644, 6 predictors
m.none <- lm(spatialmismatch~1, data = model_data_na)
step(m.none, scope=list(upper=m.all), scale=MSE, direction="forward")

m.forward <- lm(formula = spatialmismatch ~ above_bach + bach_interact + white + phd + median_household_income, data = model_data_na)

summary(m.forward)

# stepwise regression model, r^2 = .165, 7 predictors
step(m.all, scope=list(upper=m.all), scale=MSE, direction="both")
m.stepwise <- lm(formula = spatialmismatch ~ spanish + median_household_income + 
                   above_bach + bach_interact + phd + white + english_better, 
                 data = model_data)
summary(m.stepwise)

anova(m.stepwise, m.forward)

# Best subsets model
all <- regsubsets(spatialmismatch~ spanish + median_household_income + below_bach + above_bach + bach_interact + phd + white + nonwhite 
                  + people_per_sqmi + english_better, data = model_data)
round(summary(all)$adjr2, 3)
plot(all, scale="adjr2")

# Lowest Cp model
round(summary(all)$cp,2)
plot(all, scale="Cp")

best_indiv_edu <- lm(formula = spatialmismatch ~ above_bach + bach_interact + white + phd + median_household_income, data = model_data_na)

summary(best_indiv_edu)

plot(best_indiv_edu)

