# Setting working directory

setwd("/home/gc/Projects/Click-Fraud-Detection/code")
getwd()

library(data.table)
library(ggplot2)
library(dplyr)

# Reading the full csv data

data_full <- fread("../dataset/train.csv")
gc() #  Free up memrory and report the memory usage.

# Balancing the data accoring to the target variable

data_positive <- data_full[is_attributed == 1,]
n <- nrow(data_positive)
data_negative <- sample_n(data_full,n) %>% filter(is_attributed == 0)
data_full <- NULL
gc() #  Free up memrory and report the memory usage.

data <- rbind(data_negative,data_positive)
fwrite(data,"../dataset/data.csv")
