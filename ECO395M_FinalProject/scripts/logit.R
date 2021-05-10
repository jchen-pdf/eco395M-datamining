###################
####LOGIT MODEL####
###################
#import packages
library(gamlr)
library(caTools)
library(caret)

#train/test split
sample <- sample.split(chess.dum,SplitRatio = 0.7)
chess.dum.train <- subset(chess.dum,sample==TRUE)
chess.dum.test <- subset(chess.dum,sample==FALSE)

#logit model
x <- model.matrix(~.+.*white_rating+.*black_rating,data=chess.dum.train %>% mutate(winner=NULL))
y <- chess.dum.train$winner
chess.logit <- cv.gamlr(x,y,family='binomial',nfold=10)

#non-zero logit coefficents
coef(chess.logit)[coef(chess.logit)!=0]

#logit confusion matrix and accuracy curve
chess.logit.predict <- predict(chess.logit,model.matrix(~.+.*white_rating+.*black_rating,data=chess.dum.test %>% mutate(winner=NULL)),type='response')

thresholds <- seq(0.1,0.9,0.005)
accuracy <- rep(NA,length(thresholds))
for(i in 1:length(accuracy)){
  accuracy[i] <- confusionMatrix(factor({chess.logit.predict>thresholds[i]}+0),factor(chess.dum.test$winner))$overall[1]
}
plot(data.frame(thresholds,accuracy))
data.frame(thresholds,accuracy)[which(max(accuracy)==accuracy),]