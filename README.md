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

##  How to predict demand

The main strategy behind this script is to tag every possible predictive variable by it's mean demand, according to the train data. For example, we know from the 73 million registers in the train data that the main demand for the product "1212" is 2.84. We will then replace the product ID for this value. 

The exploratory analysis phase consists on findind the mean demand from each variable, allocating this values to the train and test datasets, treating na values, etc.

##  Variables not used

The following variables were not used on this script:

~~NombreCliente — Client name~~

~~NombreProducto — Product Name~~

~~Venta_uni_hoy — Sales unit this week (integer)~~

~~Venta_hoy — Sales this week (unit: pesos)~~

~~Dev_uni_proxima — Returns unit next week (integer)~~

~~Dev_proxima — Returns next week (unit: pesos)~~

##  Outliers

99.9% of the demands are placed between 0 and 100. The 0.1% left is spread between 100 and 5000. These outliers were remove to prevent any influence on the mean demands. 

##  Prediction Model

The chosen predictive model is Random Forest. The scrip uses the Ranger package, to improve memory usage efficiancy. The model is trained by using a 10 million size sample from the train data and 100 trees. The R-Square value reached is 0.55.  

##  How to run scrips

The codes are split into 6 files (5 for each variable and 1 for the predictive model), due to the large memory load required to process the train data. Each exploratory scrip creates two new files called "test_variable_x_mean.csv" and "train_variable_x_mean.csv" which contains the list of the x variable mean values according to the test and train data. 

The "exploratory_analysis_1.R" must be the first to run, since it creates an extra file "train_sample.csv" (train file without outliers) which is used as source for the remaining codes. 

Using Command Line:
```
Rscript exploratory_analysis_1.R
Rscript exploratory_analysis_2.R
Rscript exploratory_analysis_3.R
Rscript exploratory_analysis_4.R
Rscript exploratory_analysis_5.R
Rscript predictive_analysis.R
```
