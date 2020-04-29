# Analyzing-Customer-Churn

#### linear classifier: Logistic regression  
 

### 	Increasing customer retention rate to decrease cost

## Abstract

Any one work in the telecommunications industry, can understand the importance of customer churn to the bottom line. When a customer leaves, the company lose not only a recurring source of revenue, but also the marketing dollars they paid out to bring them in. As such, small changes in customer churn can easily profitable the business. In this paper we will build a customer churn predictive model that shows a significant business impact (cost savings).


## Introduction

Telco data is dataset contains 21 features and 7,043 rows, with various features such as Totalcharges and tenure. The output that we’re going to try and predict is “churn”.
After looking at Telco data, we’ve identified that it’s about five times more expensive to acquire new customers than retain existing ones. So, we will try to increase customer retention rate to decrease cost.


## Approach
Logistic regression is a linear classifier. Since we’re trying to predict “churn” or “didn’t churn” a classification model is exactly what we need, and to evaluate our model we will  use a series of machine learning evaluation metrics (ROC, AUC, sensitivity, specificity) as well as business oriented metrics (cost savings).



## Method

We take advantage of the Tidyverse library. we start by importing the data from github, since this is a csv file, we used the read_csv function to read the data into a dataframe df, then we mutated the character variables to factors, also we changed the SeniorCitizen variable from an integer to a factor. And replaced the missing values by median.
To make sure that we’re not overfitting our model, we split the data into a training set and a test set. This is known as cross validation.
To implement a logistic regression model, we used the generalized linear models (GLM) function, then we summarized the fit, the following is the result:


![9](https://user-images.githubusercontent.com/58350018/80562652-f3272d80-89ad-11ea-949a-e59d8b868706.jpg)




 
Result shows that only six variables are significant:  tenure, ContractOne year, ContracTow year, PaperLessBillingYear, PaymentMethodelectronic check, and TotalCharges.
After we fit our model, we saw how it performs, we made predictions using the test data set. We passed in the fit model from the previous section. To predict the probabilities, we specified type=” response”, then we convert these probabilities to a binary response, then we evaluate our model using confusing matrix, the following is the result:


![10](https://user-images.githubusercontent.com/58350018/80562653-f6221e00-89ad-11ea-8563-3ebcbe5bd5f2.jpg)


 

We can see that the model correctly predicted “No” 1167 times, and incorrectly predicted “No” when the actual response was “Yes” 213 times.
Likewise, the model correctly predicted “Yes” when the actual answer was “Yes” 254 times. At the same time, it incorrectly predicted “Yes” when the actual response was “No” 126 times. And overall accuracy is 81%.

Also, result shows some other useful metrics, sensitivity and specificity. Since our classes are slightly imbalanced (~73%=“No”, ~27%=“Yes”) these metrics can be more useful.

Sensitivity tells us that 54% of the customers who churn, were correctly identified by the Logistic Regression model.
Specificity tell us that 90% of the customers who didn’t churn, were correctly identified by the Logistic Regression model. 
Another useful metric is the Area Under the Receiver Operating Characteristic (ROC) Curve, also known as AUC.
the ROC is a plot of the True Positive Rate vs. the False Positive Rate.
We made a plot of the ROC curve using the pROC library. Here’s the result:



![11](https://user-images.githubusercontent.com/58350018/80562662-fde1c280-89ad-11ea-9b08-e83a8920b8a9.png)



 
The AUC can take on any value between 0 and 1, with 1 being the best. This is a convenient way to boil down the ROC to a single number for evaluating a model. Our model has an AUC of 0.85, which is pretty good. 
So, we know that our model is at least adding some value!, and to improve our model we will used a better approach called K-fold Cross Validation, we  randomly partition the data in to test and training sets by specifying a certain number of “folds”( k=10). 
After we run the model on each fold, we average the evaluation metric from each one. So, if we ran the model ten times using ROC, we would average each of the ten ROC values together. This is a great way to try and prevent overfitting a model.
We also repeat the process 3 times, just to add a little bit more technical rigor to our approach. And we changed the positive class to “Yes” right before the code for the trainControl function. We did this so that we could compare the sensitivity and specificity with our previous results. Here’s the result:


![12](https://user-images.githubusercontent.com/58350018/80562665-00dcb300-89ae-11ea-8395-3cf0a4744be3.jpg)

 


The results are almost similar to what we got previously. As before, our AUC is 0.85. This is reported in the output as ROC, but it’s actually the AUC.
The true positive rate (sensitivity) is 0.55 and the true negative rate (specificity) is 0.90.

So far, we’ve used k-fold cross validation and logistic regression to predict customer churn.
Our actual goal with developing this model is to show a business impact (cost savings).
To do that we made some assumptions about some various costs as follow:
#### •	Assumed that customer acquisition cost in the telecom industry is approximately $300. 
#### •	Assumed that it’s 5 times more expensive to acquire a new customer rather than retain an existing one. So, around $60 to retain that customer.


Here’s a quick summary of the costs:

#### 	FN (predict that a customer won’t churn, but they actually do): $300
#### 	TP (predict that a customer would churn, when they actually would): $60
#### 	FP (predict that a customer would churn, when they actually wouldn’t): $60
#### 	TN (predict that a customer won’t churn, when they actually wouldn’t): $0

If we multiply the number of each prediction type (FN, TP, FP, and TN) by the cost associated with each and sum them up, then we can calculate the total cost associated with our model. Here’s what that equation looks like:
Cost = FN($300) + TP($60) + FP($60) + TN($0)
Then we applied this cost evaluation to our model.
We start by fitting the model and making predictions in the form of probabilities. Next, we created a threshold vector and a cost vector, and we created a for loop to make predictions using the various thresholds and evaluate the cost of each as we go.

Rather than use the total number of each outcome for TN, FP, FN, and TP, we used a percentage instead. That’s why we pulled each value out using the confusion matrix and divided by 1760.
There’s 1760 observations in our test set, so that’s where that number comes from. By doing it this way we’re calculating the cost per customer.
Now if we assumed that the company is currently using what we’ll call a “simple model” which just defaults to a threshold of 0.5.
Finally, we can put all of the results in a dataframe and plot them, the following is the result:


![13](https://user-images.githubusercontent.com/58350018/80562667-04703a00-89ae-11ea-89de-339f276d4cf2.png)

 


Looking at the results, we can see that the minimum cost per customer is about $40.00 at a threshold of 0.2.
The “simple” model that our company is currently implementing costs about $48.00 per customer, at a threshold of 0.50.
If we assume that we have a customer base of approximately 500,000 the switching from the simple model to the optimized model produces a cost savings of $4MM.
This type of cost savings could be a significant business impact depending on the size of the business.


## Conclusion

In this paper we developed a machine learning model to predict customer churn.
Specifically, we walked through each of the following steps:

### 	Business Background
### 	Logistic Regression
### 	Preparing The Data
### 	Fitting The Model
### 	Making Predictions
### 	Business Impact


We concluded by developing an optimized logistic regression model for our customer churn problem.
Assuming the company is using a logistic regression model with a default threshold of 0.5, we were able to identify that the optimum threshold is actually 0.2.
This reduced cost per customer from $48.00 to $40.00. With a customer base of approximately 500,000 this would produce a yearly cost savings of $4MM.








