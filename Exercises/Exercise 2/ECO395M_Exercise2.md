1 Visualization
===============

Here, the dataset of interest is information on the Capital Metro
running on the bus network in Austin tracking ridership with time.

    data1_avg <- data1 %>% 
                    group_by(hour_of_day,day_of_week,month) %>%
                    summarize(avg = mean(boarding))

    ## `summarise()` has grouped output by 'hour_of_day', 'day_of_week'. You can override using the `.groups` argument.

    ggplot(data = data1_avg) + 
            geom_line(mapping=aes(x=hour_of_day,y=avg,color=month)) + 
            labs(title = 'Avg Boarding over Hour of the Day',x='Hour of the Day',y='Avg Boarding') +
            facet_wrap(~day_of_week)

![Figure 1: The average boarding of Capital Metro buses over
time.](ECO395M_Exercise2_files/figure-markdown_strict/avg%20cap%20metro%20boarding-1.png)
Figure 1 shows the average boarding of Captial Metro buses per day of
the week split on months and day of the week. It can be seen that peak
hours during weekdays are roughly around 4PM which would likely indicate
when school and work may end. From the plots, it can be seen that
average boardings in September on Mondays are lower which might be due
to Labor Day as less people would be using the bus. In addition, Labor
Day would be about 25% of the total Mondays in September, so having a
very low ridership in a single Monday would make a noticeable impact in
average. Ridership appears to be lower on Wednesdays, Thursdays and
Fridays in November. This could be attributed to UT Austin's
Thanksgiving break, which removes many student bus riders from the city.
However, no conclusive conclusions can be drawn without proper analysis.

    ggplot(data = data1) + 
            geom_point(mapping=aes(x=temperature,y=boarding,color=weekend)) +
            facet_wrap(~hour_of_day) +
            labs(title='Boarding over Temperatures',x='Temperature (F)',y='Boarding')

![Figure 2: Boarding verses the temperature faceted hour of the day and
color coded by weekend or
not.](ECO395M_Exercise2_files/figure-markdown_strict/boarding%20vs%20temp-1.png)
By examining these plots in Figure 2, it would appear that the density
of points is lower as the temperature decreases. So, it might give the
confidence to say that bus ridership drops during colder temperatures.

2 Saratoga House Prices
=======================

    #fold the data
    kfolds = 10
    data2 = data2 %>%
      mutate(fold_id = rep(1:kfolds, length=nrow(data2)) %>% sample)

    #base model to beat
    lm3.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
      lm3 <- lm(price ~ (. - pctCollege - sewer - waterfront - landValue - newConstruction)^2, data=filter(data2,fold_id!=fold))
      modelr::rmse(lm3, data=filter(data2, fold_id == fold))
    }

    ## Warning in predict.lm(model, data): prediction from a rank-deficient fit may be
    ## misleading

    ## Warning in predict.lm(model, data): prediction from a rank-deficient fit may be
    ## misleading

    #linear model
    step_lm <- stepAIC(lm(price~.,data=filter(data2,fold_id!=1)),direction='both',trace=FALSE)
    step_lm.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
      step_lm.cv <- lm(step_lm$call, data=filter(data2,fold_id!=fold))
      modelr::rmse(step_lm.cv, data=filter(data2, fold_id == fold))
    }

    #knn (with scaling each fold seperately)
    k <- seq(2,300,1)
    knn.mean_rmse_cv <- rep(0,length(k))
    knn.se_rmse_cv <- rep(0,length(k))
    c <- 1
    for(i in k){
      knn.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
        #rescale the training and testing data
        train <- filter(data2,fold_id!=fold)
        test <- filter(data2, fold_id == fold)
        
        index <- sapply(train, is.numeric)
        index[length(index)] <- FALSE  #take out fold_id
        index[1] <- FALSE #take out price
        
        train[index] <- scale(train[index],scale=apply(train[index],2,sd))
        test[index] <- scale(test[index],scale=apply(train[index],2,sd))
        
        #run knn and get rmse
        knn.cv <- knnreg(price~., data=train,k=i)
        modelr::rmse(knn.cv, data=test)
      }
      knn.mean_rmse_cv[c] <- mean(knn.rmse_cv)
      knn.se_rmse_cv[c] <- sd(knn.rmse_cv)
      c <- c+1
    }
    ggplot(data=data.frame(k,knn.mean_rmse_cv)) +
      geom_point(mapping=aes(x=k,y=knn.mean_rmse_cv))

![](ECO395M_Exercise2_files/figure-markdown_strict/3%20models-1.png)

    print(paste('base model RMSE:',mean(lm3.rmse_cv)))

    ## [1] "base model RMSE: 73610.497735494"

    print(paste('step model RMSE:',mean(step_lm.rmse_cv)))

    ## [1] "step model RMSE: 58397.028568103"

    print(paste('knn model RMSE:',knn.mean_rmse_cv[order(knn.mean_rmse_cv)[1]]))

    ## [1] "knn model RMSE: 87624.846953421"

For this data set on the prices of houses in Saratoga with other
variables, three predictive models have been built: one model feature
engineered by hand, one linear model feature enginnered using step AIC
and a KNN model (with scaled numeric values). Additionally, given that
KNN has an range of possible K values for its number of nearest
neighbors, a plot of K vs mean RMSE was created. We measure the model
performance by mean out-of-sample RMSE from 10 fold cross validation.
Additionally, while the evaluation of the knn model is by the K that
yields the lowest RMSE, it is important to keep in mind that K maybe
unstable.

It can be seen that the step model performances the best in terms of
mean cross validated out-of-sample RMSE, so it would likely be the best
choice given that it has an signficiant improvement over the other two
models in the range of $15,000 which would be a large sum of money to
miss out on in the market when using one of these models for price
prediction.

3 Classification and Retrospective Sampling
===========================================

This part will be analyzing data on loan defaults from a German bank.
However, this is not raw data. Given that defaults are rare, the bank
sampled a set of loans that had defaulted to be included, then tried to
match each default with similar sets of loans that had not defaulted.
So, the end result was oversampling of the defaults in their set.

    ggplot(data=data3) +
      geom_bar(mapping=aes(x=history,y=Default),stat='summary',fun='mean') +
      labs(title='Credit History vs Defaults',x='Credit History',y='Default Probability')

![Figure 3: The probabilty of defaulting on a loan given credit history
(good, poor, terrible). The probability calculation is carried out by a
simple unweighted
mean.](ECO395M_Exercise2_files/figure-markdown_strict/bar%20plot-1.png)
From this plot, it can be plainly seen that default probability
increases with positive credit rating. This is opposite to the intuition
of credit rating, as better should see less defaults. This may be a
result of the resampling done on the data set in that the "closeness"
thershold did not treat each credit history the same; "good" might have
sampled more than "terrible" just because a 'distance' between person
who defaults and who does not, both with "good" credit history, is
smaller than with "terrible" credit history. As such, this may not be an
appropriate for building a predictive model on defaults because the data
set may be misrepresentative of reality.

    glm(Default~duration+amount+installment+age+history+purpose+foreign,data=data3,family='binomial')

    ## 
    ## Call:  glm(formula = Default ~ duration + amount + installment + age + 
    ##     history + purpose + foreign, family = "binomial", data = data3)
    ## 
    ## Coefficients:
    ##         (Intercept)             duration               amount  
    ##          -7.075e-01            2.526e-02            9.596e-05  
    ##         installment                  age          historypoor  
    ##           2.216e-01           -2.018e-02           -1.108e+00  
    ##     historyterrible           purposeedu  purposegoods/repair  
    ##          -1.885e+00            7.248e-01            1.049e-01  
    ##       purposenewcar       purposeusedcar        foreigngerman  
    ##           8.545e-01           -7.959e-01           -1.265e+00  
    ## 
    ## Degrees of Freedom: 999 Total (i.e. Null);  988 Residual
    ## Null Deviance:       1222 
    ## Residual Deviance: 1070  AIC: 1094

Here is a linear predicitve model for defaults based on the data set.
This model indicates that increasingly poor credit history leads to less
likely default probability, which is what the above plot indicated. So,
again this contradicts what is expected to be intuitively true.

4 Children and Hotel Reservations
=================================

In this section, the data set of interest is one with information about
hotel attendence from a major United States based hotel chain. The
variable that the models will focus on predicting is the presence of
children in a booking for the hotel, as there are some practical
advantages to knowing if a child will be arriving beforehand without
explicit information. First, three linear models were build using logit
regression and feature engineering. The first model uses only 4
covariates (small model) whilte the second uses all avaliable covariates
except arrival time. The last one includes the month feature engineered
from the arrival date and the arrival date changed into days since the
first booking.

    #date feature
    data4 <- cbind(data4,'month'= month(ymd(as.Date(data4$arrival_date,'%Y-%m-%d'))))
    data4$month <- month.abb[data4$month]
    data4$arrival_date <- cumsum(yday(ymd(as.Date(data4$arrival_date,'%Y-%m-%d'))))

    data4_val <- cbind(data4_val,'month'=month(ymd(as.Date(data4_val$arrival_date,'%Y-%m-%d'))))
    data4_val$month <- month.abb[data4_val$month]
    data4_val$arrival_date <- cumsum(yday(ymd(as.Date(data4_val$arrival_date,'%Y-%m-%d'))))

    #fold the data
    kfolds = 10
    data4  <- data4 %>% 
      mutate(fold_id = rep(1:kfolds, length=nrow(data4)) %>% sample)

    #baseline 1 model
    baseline1.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
      baseline1 <- glm(children~market_segment+adults+customer_type+is_repeated_guest,data=filter(data4,fold_id!=fold),family='binomial')
      sqrt(mean((predict(baseline1,filter(data4,fold_id==fold),type='response')-filter(data4,fold_id==fold)$children)^2))
    }

    #baseline 2 model
    baseline2.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
      baseline2 <- glm(children~.-arrival_date-month,data=filter(data4,fold_id!=fold),family='binomial')
      sqrt(mean((predict(baseline2,filter(data4,fold_id==fold),type='response')-filter(data4,fold_id==fold)$children)^2))
    }

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    #model building
    my.model.rmse_cv <- foreach(fold = 1:kfolds, .combine='c') %do% {
      my.model <- glm(children~.,data=filter(data4,fold_id!=fold),family='binomial')
      sqrt(mean((predict(my.model,filter(data4,fold_id==fold),type='response')-filter(data4,fold_id==fold)$children)^2))
    }

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    #mean rmse of baseline models
    mean(baseline1.rmse_cv)

    ## [1] 0.2682048

    mean(baseline2.rmse_cv)

    ## [1] 0.2284335

    #mean rmse of competing model
    mean(my.model.rmse_cv)

    ## [1] 0.226036

As can be seen from the mean cross validated out-of-sample RMSE, the
third model is just slightly better, so now there will be further
validation of its predictive capabilities.

Now to further explore the performance of the model, a ROC curve can be
plotted employing a data set not used for training or testing.

    my.model.val <- glm(children~.,data=data4[,1:length(data4)-1],family='binomial')

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    thresholds <- seq(0,1,0.01)
    TPR  <- rep(0,length(thresholds))
    FPR  <- rep(0,length(thresholds))
    c  <- 1
    for(u in thresholds){
      predictions <- predict(my.model.val,data4_val,type='response')
      for(i in 1:length(predictions)){
        if(predictions[i] >= u){
          predictions[i] <- 1
        }else{
          predictions[i] <- 0
        }
      }
      mat <- confusionMatrix(factor(predictions),factor(data4_val$children))$table
      TPR[c] <- mat[2,2]/(mat[2,2]+mat[2,1])
      FPR[c] <- mat[1,2]/(mat[1,2]+mat[1,1])
      c <- c+1
    }

    ## Warning in confusionMatrix.default(factor(predictions),
    ## factor(data4_val$children)): Levels are not in the same order for reference and
    ## data. Refactoring data to match.

    ## Warning in confusionMatrix.default(factor(predictions),
    ## factor(data4_val$children)): Levels are not in the same order for reference and
    ## data. Refactoring data to match.

    ggplot(data=data.frame(TPR,FPR)) +
      geom_line(mapping=aes(x=FPR,y=TPR)) +
      labs(title='ROC Curve')

    ## Warning: Removed 2 row(s) containing missing values (geom_path).

![](ECO395M_Exercise2_files/figure-markdown_strict/validation%20step%201%20ROC%20curve-1.png)
From the ROC cruve, it can be seen that there is no much deviation from
the central line that balances TPR and FPR equally.

    #fold the data
    kfolds_val = 20
    data4_val  <- data4_val %>% 
      mutate(fold_id = rep(1:kfolds_val, length=nrow(data4_val)) %>% sample)

    sum_pred <- rep(0,kfolds_val)
    sum_real <- rep(0,kfolds_val)
    for(fold in 1:kfolds_val){
      sum_pred[fold] <- sum(predict(my.model.val,filter(data4_val,fold_id==fold),type='response'))
      sum_real[fold] <- sum(filter(data4_val,fold_id==fold)$children)
    }

    ggplot(data=data.frame(fold=1:kfolds_val,real=sum_real,pred=sum_pred)) +
      geom_bar(mapping=aes(x=fold,y=real-pred),stat='identity')

![](ECO395M_Exercise2_files/figure-markdown_strict/validation%20step%202%20folds-1.png)
Here, as a test of validity, the new data set is folded 20 times then
each fold has the predictive model tested against it by take the
difference of the sum of the children variable in the predictions and
the sum of the children variable in the data set. It can be seen that
the model is somewhat inconsisent given the variation in difference.
