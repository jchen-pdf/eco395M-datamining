#####################
####RANDOM FOREST####
#####################
#import packages
library(caTools)
library(caret)
library(randomForest)

#train/test split
sample <- sample.split(chess.fac,SplitRatio = 0.7)
chess.fac.train <- subset(chess.fac,sample==TRUE)
chess.fac.test <- subset(chess.fac,sample==FALSE)

#rf model
chess.rf <- randomForest(winner~.,data=chess.fac.train)

#rf accuracy
confusionMatrix(predict(chess.rf,newdata=chess.fac.test),chess.fac.test$winner)

