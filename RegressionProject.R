Prices = read.csv("btc_eth_prices_hourly.csv",stringsAsFactors = TRUE)
Traits = read.csv("punk_traits.csv",stringsAsFactors = TRUE)
Sales = read.csv("punk_sales.csv",stringsAsFactors = TRUE)

#Independent variable: Setting Floor as minimum of last 20 transactions in Sales 
install.packages("zoo")
library(zoo)
Sales$Floor = rollapplyr(Sales$eth_amount,list(-1:-20),min,fill=NA)

#Reads and merges in Rarity2 to created Merged 
Rarity2 = read.csv("punk_rarities2.csv")
Merged = merge(Sales,Rarity2,by.x="token_id",by.y="id")

#Independent variable: Creates ExchangeRate in Merged  
Merged$ExchangeRate = Merged$eth_amount / Merged$usd_amount

#Converts Inf and NaN values to NA, and then drops rows with NA 
Merged[is.na(Merged) | Merged == "Inf"] <- NA
Merged[is.na(Merged) | Merged == "NaN"] <- NA
MergedClean = Merged[complete.cases(Merged),]

#Turns Punk.Type to binary Gender variable 
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

#Finds RMSE of training data (29.45267)
sqrt(mean((train$eth_amount - reg1$fitted.values)^2))

#Plots fitted values vs. residuals 
plot(reg1$fitted.values,reg1$residuals,labels=TRUE)

#Predicts on test data 
Predictions = predict(reg1, newdata = test)
plot(Predictions, test$eth_amount)

#Finds RMSE of test data (33.17123) 
sqrt(mean((test$eth_amount - Predictions)^2))

#Lasso
library(glmnet)
XVars = sparse.model.matrix(eth_amount ~ Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender, data = train)
set.seed(12345)
Lasso = cv.glmnet(x = XVars,y = train$eth_amount)
coef(Lasso,s="lambda.min")!=0 #Excludes Full.Type.rarity, Blemishes.rarity,Noses.rarity, and Ears.rarity
sum(coef(Lasso,s="lambda.min")!=0)

XVarsTest = sparse.model.matrix(eth_amount ~ Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender, data = test)
PredictLasso = predict(Lasso, newx = XVarsTest, s="lambda.min")
sqrt(mean((test$eth_amount - PredictLasso)^2)) #33.21209 ??? How is this a higher RMSE than w/o Lasso? 


#-----------------------REGRESSION ON LOG OF DEPENDENT VARIABLE-----------------------

#Creates new variable that is log of eth_amount
MergedReal$log_eth_amount = log(MergedReal$eth_amount)

#Creates new df that removes Inf log_eth_amount and splits into training/testing data
MergedLog = MergedReal[is.finite(MergedReal$log_eth_amount),]

set.seed(12345)
dt = sample(nrow(MergedLog),0.8*nrow(MergedLog))
trainlog = MergedLog[dt,]
testlog = MergedLog[-dt,]

#Runs regression on trainlog with log_eth as dependent variable (R^2 = 0.4103)
reglog = lm(log_eth_amount ~ Floor + Attribute.Count.rarity + Skin.Tone.rarity + isPersonOfColor + Full.Type.rarity + Hair.rarity + Eyes.rarity + Facial.Hair.rarity + Blemishes.rarity + Neck.Accessory.rarity + Mouth.Prop.rarity + Mouth.rarity + Nose.rarity + Ears.rarity + ExchangeRate + Gender,data=trainlog)
summary(reglog)

#Plots fitted values vs. residuals 
plot(reglog$fitted.values,reglog$residuals,labels=TRUE)
