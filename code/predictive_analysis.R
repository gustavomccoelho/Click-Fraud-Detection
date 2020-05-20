# Setting working directory

setwd("/home/gc/Projects/Click-Fraud-Detection/code")
getwd()

library(data.table)
library(randomForest)

# Reading csv data

train <- fread("../dataset/train_2.csv")
test <- fread("../dataset/test_2.csv")

# Changing metadata

train$is_attributed <- as.factor(train$is_attributed)
train$hour <- NULL
train$early <- as.factor(train$early)
train$ip_flag <- NULL
train$app_flag <- as.factor(train$app_flag)
train$os_flag <- as.factor(train$os_flag)
train$channel_flag <- as.factor(train$channel_flag)

test$click_id <- NULL
test$hour <- NULL
test$early <- as.factor(test$early)
test$ip_flag <- NULL
test$app_flag <- as.factor(test$app_flag)
test$os_flag <- as.factor(test$os_flag)
test$channel_flag <- as.factor(test$channel_flag)

#*************************************Predictive model*********************************************************

# Random Forest - Accuracy 0.88795 - 100 trees

gc()  # cleaning memory
model <- randomForest(is_attributed~.,train, ntree = 120, nodesize = 10)
gc()  # cleaning memory
prediction <- predict(model,test)

#Saving data - GOOD LUCK!

test <- fread("../dataset/test_2.csv")
kaggle <- data.frame(prediction)
kaggle <- cbind(test$click_id,kaggle)
colnames(kaggle) = c("click_id","is_attributed")

fwrite(kaggle,"../dataset/kaggle.csv")
