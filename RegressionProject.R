Prices = read.csv("btc_eth_prices_hourly.csv",stringsAsFactors = TRUE)
Traits = read.csv("punk_traits.csv",stringsAsFactors = TRUE)
Sales = read.csv("punk_sales.csv",stringsAsFactors = TRUE)

#Independent variable: Setting Floor as minimum of last 20 transactions in Sales 
install.packages("zoo")
library(zoo)
Sales$Floor = rollapplyr(Sales$eth_amount,list(-1:-20),min,fill=NA)

#Reads and merges in Rarity2 to create df Merged 
Rarity2 = read.csv("punk_rarities2.csv")
Merged = merge(Sales,Rarity2,by.x="token_id",by.y="id")

#Independent variable: Creates ExchangeRate in Merged  
Merged$ExchangeRate = Merged$eth_amount / Merged$usd_amount

#Converts Inf and NaN values to NA, and then drops rows with NA 
Merged[is.na(Merged) | Merged == "Inf"] <- NA
Merged[is.na(Merged) | Merged == "NaN"] <- NA
MergedClean = Merged[complete.cases(Merged),]

#Turns Punk.Type to binary Gender variable in new df MergedClean 
lookup = c("Male" = 1, "Female" = 0)
MergedClean$Gender = lookup[MergedClean$Punk.Type]

#Creates df MergedReal, dropping rows if not male or female 
MergedReal = subset(MergedClean, !(Punk.Type %in% c("Zombie", "Alien", "Ape")) & usd_amount < 10000000)

#Creates correlation matrix 
CorMatrix = subset(MergedReal, select = -c(datetime_UTC, token_id, timestamp_UTC, eth_amount, usd_amount, Full.Type.rarity))
cor(CorMatrix[sapply(CorMatrix, is.numeric)],use="complete.obs")

#Splits dataset (80% train, 20% test)
set.seed(12345)
dt = sample(nrow(MergedReal),0.8*nrow(MergedReal))
train = MergedReal[dt,]
test = MergedReal[-dt,]

#Runs regression on training data (R^2 = 0.5658)
reg1 = lm(eth_amount ~ Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender,data=train)
summary(reg1)

#Copy regression coefficients to table 
install.packages("broom")
library(broom)
install.packages("clipr")
library(clipr)
install.packages("magrittr")
library(magrittr)

reg1 = lm(eth_amount ~ Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender,data=train) %>%
  tidy() %>%
  write_clip()

#Finds RMSE of training data (29.45267)
sqrt(mean((train$eth_amount - reg1$fitted.values)^2))

#Plots fitted values vs. residuals 
plot(reg1$fitted.values,reg1$residuals,labels=TRUE,xlab="Fitted Values",ylab="Residuals",main="Fitted Values vs. Residuals")

#Predicts on test data 
Predictions = predict(reg1, newdata = test)
plot(Predictions, test$eth_amount,xlab="Predictions",ylab="Price from Test Data",main="Predictions vs. Test Data")

#Finds RMSE of test data (33.17123) 
sqrt(mean((test$eth_amount - Predictions)^2))

#Lasso
library(glmnet)
XVars = sparse.model.matrix(eth_amount ~ (Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender)^2, data = train)
set.seed(12345)
Lasso = cv.glmnet(x = XVars,y = train$eth_amount)
coef(Lasso,s="lambda.min")!=0 
sum(coef(Lasso,s="lambda.min")!=0)

XVarsTest = sparse.model.matrix(eth_amount ~ (Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender)^2, data = test)
PredictLasso = predict(Lasso, newx = XVarsTest, s="lambda.min")
sqrt(mean((test$eth_amount - PredictLasso)^2)) #30.95439

plot(PredictLasso, test$eth_amount,xlab="Predictions",ylab="Price from Test Data",main="Predictions vs. Test Data")

#-----------------------REGRESSION ON LOG OF DEPENDENT VARIABLE-----------------------

#Creates new variables that are logs of eth_amount and Floor 
MergedReal$log_eth_amount = log(MergedReal$eth_amount)
MergedReal$log_Floor = log(MergedReal$Floor)
MergedReal$log_ExchangeRate = log(MergedReal$ExchangeRate)

#Creates new df MergedLog that removes Inf log_eth_amount
MergedLog = MergedReal[is.finite(MergedReal$log_eth_amount) & is.finite(MergedReal$log_Floor) & is.finite(MergedReal$log_ExchangeRate),]

#Splits MergedLog in training and test data 
set.seed(12345)
dtlog = sample(nrow(MergedLog),0.8*nrow(MergedLog))
trainlog = MergedLog[dtlog,]
testlog = MergedLog[-dtlog,]

#Runs regression on trainlog with log_eth as dependent variable (R^2 = 0.4103)
reglog = lm(log_eth_amount ~ log_Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + log_ExchangeRate + Gender,data=trainlog)
summary(reglog)

#Copy regression coefficients to table 
reglog = lm(log_eth_amount ~ log_Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + log_ExchangeRate + Gender,data=trainlog) %>%
  tidy() %>%
  write_clip()

#Plots fitted values vs. residuals 
plot(reglog$fitted.values,reglog$residuals,labels=TRUE,xlab="Fitted Values",ylab="Residuals",main="Fitted Values vs. Residuals")

#Finds RMSE of training data (51.92751)
sqrt(mean((trainlog$eth_amount - reglog$fitted.values)^2))

#Predicts on test data 
PredictionsLog = predict(reglog, newdata = testlog)
plot(PredictionsLog, testlog$eth_amount,xlab="Predictions",ylab="Price from Test Data",main="Predictions vs. Test Data")

#Finds RMSE of test data (53.73768) 
sqrt(mean((testlog$eth_amount - PredictionsLog)^2))
