# Setting working directory

setwd("/home/gc/Projects/Click-Fraud-Detection/code")
getwd()

library(ggplot2)
library(dplyr)
library(data.table)

# Reading csv data

data <- fread("../dataset/data.csv")
test_data <- fread("../dataset/test.csv")

# Changing metadata

data$is_attributed <- as.factor(data$is_attributed)
data$click_time <- as.POSIXct(data$click_time)
test_data$click_time <- as.POSIXct(test_data$click_time)

# Removing attributed_time, since it is only valid when the target value is true

data$attributed_time <- NULL

#*************************************Analysing time*********************************************************

# Creating variable called hour

data$hour <- as.factor(hour(data$click_time))
test_data$hour <- as.factor(hour(test_data$click_time))

#ggplot(data,aes(x=hour,fill=is_attributed)) +
#                  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
#                  ggtitle("App downloads by hour")

# It looks like the is_attributed variable is slightly more likelly to be 1 during 1:00 to 9:00
# So, we will make a variable to indicate that

data$early <- as.factor(ifelse(as.integer(data$hour) > 1 & as.integer(data$hour) < 10, 1, 0))
test_data$early <- as.factor(ifelse(as.integer(test_data$hour) > 1 & as.integer(test_data$hour) < 10, 1, 0))

#ggplot(data,aes(x=early,fill=is_attributed)) +
#                  geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
#                  ggtitle("App downloads by night/day clicks")

#*************************************Analysing IPs*********************************************************

#ggplot(data) + geom_histogram(aes(x=ip,fill=is_attributed),color="#e9ecef", alpha=0.6, position = 'identity') +ggtitle("IP distribution")

# There are 2 ranges where the ips are more or less likely to return 1
# Lets make a new variable to reflect that

data$ip_flag <- as.factor(ifelse(data$ip <= 213000, 1, 0))
test_data$ip_flag <- as.factor(ifelse(as.integer(test_data$ip) <= 213000, 1, 0))

#*************************************Analysing apps*********************************************************

#ggplot(data,aes(x=app,fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 5) +
#        ggtitle("app distribution")

#ggplot(filter(data, app < 50),aes(x=app,fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 5) +
#        ggtitle("app distribution")

# app seems to be distinctable when in the range 0 to 29
# Let make a variable called app_range to take advantage of this

data$app_range <- as.factor(ifelse(data$app < 29,data$app,29))
test_data$app_range <- as.factor(ifelse(test_data$app < 29,test_data$app,29))

#ggplot(data,aes(x=app_range,fill=is_attributed)) +
#        geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
#        ggtitle("app_range distribution")

# Creating app_flag

data$app_flag <- as.factor(ifelse(data$app_range==5|data$app_range==10|data$app_range==19|data$app_range==29,1,0))
test_data$app_flag <- as.factor(ifelse(test_data$app_range==5|test_data$app_range==10|test_data$app_range==19|test_data$app_range==29,1,0))

#*************************************Analysing OSs*********************************************************

#ggplot(data,aes(x=os, fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
#        ggtitle("os distribution")

#ggplot(filter(data, os < 30),aes(x=os, fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 1) +
#        ggtitle("os distribution")

# os seems to be distinctable when in the range 0 to 30

data$os_range <- as.factor(ifelse(data$os < 30,data$os,30))
test_data$os_range <- as.factor(ifelse(test_data$os < 30,test_data$os,30))

#ggplot(data,aes(x=os_range,fill=is_attributed)) +
#        geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
#        ggtitle("os_range distribution")

# creating os_flag

data$os_flag <- as.factor(ifelse(data$os_range==0|data$os_range==21|data$os_range==24|data$os_range==29|data$os_range==30,1,0))
test_data$os_flag <- as.factor(ifelse(test_data$os_range==0|test_data$os_range==21|test_data$os_range==24|test_data$os_range==29|test_data$os_range==30,1,0))

#*************************************Analysing channels*********************************************************

#ggplot(data,aes(x=channel,fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
#        ggtitle("Channel distribution")

#ggplot(filter(data,data$channel>100),aes(x=channel,fill=is_attributed)) +
#        geom_histogram(color="#e9ecef", alpha=0.6, position = 'identity',binwidth = 10) +
#        ggtitle("Channel distribution")

# channel seems to be distinctable when higher than 100

data$channel_range <- as.factor(ifelse(data$channel < 100,0,round(data$channel/10)-9))
test_data$channel_range <- as.factor(ifelse(test_data$channel < 100,0,round(test_data$channel/10)-9))

#ggplot(data, aes(x=channel_ranges, fill=is_attributed)) +
#        geom_bar(color="#e9ecef", alpha=0.6, position = 'identity') +
#        ggtitle("channel_range distribution")

# creating channel_flag

data$channel_flag <- as.factor(ifelse(data$channel_range==0|data$channel_range==1|data$channel_range==2|data$channel_range==12|data$channel_range==18,1,0))
test_data$channel_flag <- as.factor(ifelse(test_data$channel_range==0|test_data$channel_range==1|test_data$channel_range==2|test_data$channel_range==12|test_data$channel_range==18,1,0))

#*************************************Saving data for prediction analysis*********************************************************

# lets remove the initial parameters since they are actually factors and not integers
# using more than 50 levels on a factor is probably not a good idea

data$ip <- NULL
data$app <- NULL
data$device <- NULL
data$os <- NULL
data$channel <- NULL
data$click_time <- NULL
data$app_range <- NULL
data$os_range <- NULL
data$channel_range <- NULL

test_data$ip <- NULL
test_data$app <- NULL
test_data$device <- NULL
test_data$os <- NULL
test_data$channel <- NULL
test_data$click_time <- NULL
test_data$app_range <- NULL
test_data$os_range <- NULL
test_data$channel_range <- NULL

#Saving data

fwrite(data,"../dataset/train_2.csv")
fwrite(test_data,"../dataset/test_2.csv")