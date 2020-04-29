library(tidyverse)
library(pROC)

# Data preperation
# reading in the data
df <- read_csv("Telco Data.csv")
head(df)
# dimensions of the data
dim_desc(df)
attach(df)

# names of the data
names(df)
# taking a look at the data
glimpse(df)
# changing character variables to factors
df <- df %>% mutate_if(is.character, as.factor)

# changing SeniorCitizen variable to factor
df$SeniorCitizen <- as.factor(df$SeniorCitizen)
# looking for missing values
df %>% map(~ sum(is.na(.)))
# imputing with the median
df <- df %>% 
  mutate(TotalCharges = replace(TotalCharges,
                                is.na(TotalCharges),
                                median(TotalCharges, na.rm = T)))

# removing customerID; doesn't add any value to the model
df <- df %>% select(-customerID)
library(caret)

# selecting random seed to reproduce results
set.seed(100)
# sampling 75% of the rows
inTrain <- sample(1:nrow(df),nrow(df)*0.75)
# train/test split; 75%/25%
train <- df[inTrain,]
test <- df[-inTrain,]


# fitting the model 

fit <- glm(Churn~., data=train, family=binomial)
summary(fit)

# making predictions

churn.probs <- predict(fit, test, type="response")
head(churn.probs)

# Looking at the response encoding
contrasts(df$Churn)

# converting probabilities to "Yes" and "No" 
glm.pred = ifelse(churn.probs>0.5,"Yes","No")
glm.pred <- as.factor(glm.pred)


# creating a confusion matrix
confusionMatrix(glm.pred, test$Churn, positive = "Yes")

# plotting ROC curve

par(pty="s")
roc(train$Churn,fit$fitted.values,plot = TRUE,
    legacy.axes=TRUE,percent = TRUE,
    xlab= "False Positive Percentage",
    ylab="True Positive Percentage",col="#377eb8",
    lwd=4,print.auc=TRUE)
par(pty="m")


######################################################################33

#K-fold Cross Validation

# setting a seed for reproduceability
set.seed(10)

#changing the positive class to "Yes"
df$Churn <- as.character(df$Churn)
df$Churn[df$Churn == "No"] <- "Y"
df$Churn[df$Churn == "Yes"] <- "N"
df$Churn[df$Churn == "Y"] <- "Yes"
df$Churn[df$Churn == "N"] <- "No"

# train control
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated 3 times
  repeats = 3,
  classProbs = TRUE,
  summaryFunction = twoClassSummary)

# logistic regression model

logreg <- train(Churn ~., df,
                method = "glm",
                family = "binomial",
                trControl = fitControl,
                metric = "ROC")
logreg

###########################################################

# threshold vector
thresh <- seq(0.1,1.0, length = 10)

#cost vector
cost = rep(0,length(thresh))

for(i in 1:length(thresh)){
  
  glm.pred = ifelse(churn.probs>thresh[i],"Yes","No")
  glm.pred <- as.factor(glm.pred)
  x<- confusionMatrix(glm.pred, test$Churn, positive = "Yes")
  
  TN = x$table[1]/1761
  FP = x$table[2]/1761
  FN = x$table[3]/1761
  TP = x$table[4]/1761
    
  cost[i]= FN*300+TP*60+FP*60+TN*0
  
}

# simple model - assume threshold is 0.5

glm.pred = ifelse(churn.probs>0.5,"Yes","No")
glm.pred <- as.factor(glm.pred)

x <- confusionMatrix(glm.pred, test$Churn, positive = "Yes")
TN <- x$table[1]/1760
FP <- x$table[2]/1760
FN <- x$table[3]/1760
TP <- x$table[4]/1760
cost_simple = FN*300 + TP*60 + FP*60 + TN*0


# putting results in a dataframe for plotting
dat <- data.frame(
  model = c(rep("optimized",10),"simple"),
  cost_per_customer = c(cost,cost_simple),
  threshold = c(thresh,0.5)
)

# plotting
ggplot(dat, aes(x = threshold, y = cost_per_customer, group = model, colour = model)) +
  geom_line() +
  geom_point()






