# This is a project to predict the Click Fraud Detection on TalkingData, China’s largest independent big data service platform.
# Data set is available on Kaggle on https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/overview

setwd("C:/FraudDetection")
getwd()

library(ggplot2)
library(dplyr)
library(data.table)
library(randomForest)
library(caret)
library(e1071)

# Reading csv data

data <- fread("data.csv")
str(data)
View(data)

# Changing metadata

data$is_attributed <- as.factor(data$is_attributed)
data$click_time <- as.POSIXct(data$click_time)

# Removing attributed_time, since it is only valid when the target value is true

data$attributed_time <- NULL

# Looking for NA Values

lapply(data,function(x) sum(is.na(x)))

# Creating variable called hour

data$hour <- as.factor(hour(data$click_time))

ggplot(data,aes(x=hour,fill=is_attributed)) +
                  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
                  ggtitle("IP distribution")

# It looks like the is_attributed variable is slightly more likelly to be 1 during 1:00 to 9:00
# So, we will make a variable to indicate that

data$early <- ifelse(as.integer(data$hour)>1&as.integer(data$hour)<10,1,0)
data$early <- as.factor(data$early)

ggplot(data,aes(x=early,fill=is_attributed)) +
                  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
                  ggtitle("IP distribution")

# Analysing the IPs

ggplot(data,aes(x=is_attributed,y=ip, fill=is_attributed)) +
                    geom_boxplot() +
                    ggtitle("IP distribution")

ggplot(filter(data,ip>130000),aes(x=ip,fill=is_attributed)) +
                    geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 2000) +
                    ggtitle("IP distribution")

# There are 2 ranges where the ips are more or less likely to return 1
# Lets make a new variable to reflect that

data$ip_flag <- ifelse(as.integer(data$ip)<=213000,1,0)
data$ip_flag <- as.factor(data$ip_flag)

# Analysing app

ggplot(data,aes(x=app,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 5) +
  ggtitle("app distribution")

ggplot(filter(data,app<50),aes(x=app,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 1) +
  ggtitle("app distribution")

# app seems to be distinctable when in the range 0 to 29
# Let make a variable called app_range to take advantage of this

data$app_range <- ifelse(data$app < 29,data$app,29)
data$app_range <- as.factor(data$app_range)

ggplot(data,aes(x=app_range,fill=is_attributed)) +
  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
  ggtitle("app_range distribution")

# Creating app_flag

data$app_flag <- ifelse(data$app_range==5|data$app_range==10|data$app_range==19|data$app_range==29,1,0)
data$app_flag <- as.factor(data$app_flag)

# Analysing the OSs

ggplot(data,aes(x=os,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
  ggtitle("os distribution")

ggplot(filter(data,os<30),aes(x=os,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 1) +
  ggtitle("os distribution")

# os seems to be distinctable when in the range 0 to 30

data$os_range <- ifelse(data$os < 30,data$os,30)
data$os_range <- as.factor(data$os_range)

ggplot(data,aes(x=os_range,fill=is_attributed)) +
  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
  ggtitle("os_range distribution")

# creating os_flag

data$os_flag <- ifelse(data$os_range==0|data$os_range==21|data$os_range==24|data$os_range==29|data$os_range==30,1,0)
data$os_flag <- as.factor(data$os_flag)

# Analysing the channel

ggplot(data,aes(x=channel,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
  ggtitle("Channel distribution")

ggplot(filter(data,data$channel>100),aes(x=channel,fill=is_attributed)) +
  geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
  ggtitle("Channel distribution")

# channel seems to be distinctable when higher than 100

data$channel_ranges <- ifelse(data$channel < 100,0,round(data$channel/10)-9)
data$channel_ranges <- as.factor(data$channel_ranges)

ggplot(data,aes(x=channel_ranges,fill=is_attributed)) +
  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
  ggtitle("channel_range distribution")

# creating channel_flag

data$channel_flag <- ifelse(data$channel_range==0|data$channel_range==1|data$channel_range==2|data$channel_range==12|data$channel_range==18,1,0)
data$channel_flag <- as.factor(data$channel_flag)

# lets remove the initial parameters since they are actually factors and not integers
# using more than 50 levels on a factor is probably not a good idea

data$ip <- NULL
data$app <- NULL
data$device <- NULL
data$os <- NULL
data$channel <- NULL
data$click_time <- NULL

# Feature selection

model <- randomForest(is_attributed~.,data,ntree = 100, nodesize = 10, importance = T)
varImpPlot(model)

# Spliting train and test data

nrows <- unique(round(runif(nrow(data)*1.2,1,nrow(data))))
train_data <- data[nrows,]
test_data <- data[-nrows,]

# First attempt - Accuracy 0.919

model_1 <- randomForest(is_attributed~.,train_data, ntree = 100, nodesize = 10)
prediction_1 <- predict(model_1,test_data)
confusionMatrix(prediction_1,test_data$is_attributed)

# Secound attempt - Accuracy 0.8986

model_2 <- randomForest(is_attributed ~ . -app_range -channel_ranges -hour,train_data, ntree = 100, nodesize = 10)
prediction_2 <- predict(model_2,test_data)
confusionMatrix(prediction_2,test_data$is_attributed)

# Third attempt - Accuracy 0.8976

model_3 <- randomForest(is_attributed ~ . -app_range -channel_ranges -hour -os_range,train_data, ntree = 100, nodesize = 10)
prediction_3 <- predict(model_3,test_data)
confusionMatrix(prediction_3,test_data$is_attributed)

# Forth attempt - Accuracy 0.8957 - chosen model
# Although this is the lowest accurate model, we choose this one to avoid issues with variable ranges and levels between train data and test data

model_4 <- randomForest(is_attributed ~ . -app_range -channel_ranges -hour -os_range -ip_flag,data, ntree = 100, nodesize = 10)
prediction_4 <- predict(model_4,test_data)
confusionMatrix(prediction_4,test_data$is_attributed)

# Testing on train sample

train_sample <- fread("train_sample.csv")

train_sample$is_attributed <- as.factor(train_sample$is_attributed)
train_sample$click_time <- as.POSIXct(train_sample$click_time)
train_sample$attributed_time <- NULL
train_sample$hour <- as.factor(hour(train_sample$click_time))
train_sample$early <- ifelse(as.integer(train_sample$hour)>1&as.integer(train_sample$hour)<10,1,0)
train_sample$early <- as.factor(train_sample$early)
train_sample$ip_flag <- ifelse(as.integer(train_sample$ip)<=213000,1,0)
train_sample$ip_flag <- as.factor(train_sample$ip_flag)
train_sample$app_range <- ifelse(train_sample$app < 29,train_sample$app,29)
train_sample$app_range <- as.factor(train_sample$app_range)
train_sample$app_flag <- ifelse(train_sample$app_range==5|train_sample$app_range==10|train_sample$app_range==19|train_sample$app_range==29,1,0)
train_sample$app_flag <- as.factor(train_sample$app_flag)
train_sample$os_range <- ifelse(train_sample$os < 30,train_sample$os,30)
train_sample$os_range <- as.factor(train_sample$os_range)
train_sample$os_flag <- ifelse(train_sample$os_range==0|train_sample$os_range==21|train_sample$os_range==24|train_sample$os_range==29|train_sample$os_range==30,1,0)
train_sample$os_flag <- as.factor(train_sample$os_flag)
train_sample$channel_ranges <- ifelse(train_sample$channel < 100,0,round(train_sample$channel/10)-9)
train_sample$channel_ranges <- as.factor(train_sample$channel_ranges)
train_sample$channel_flag <- ifelse(train_sample$channel_range==0|train_sample$channel_range==1|train_sample$channel_range==2|train_sample$channel_range==12|train_sample$channel_range==18,1,0)
train_sample$channel_flag <- as.factor(train_sample$channel_flag)

train_sample$ip <- NULL
train_sample$app <- NULL
train_sample$device <- NULL
train_sample$os <- NULL
train_sample$channel <- NULL
train_sample$click_time <- NULL

# Prediction - Accuracy 0.9615

prediction_sample <- predict(model_4,train_sample)
confusionMatrix(prediction_sample,train_sample$is_attributed)

# Testing on test data

test_data <- fread("test.csv")

test_data$is_attributed <- as.factor(test_data$is_attributed)
test_data$click_time <- as.POSIXct(test_data$click_time)
test_data$hour <- as.factor(hour(test_data$click_time))
test_data$early <- ifelse(as.integer(test_data$hour)>1&as.integer(test_data$hour)<10,1,0)
test_data$early <- as.factor(test_data$early)
test_data$ip_flag <- ifelse(as.integer(test_data$ip)<=213000,1,0)
test_data$ip_flag <- as.factor(test_data$ip_flag)
test_data$app_range <- ifelse(test_data$app < 29,test_data$app,29)
test_data$app_range <- as.factor(test_data$app_range)
test_data$app_flag <- ifelse(test_data$app_range==5|test_data$app_range==10|test_data$app_range==19|test_data$app_range==29,1,0)
test_data$app_flag <- as.factor(test_data$app_flag)
test_data$os_range <- ifelse(test_data$os < 30,test_data$os,30)
test_data$os_range <- as.factor(test_data$os_range)
test_data$os_flag <- ifelse(test_data$os_range==0|test_data$os_range==21|test_data$os_range==24|test_data$os_range==29|test_data$os_range==30,1,0)
test_data$os_flag <- as.factor(test_data$os_flag)
test_data$channel_ranges <- ifelse(test_data$channel < 100,0,round(test_data$channel/10)-9)
test_data$channel_ranges <- as.factor(test_data$channel_ranges)
test_data$channel_flag <- ifelse(test_data$channel_range==0|test_data$channel_range==1|test_data$channel_range==2|test_data$channel_range==12|test_data$channel_range==18,1,0)
test_data$channel_flag <- as.factor(test_data$channel_flag)

test_data$ip <- NULL
test_data$app <- NULL
test_data$device <- NULL
test_data$os <- NULL
test_data$channel <- NULL
test_data$click_time <- NULL

# Prediction - Accuracy 0.8876

prediction_test <- predict(model_4,test_data)

#Saving data

output <- data.frame(prediction_test)
output <- cbind(test_data$click_id,output)
colnames(output) = c("click_id","is_attributed")

fwrite(output,"kaggle.csv")
