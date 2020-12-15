
########################### Data Transformation ########################### 

### Libraries 
library(readxl)
library(dplyr)
library(caret)
library(DMwR)


########## Read data and clean ##########################
data<-data.frame(read_xls("default_creditcard.xls", col_names = TRUE))
colnames(data)<-data[1,]
data<-data[-1,]

data<-data.frame(sapply(data,as.numeric))
data$SEX<-ifelse(data$SEX == 1, "Male","Female")
data$EDUCATION<-ifelse(data$EDUCATION == 1, "Graduate School",
                       ifelse(data$EDUCATION == 2, "University",
                              ifelse(data$EDUCATION == 3, "High School","Others")))
data$MARRIAGE<-ifelse(data$MARRIAGE == 1, "Married",
                      ifelse(data$MARRIAGE == 2,"Single","Others"))
names(data)[names(data) == "default.payment.next.month"]<-"DEFAULT"
names(data)[names(data) == "PAY_0"]<-"PAY_1"
data<-data[data$EDUCATION != "Others" & data$MARRIAGE != "Others",]

data<-data[,-1]


########## Encoding Variables ##########################
# Target mean Encoding.
training.targetMean<-data

encoding.target.sex<-training.targetMean%>%group_by(SEX) %>%summarise(sex_target = mean(DEFAULT))
encoding.target.education<-training.targetMean%>%group_by(EDUCATION) %>%summarise(education_target = mean(DEFAULT))
encoding.target.marriage<-training.targetMean%>%group_by(MARRIAGE) %>%summarise(marriage_target = mean(DEFAULT))

training.targetMean<-left_join(training.targetMean, encoding.target.sex)
training.targetMean<-left_join(training.targetMean, encoding.target.education)
training.targetMean<-left_join(training.targetMean, encoding.target.marriage)

training.targetMean[,"SEX"]<-training.targetMean[,"sex_target"]
training.targetMean[,"EDUCATION"]<-training.targetMean[,"education_target"]
training.targetMean[,"MARRIAGE"]<-training.targetMean[,"marriage_target"]

training.targetMean<-select(training.targetMean,-c("sex_target","education_target","marriage_target"))




# Frequency Encoding.
training.frequencyEncoding<-data

encoding.freq.sex<-training.frequencyEncoding%>%group_by(SEX)%>%summarise(n = n())%>%mutate(sex_freq=n/sum(n))%>%select(SEX,sex_freq)
encoding.freq.education<-training.frequencyEncoding%>%group_by(EDUCATION)%>%summarise(n = n())%>%mutate(edu_freq=n/sum(n))%>%select(EDUCATION,edu_freq)
encoding.freq.marriage<-training.frequencyEncoding%>%group_by(MARRIAGE)%>%summarise(n = n())%>%mutate(marriage_freq=n/sum(n))%>%select(MARRIAGE,marriage_freq)

training.frequencyEncoding<-left_join(training.frequencyEncoding, encoding.freq.sex)
training.frequencyEncoding<-left_join(training.frequencyEncoding, encoding.freq.education)
training.frequencyEncoding<-left_join(training.frequencyEncoding, encoding.freq.marriage)

training.frequencyEncoding[,"SEX"]<-training.frequencyEncoding[,"sex_freq"]
training.frequencyEncoding[,"EDUCATION"]<-training.frequencyEncoding[,"edu_freq"]
training.frequencyEncoding[,"MARRIAGE"]<-training.frequencyEncoding[,"marriage_freq"]

training.frequencyEncoding<-select(training.frequencyEncoding,-c("sex_freq","edu_freq","marriage_freq"))


# One Hot Encoding.
training.onehotEconding<-data
dummy <- dummyVars(" ~ .", data = training.onehotEconding)
training.onehotEconding <- data.frame(predict(dummy, newdata = training.onehotEconding))




training.onehotEconding
########## Create folds ################################
# standardisation 

training.targetMean.scale<-training.targetMean %>% mutate_at(c(1:23), funs(c(scale(.))))
training.frequencyEncoding.scale<-training.frequencyEncoding %>% mutate_at(c(1:23), funs(c(scale(.))))
training.onehotEconding.scale<-training.onehotEconding %>% mutate_at(c(1,9:27), funs(c(scale(.))))

## k-fold and SMOTE Oversampling 


kfold<-function(df,n,smote){
  set.seed(1)
  df$DEFAULT<-as.factor(df$DEFAULT)
  df<-df[sample(nrow(df)),]
  folds<-cut(seq(1,nrow(df)),breaks=n,labels=FALSE)
  folds.list<-list()
  for(i in 1:n){
    testIndexes<-which(folds==i,arr.ind=TRUE)
    testData<-df[testIndexes,]
    trainData<-df[-testIndexes,]
    if (smote == "yes"){ ## SMOTE
      trainData<-SMOTE(DEFAULT ~ .,df, perc.over = 100,perc.under = 200) #without considering Default
      testData$SET.IS<-"TEST"
      trainData$SET.IS<-"TRAINING"
      final.set<-rbind(trainData,testData)
      folds.list[[i]]<-final.set
    } else{
      testData$SET.IS<-"TEST"
      trainData$SET.IS<-"TRAINING"
      final.set<-rbind(trainData,testData)
      folds.list[[i]]<-final.set
    }
  }
  return(folds.list)
}


kfold.targetMean.scale<-kfold(training.targetMean.scale,10,"yes")
kfold.frequencyEncoding.scale<-kfold(training.frequencyEncoding.scale,10,"yes")
kfold.onehotEncoding.scale<-kfold(training.onehotEconding.scale,10,"yes")

kfold.targetMean.scale.nosmote<-kfold(training.targetMean.scale,10,"no")
kfold.frequencyEncoding.scale.nosmote<-kfold(training.frequencyEncoding.scale,10,"no")
kfold.onehotEncoding.scale.nosmote<-kfold(training.onehotEconding.scale,10,"no")


