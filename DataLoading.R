# This is a project to predict the Click Fraud Detection on TalkingData, China’s largest independent big data service platform.
# Data set is available on Kaggle on https://www.kaggle.com/c/talkingdata-adtracking-fraud-detection/overview

setwd("C:/FraudDetection")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Reading the full csv data

data_full <- fread("train.csv")
str(data_full)
head(data_full)

# Checking the target variable balance

table(data_full$is_attributed)

# The data is extremely unbalanced

gc() #  Free up memrory and report the memory usage.

data_positive <- data_full[is_attributed == 1,]
n <- nrow(data_positive)
data_sample <- sample_n(data_full,n)
data_negative <- sample_n(data_full,n) %>% filter(is_attributed == 0)
data_full <- NULL

gc()

data <- rbind(data_negative,data_positive)

# Checking data balance now

table(data$is_attributed)

fwrite(data,"data.csv")

View(data)
