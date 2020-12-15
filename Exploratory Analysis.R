
########################### Exploratory data analysis########################### 

### Libraries
library(readxl)
library(dplyr)
library(ggplot2)

### Read data

data<-read_xls("default_creditcard.xls", col_names = TRUE)
data<-data.frame(data)
colnames(data)<-data[1,]
data<-data[-1,]

#### Clean data: variables are character #######

data.clean<-data.frame(sapply(data,as.numeric))
data.clean$SEX<-ifelse(data$SEX == 1, "Male","Female")
data.clean$EDUCATION<-ifelse(data$EDUCATION == 1, "Graduate School",
                             ifelse(data$EDUCATION == 2, "University",
                                    ifelse(data$EDUCATION == 3, "High School","Others")))
data.clean$MARRIAGE<-ifelse(data$MARRIAGE == 1, "Married",
                            ifelse(data$MARRIAGE == 2,"Single","Others"))
names(data.clean)[names(data.clean) == "default.payment.next.month"]<-"DEFAULT"
names(data.clean)[names(data.clean) == "PAY_0"]<-"PAY_1"

#### Summary 

summary(data.clean[,c(2,6:24)])

#### Count Genre ####
data.clean%>%
  group_by(SEX)%>%
  summarise(count = n())%>%
  mutate(countTotal = sum(count),percentage = count/countTotal)%>%
  arrange(-percentage)%>%
  mutate(percentageT=cumsum(percentage))

data.clean%>%
  group_by(EDUCATION)%>%
  summarise(count = n())%>%
  mutate(countTotal = sum(count),percentage = count/countTotal)%>%
  arrange(-percentage)%>%
  mutate(percentageT=cumsum(percentage))


data.clean%>%
  group_by(MARRIAGE)%>%
  summarise(count = n())%>%
  mutate(countTotal = sum(count),percentage = count/countTotal)%>%
  arrange(-percentage)%>%
  mutate(percentageT=cumsum(percentage))


# Combined analysis

View(data.clean%>%
       group_by(EDUCATION,MARRIAGE)%>%
       summarise(count = n())%>%
       ungroup()%>%
       mutate(countTotal = sum(count),percentage = count/countTotal)%>%
       arrange(-percentage)%>%
       mutate(percentageT=cumsum(percentage)))

# Correlation between variables independant variables (numericals)

correlation.matrix<-cor(data.clean[,c(2,6:24)])

# Charts to check the relationship between the dependant variable and the categorial variables

data.clean%>%
  group_by(DEFAULT)%>%
  summarise(count = n())%>%
  mutate(percentage = count/sum(count))%>%
  ggplot(aes(x = as.factor(DEFAULT), y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity")+
  geom_text(aes(label = paste(round(percentage,2)*100,"%","")))

data.clean%>%
  group_by(SEX,DEFAULT)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = SEX, y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity")+
  geom_text(aes(label = paste(round(percentage,2)*100,"%","")))

data.clean%>%
  group_by(EDUCATION,DEFAULT)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = EDUCATION, y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity")+
  geom_text(aes(label = paste(round(percentage,2)*100,"%","")))


# Check age and Others

aggregate(data.clean$AGE,by = list(data.clean$EDUCATION),mean)

# Histogram Age 

ggplot(data.clean, aes(x = AGE, color=as.factor(DEFAULT)))+
  geom_histogram(fill="white", position="dodge")
theme(legend.position="top",alpha=0.5, position="identity")+
  scale_color_brewer(palette="Dark2")+
  theme_classic()

# Histogram Limit_Bal 

ggplot(data.clean, aes(x = LIMIT_BAL, color=as.factor(DEFAULT)))+
  geom_histogram(fill="white", position="dodge")
theme(legend.position="top",alpha=0.5, position="identity")+
  scale_color_brewer(palette="Dark2")+
  theme_classic()

# boxplots

boxplot(data.clean$LIMIT_BAL ~ data.clean$EDUCATION, ylab = "LIMIT_BAL",xlab = "Education", main = "LIMIT_BAL vs Education")

boxplot(data.clean[data.clean$EDUCATION == "University", "LIMIT_BAL"] ~ data.clean[data.clean$EDUCATION == "University", "DEFAULT"],
        main = "Limit_Bal-University", ylab = "LIMIT_BAL", xlab = "DEFAUL")

boxplot(data.clean[data.clean$EDUCATION == "Graduate School", "LIMIT_BAL"] ~ data.clean[data.clean$EDUCATION == "Graduate School", "DEFAULT"],
        main = "Limit_Bal-Graduate School", ylab = "LIMIT_BAL", xlab = "DEFAUL")


# MANOVA
stat.manova<-manova(cbind(PAY_AMT1,PAY_AMT2,PAY_AMT3,PAY_AMT4,PAY_AMT5,PAY_AMT6)~DEFAULT, data = data.clean)
summary(stat.manova)
summary.aov(stat.manova)

stat.manova<-manova(cbind(BILL_AMT1,BILL_AMT2,BILL_AMT3,BILL_AMT4,BILL_AMT5,BILL_AMT6)~DEFAULT, data = data.clean)
summary(stat.manova)
summary.aov(stat.manova)

stat.manova<-manova(cbind(PAY_1,PAY_2,PAY_3,PAY_4,PAY_5,PAY_6)~DEFAULT, data = data.clean)
summary(stat.manova)
summary.aov(stat.manova)



######################### Charts 

data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  ggplot(.,aes(DEFAULT, fill = DEFAULT))+
  geom_bar(aes(y = (..count..)/sum(..count..)), width = 0.5)+
  geom_text(aes( label = scales::percent((..count..)/sum(..count..)),
                 y= (..count..)/sum(..count..) ), stat= "count",vjust = -.5,size = 5)+
  scale_fill_manual(values=c("orange2","dodgerblue4"))+
  scale_y_continuous(labels = scales::percent, limits = c(0,1))+
  ylab("% Percentage of Instaces")+
  xlab("")+
  ggtitle("Proportion of default and non-default instances")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))

####### 2. 

data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  group_by(SEX,DEFAULT)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = SEX, y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity", width = 0.5)+
  geom_text(aes(label = paste(round(percentage,2)*100,"%",""),color =DEFAULT),size = 5,show.legend = FALSE,position =position_stack(vjust = 0.5))+
  scale_y_continuous(labels = scales::percent, limits = c(0,1))+
  scale_fill_manual(values=c("orange2","dodgerblue4"))+
  ylab("% Percentage of Instaces")+
  xlab("")+
  ggtitle("Proportion of default and non-default records by gender")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))+
  # guides(fill = guide_legend(reverse = T))+
  scale_color_manual(values = c("black","white"))




####### 3. 

data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  group_by(EDUCATION,DEFAULT)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = EDUCATION, y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity", width = 0.5)+
  geom_text(aes(label = paste(round(percentage,2)*100,"%",""),color =DEFAULT),size = 5,show.legend = FALSE,position =position_stack(vjust = 0.5))+
  scale_y_continuous(labels = scales::percent, limits = c(0,1))+
  scale_fill_manual(values=c("orange2","dodgerblue4"))+
  ylab("% Percentage of Instaces")+
  xlab("")+
  ggtitle("Proportion of default and non-default records by education")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))+
  scale_color_manual(values = c("black","white"))


######### 4.

data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  group_by(MARRIAGE,DEFAULT)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = MARRIAGE, y = percentage, fill = as.factor(DEFAULT)))+
  geom_bar(stat = "identity", width = 0.5)+
  geom_text(aes(label = paste(round(percentage,2)*100,"%",""),color =DEFAULT),size = 5,show.legend = FALSE,position =position_stack(vjust = 0.5))+
  scale_y_continuous(labels = scales::percent, limits = c(0,1))+
  scale_fill_manual(values=c("orange2","dodgerblue4"))+
  ylab("% Percentage of Instaces")+
  xlab("")+
  ggtitle("% of default and non-default records by marital status")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))+
  scale_color_manual(values = c("black","white"))



########### 5.
ggplot(data.clean, aes(x = AGE, color=as.factor(DEFAULT),fill = as.factor(DEFAULT)))+
  geom_histogram(color = "white",position="identity")+
  scale_fill_manual(values=c("dodgerblue4","orange2"), labels = c("Non Default","Default"))+
  ggtitle("Distribution of the Age attribute")+
  ylab("Count")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))


########### 6.
ggplot(data.clean, aes(x = LIMIT_BAL, color=as.factor(DEFAULT),fill = as.factor(DEFAULT)))+
  geom_histogram(color = "white",position="identity")+
  scale_fill_manual(values=c("dodgerblue4","orange2"), labels = c("Non Default","Default"))+
  ggtitle("Distribution of the LIMIT_BAT attribute")+
  ylab("Count")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))




#################### Scatterplot ########################
options(scipen=10000)
data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  ggplot(aes(x = PAY_6, y = BILL_AMT6,color=DEFAULT))+
  geom_point(size = 3)+
  scale_color_manual(values=c("orange2","dodgerblue4"))+
  ggtitle("BILL_AMT6 vs PAY_6")+
  scale_x_continuous(breaks = unique(data.clean$PAY_6))+
  theme_bw()+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 16),
        axis.text.y = element_text(color = "black", size = 16),
        axis.title = element_text(size = 16))


data.clean%>%
  mutate(DEFAULT = ifelse(DEFAULT == 0,"Non Default","Default"))%>%
  ggplot(aes(x = PAY_6, y = PAY_AMT6,color=DEFAULT))+
  geom_point(size = 3)+
  scale_color_manual(values=c("orange2","dodgerblue4"))+
  ggtitle("PAY_AMT6 vs PAY_6")+
  scale_x_continuous(breaks = unique(data.clean$PAY_6))+
  theme_bw()+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 15),
        axis.text.x = element_text(color = "black", size = 15),
        axis.text.y = element_text(color = "black", size = 15),
        axis.title = element_text(size = 15))


#### charts
data.clean%>%
  group_by(MARRIAGE)%>%
  summarise(count = n())%>%
  mutate(countT=sum(count), percentage = count/countT)%>%
  ggplot(aes(x = reorder(MARRIAGE,-percentage), y = percentage))+
  geom_bar(stat = "identity", width = 0.5, fill = "dodgerblue4")+
  geom_text(aes(label = paste(round(percentage,2)*100,"%",""), color = "white"),size = 6,show.legend = FALSE,position =position_stack(vjust = 1.2))+
  scale_y_continuous(labels = scales::percent, limits = c(0,1))+
  ylab("% Percentage of Instaces")+
  xlab("")+
  ggtitle("MARRIAGE")+
  theme(panel.background = element_rect(fill = NA, colour = "black", size = .03),
        panel.grid.major = element_line(colour = "gray90", size = 0.05),
        plot.title = element_text(hjust = 0.5, size = 18),
        legend.position = "top",
        legend.background = element_rect(fill =NA),
        legend.title = element_blank(),
        legend.text = element_text(size = 18),
        axis.text.x = element_text(color = "black", size = 18),
        axis.text.y = element_text(color = "black", size = 18),
        axis.title = element_text(size = 18))+
  scale_color_manual(values = c("black","white"))