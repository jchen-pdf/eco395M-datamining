Introduction
============

Given the the financial capital and public interest surrounding
competitives sports and games, the predictive ability regarding the
outcome is an incredibly attractive endeavor worth pursuing. And so, of
course, we choose to construct a predictive model for the most popular
competitve sport: chess. Chess presents intself as a much simpler game
than most others given its turn based nature along with the fact that it
is an individuals game.

Data
====

To build a predictive model of chess outcomes, we will use a data set
from kaggle that contains over 20,000 online chess matches
(<https://www.kaggle.com/datasnaek/chess>). The data set contain 16
variables, but we will not be using all of them to build our model.
Firstly, each game is given a unique identifying alphanumeric string
that can be removed as it does not provide any information regarding the
outcome. There are additional variables which also do not provide any
information about the outcome of the game; the game start and end
variables are not sensitive enough to be distinguishable so the total
game time cannot be retrieved. Futhermore, the "moves" variable will
also be eliminated as the aim to predict the outcome of the game before
it begins; using the "moves" variable also leans more towards just
building an algorithm to play chess rather than prediction of outcome
between players. The identifying names of the players are also dropped
to be able to predict for unidentified players.

For the remaining features, there is some pre-processing to be done for
both the the lasso logit model and random forest that will be used. The
increment codes are in the form of an integer "+" an integer in a
string, so it can be seperated into two variables of the increment
integers and treated as a continuous variable. The "opening\_name"
variable contains the opening each game but will be dropped in favor of
the "opening\_eco" variable which categorizes the openings in codes;
this "opening\_eco" variable is then made into a dummy variable (with
over 300 different outcomes) and one removed option as the baseline
(A00). The outcome variable for the a binary logit model must be in 0 or
1 so the winner variable is changed as outcome "white" is one and
"black"/"draw" is zero. White is actually favored more than black in
winning (likely due to having the first move) as seen below, so when
"black"/"draw" are categorized into zero the binary outcomes are roughly
50-50.

![](write_up_files/figure-markdown_strict/prelim%20plots-1.png)![](write_up_files/figure-markdown_strict/prelim%20plots-2.png)

Random forest can handle categorical variables without explicitly using
dummy variables. This is a behavior present in the algorithm in
randomForest package in R but can only handle categorical variables with
up to 53 levels. The "opening\_eco" variable has over 300 levels which
cannot be processed by the function, so we will drop this variable (more
reasoning will be provided later). The outcome variable winner can be
left as "white", "black"," and "draw".

Logit Lasso Model
=================

Given the large number of variable after coverting the categorical
variables to dummy variables, a lasso model would be appropriate for
feature selection. Then it can be combined with a logit model to predict
the binary winner outcome variable. To train the model, a 70-30 train
test split is used on the original data set. Furthermore, the model is
trained with cross-validation to improve out-of-sample predictive
performance and avoid overfitting.

The model itself will also include interaction terms from the white
player's rating and the black player's rating with each other term. The
ratings act as the individual's propensity score towards winning and
would make sense that individual skill will have some effect on how
openings play out and especially with mismatched skill across the two
players.

As the outcome is discrete, a confusion matrix will be the first step in
assessing the predictive performance of the model. The accuracy metric
will be the measure of performance as this is a very balanced outcome
variable in the binary form prescribed. Given that the logit model
predicts with a continious outcome variable of the probability of white
winning in this case, a threshold will need to be set of what likelihood
constitutes as a prediction in the positive.

![](write_up_files/figure-markdown_strict/logit%20model-1.png)

    ##    thresholds  accuracy
    ## 89       0.54 0.6671625

With proper threshold setting of around a confidence of 50%, the lasso
logit model is able to achieve an accuracy of about 67%. This about 17%
over the incident rate (which will act as the baseline) which is indeed
an improvement. However, next is the question is if random forest can
beat that out-of-sample predictive performance.

Random Forest
=============

Random forest works well with a modest number of predictor variables
with the 9 (excluding the outcome variable) in the data set, this
algorithm would appear to be good choice. However, as stated before, the
"opening\_eco" variable has over 300 levels which is way too many for
the random forest function to handle; the lasso logit regression has
also shown that many of the dummy variables from the "opening\_eco"
variable are zero. Thus, dropping the column entirely should not have
marked effect in performance.

    ## Confusion Matrix and Statistics
    ## 
    ##           Reference
    ## Prediction black draw white
    ##      black  1907    9   885
    ##      draw      0  280     0
    ##      white  1150    9  2447
    ## 
    ## Overall Statistics
    ##                                          
    ##                Accuracy : 0.693          
    ##                  95% CI : (0.6818, 0.704)
    ##     No Information Rate : 0.4983         
    ##     P-Value [Acc > NIR] : < 2.2e-16      
    ##                                          
    ##                   Kappa : 0.4293         
    ##                                          
    ##  Mcnemar's Test P-Value : 2.333e-11      
    ## 
    ## Statistics by Class:
    ## 
    ##                      Class: black Class: draw Class: white
    ## Sensitivity                0.6238     0.93960       0.7344
    ## Specificity                0.7537     1.00000       0.6545
    ## Pos Pred Value             0.6808     1.00000       0.6786
    ## Neg Pred Value             0.7041     0.99719       0.7128
    ## Prevalence                 0.4572     0.04456       0.4983
    ## Detection Rate             0.2852     0.04187       0.3659
    ## Detection Prevalence       0.4189     0.04187       0.5393
    ## Balanced Accuracy          0.6888     0.96980       0.6945

The random forest also performs with an accuracy of roughly 67%. But in
addition to the relatively similar performance, the random forest also
predicts the categorical variables of the outcome: "white", "draw",
"black".

Results
=======

Given that random forest is a good predictive algorithm without too many
adjustment to the parameters, the predictive ability can be use as an
upperbound to the lasso logit model. Since the performance of both are
roughly the same, it can be said that the lasso logit model using rating
interactions works to a fair degree in terms of prediction.
Additionally, the lasso logit model has feature selection and better
interpretability of the covariates.

From examination of the coefficients, the effect of almost all of the
opening dummy variables are zero. The "rated" status and
"victory\_status" of the game also have no effect. The ratings of each
player does have a noticable effect. And given that the outcome variable
is 1 if white wins, the model shows that the coefficient on
"white\_rating" is positive and the coefficient "black\_rating" is
negative; this makes sense on a human level as a higher rating mean
increased skill. From closer inspection of the two coefficent it can be
see that they are roughly the same (~0.002), But, the "black\_rating"
coefficient is slightly lower than the "white\_rating" coefficient. This
would seem to make sense as a player with higher skill level could
leverage the white first mover advantage better than the black position.
However, this can also be statistical noise.

A slightly more surprising result is that interacting the rating of the
white player with the rating of the black player yields a coefficient of
zero under the lasso. One would normally expect that there should be
some form of effect of of having a difference between the skill levels.
Although, there are a few opening which when interacted with the
ratings, yield non-zero coefficients, so it would appear that certain
openings are, on average, better than others depending on the skill of
the individual and also some that actually lower the chances of winning.

Conclusion
==========

From a data set on ~20,000 online chess matches, a predictive model of
the outcome with 67% accuracy was built using a lasso logit algorithm as
well as random forest as a benchmark. Both models were able to beat the
incident rate (~50%) by a noticable margin. However, with the random
forest model acting as a benchmark for the accuracy to aim for,
interaction effects from the individual player ratings with all other
variables were added into the lasso logit model. This allowed the lasso
logit model to bring up its accuracy to the same level as the random
forest.

With the predictive performance equal between the two models, the lasso
logit regression model can be turned to for interpretation of the
variables on the outcome. It seems that the ratings plays a great deal
of influence on the the outcomeo of the chess game both just in
themselves and how they interact with certain openings. This effect
could be interpreted as certain opening are more effective with higher
skill levels or require a level of skill to be used correctly.

By avoiding using the particular moves in the game, it allows the model
to be used preceding the games with a control of openings rather than
requiring the game to begin. While this lacking this information in the
model most assuredly is a detriment to the accuracy, it serves better to
predicting games that are not in the middle of play.
