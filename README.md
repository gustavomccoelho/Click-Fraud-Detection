##  Business problem definition

Fraud risk is everywhere, but for companies that advertise online, click fraud can happen at an overwhelming volume, resulting in misleading click data and wasted money. Ad channels can drive up costs by simply clicking on the ad at a large scale. With over 1 billion smart mobile devices in active use every month, China is the largest
mobile market in the world and therefore suffers from huge volumes of fradulent traffic.

TalkingData, China’s largest independent big data service platform, covers over 70% of active mobile devices nationwide. They handle 3 billion clicks per day, of which 90% are potentially fraudulent. Their current approach to prevent click fraud for app developers is to measure the journey of a user’s click across their portfolio, and flag IP addresses who produce lots of clicks, but never end up installing apps. With this information, they've built an IP blacklist and device blacklist.

While successful, they want to always be one step ahead of fraudsters and have turned to the Kaggle community for help in further developing their solution. In their 2nd competition with Kaggle, you’re challenged to build an algorithm that predicts whether a user will download an app after clicking a mobile app ad. To support your modeling, they have provided a generous dataset covering approximately 200 million clicks over 4 days!

##  Data

train.csv - the training set

train_sample.csv - 100,000 randomly-selected rows of training data, to inspect data before downloading full set

test.csv - the test set

sampleSubmission.csv - a sample submission file in the correct format

##  Data fields

ip: ip address of click

app: app id for marketing

device: device type id of user mobile phone (e.g., iphone 6 plus, iphone 7, huawei mate 7, etc.)

os: os version id of user mobile phone

channel: channel id of mobile ad publisher

click_time: timestamp of click (UTC)

attributed_time: if user download the app for after clicking an ad, this is the time of the app download

is_attributed: the target that is to be predicted, indicating the app was downloaded

##  How to predict app download

The main strategy behind this script is to use the train data to predict the "is_attributed" variable by comparing it's behaviour with the IP, App, OS, Channel and click time. 

The main challenge is to narrow this predictive variables to a reasonable amount of factor levels, since there can be thousends of unique values for IPs, for example. 

This is done by analysing each predictive variable individually, and assiging ranges where the behaviour is different according to the target variable, such as below:

![Time Distribution](/images/Downloads_by_night_day.png)
![IP Distribution](/images/IP_distribution.png)
![App Distribution](/images/App_distribution.png)
![Channel Distribution](/images/channel_distribution.png)
![OS Distribution](/images/os_distribution.png)

##  Data Balance

The train data has a massive amount of registers, but it is extremelly unbalanced regarding the target variable. For this reason, the data was reshaped to have a 50/50 balance. This reduced the data substantially. 

##  Prediction Model

The chosen predictive model is Random Forest. The model is trained by using a 900.000 size sample from the balanced train sample and 100 trees. The accuracy reached is 0.8875.  

##  How to run scrips

The codes are split into 3 files. The "data_loading.R" creates the balanced train sample used in the remaining scripts. The "exploratory_analysis.R" replaces the original variables by their levels, making it ready for the "prediction_analysis.R".

Using Command Line:
```
Rscript data_loading.R
Rscript exploratory_analysis.R
Rscript predictive_analysis.R
```
##  Points of improvement

To improve the accuracy of this script, the next steps are suggested:

Use a technique to increase the train data size, maintaining the 50/50 balance

Improve the levels assignment, by identifying more precisely the different ranges on each variable

Include more trees during the Random Forest training 
