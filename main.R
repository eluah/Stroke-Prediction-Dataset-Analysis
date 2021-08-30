library(corrplot)
library(dplyr)
library(caTools) 
library(caret)
library(e1071)
library(ROSE)
library(stringr)
data <- read.csv('data.csv',header=T)
# summary of our dataset
summary(data)
str(data)
# summary statistics for each variable
# stroke
stroke<-table(data$stroke)
barplot(stroke,main='stroke')
# gender
gender<-table(data$gender)
barplot(gender,main='gender')
# age
age <- hist(data$age,main='age')
multiplier <- age$counts / age$density
den <- density(data$age)
den$y <- den$y * multiplier[1]
lines(den,col='blue')
boxplot(data$age,main='age')
# hypertension
hbp<-table(data$hypertension)
barplot(hbp,main='hypertension')
# heart disease
hd<-table(data$heart_disease)
barplot(hd,main='heart_disease')

# avg glucose level: pre-transformation
sugar <- hist(data$avg_glucose_level,main='avg glucose level')
multiplier <- sugar$counts / sugar$density
den <- density(data$avg_glucose_level)
den$y <- den$y * multiplier[1]
lines(den,col='blue')
boxplot(data$avg_glucose_level,main='avg glucose level')
# checking for normality via shapiro.test()
shapiro.test(data$avg_glucose_level) 
# avg glucose level: post-transformation
lnsugar <- log(data$avg_glucose_level)
ln_sugar <- hist(lnsugar, main="log transformation of avg glucose level")
multiplier <- ln_sugar$counts / ln_sugar$density
den <- density(log(data$avg_glucose_level))
den$y <- den$y*multiplier[1]
lines(den, col="blue")
boxplot(lnsugar, main="post-transformation of avg glucose level")
data1 <- data
data1$avg_glucose_level=log(data1$avg_glucose_level)
# bmi: pre-transformation
bmi <- hist(data$bmi,main='bmi')
multiplier <- bmi$counts / bmi$density
den <- density(data$bmi)
den$y <- den$y * multiplier[1]
lines(den,col='blue')
boxplot(data$bmi[data$bmi<45],main='bmi')
data1<-data1[data1$bmi<65, ]
# checking for normality via shapiro.test(data$bmi[data$bmi<65])
shapiro.test(data1$bmi)
# bmi: post-transformation
lnbmi <- log(data1$bmi)
ln_bmi <- hist(lnbmi, main="log transformation of bmi")
multiplier <- ln_bmi$counts / ln_bmi$density
den <- density(lnbmi)
den$y <- den$y*multiplier[1]
lines(den, col="blue")
boxplot(lnbmi, main="post-transformation of bmi")
data1$bmi=log(data1$bmi)
# smoking status
smoke<-table(data1$smoking_status)
barplot(smoke,main='smoking status')
# correlation matrix of the eight variables
res <- cor(data1)
corrplot(res, type = "upper", order = "hclust", tl.col = "black", tl.srt = 45)
#relation between stroke and age
boxplot(data1$age~data1$stroke)
aov(data1$age~factor(data1$stroke))
summary(aov(data1$age~factor(data1$stroke)))
#relation between stroke and hypertension
table(data1$hypertension,data1$stroke)
chisq.test(table(data1$hypertension,data1$stroke))
#relation between stroke and heart_disease
table(data1$heart_disease,data1$stroke)
chisq.test(table(data1$heart_disease,data1$stroke))
#relation between stroke and avg_glucose_level
boxplot(data1$avg_glucose_level~data1$stroke)
aov(data1$avg_glucose_level~factor(data1$stroke))
# relationship between hypertension and heart_disease
table(data1$hypertension,data1$heart_disease)
chisq.test(table(data1$hypertension,data1$heart_disease))
#Logistic Regression
set.seed(17) 
data2 <- ovun.sample(stroke ~ ., data = data1, method = "over",N = 6490)$data
table(data2$stroke)
sampleSplit <- sample.split(Y=data2$stroke, SplitRatio=0.7) 
trainSet <- subset(x=data2, sampleSplit==TRUE) 
testSet <- subset(x=data2, sampleSplit==FALSE)
model<-glm(stroke~age+hypertension+heart_disease+avg_glucose_level,data=trainSet,family=binomial)
summary(model)
prob <- predict(model, testSet, type='response') 
pred <- ifelse(prob > 0.5, 1, 0)
confusionMatrix(factor(pred), factor(testSet$stroke)))
