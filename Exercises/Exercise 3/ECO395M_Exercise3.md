1 What causes what?
===================

1.  There could many many different causes that can cause correlation
    between crime and police presence that may not necessarily be
    directly from police presence. It could be that increasing police
    presence required more funding that was taken out of homeless
    shelters, which could drive up crime rate.

2.  Researchers for Upenn were able to isolate the effect of police
    presence on crime rate by taking advantage of a specific protocol
    within Washington DC's police department; this protocol increases
    police presence by adding more officers on the streets when there is
    a high terrorist threat level as Washington DC is the nation's
    capitol. This protocol allows the treatment of increased police
    presence without perturbing the rest of the system too much. In the
    table, it can be seen that the coefficent of the dummy variable for
    High Alert is significant at the 5% level, showing that there is
    indeed a negative effect (for Washington DC). They also control for
    drop in METRO ridership to account for the possibility that with a
    terrorist alert people may not be outside (so less victims for
    crime). In the models with and without this control, both show a
    significant negative coefficent for police presence on crime rate.

3.  They controlled for METRO ridership as an indicator variable of
    people being outside and still operating as normal. This is because
    if the number of people were to drop it may result in a drop in
    crime rate as they would be less potential victims.

4.  The model here is estimating the interaction effect between the High
    Alert variable and dummy on first police district on the crime rate.
    The conclusion for this model is that there is a heterogenous effect
    of High Alert on crime rate in different districts; the effect is
    statistically signficant for district 1 but not for the other ones.

2 Predictive model building: green certification
================================================

Overview
--------

We will be building a predictive model for revenue per square foot per
calendar year to quantify on average the affect of green certification
(either LEED or Energystar). The data employed to build this model is on
7,894 commercial rental properties from across the United States with
about 9% of them having a green certification. \#\# Data and Model The
data set is processed by adding a column for the outcome variable,
yearly revenue per square foot, which is the rent per square foot times
the leasing rate. Then these two variables are removed from the set of
predictors as they would be highly correlated with the outcome variable.

There is a choice to use LEED and Energystar indicators or the green
rating indicator to analysis the affect of having these labels. With
keeping LEED and Energystar, it will allow the model to differentiate
between the two and therefore estimate the affects of each seperately
and we can use an interaction between them to ensure that for buildings
with both do not impact the ones with only one too much. Conversely, if
it is believed that the affect from both (together as well) is the same
then using only green rating becomes much more appealing as we reduce
the features by one and it becomes easier to interpret only one effect.

The two models with high predictive capabilities and low upfront cost
are K-NN and random forest. However, both are more useful for
out-of-sample predictions on the specified outcome variable. Here, the
foremost concern is the affect a particular covariate has on the outcome
variable. Thus, a model with high interpretability is require and
regressions will seem to fit that criteria well. So, we will use lasso
regression as it will also do automatic feature selection and allow the
estimation the importance of the green ratings.

![](ECO395M_Exercise3_files/figure-markdown_strict/lasso%20plots-1.png)![](ECO395M_Exercise3_files/figure-markdown_strict/lasso%20plots-2.png)![](ECO395M_Exercise3_files/figure-markdown_strict/lasso%20plots-3.png)
From all three variations of the lasso regression, it can be seen that
none of the green rating labels were selected. This indicates that the
they are likely not heavily important in predicting the outcomes
variable. However, since the green rating labels are the variables of
interest, they will need to be in the regression. So, instead we will
use a less feature punishing method (this can also be achieved by
decreasing lambda in lasso). Step-wise AIC can help with this feature
selection and increasing out-of-sample RMSE without exluding the green
rating labels.

From the stepwise AIC with cross-validation, the out-of-sample RMSE is
marginally lower than the lasso. Additionally, now there is
interpretability behind the affect of the green rating labels with this
model. Now, comparing the model that includes both (LEED and Energystar)
against just "green rating" (1 if having LEED or Energystar), it can be
seen that the values are much closer to the estimated effect of
Energystar; this may be caused by the fact that the data set only
includes 54 buildings with LEED and 632 with Energystar. So, it would
likely be best to focus on the model with both labels as the affect from
the two are distinguishable.

In the model with both the LEED and Energystar labels, the former has a
postive effect of about ~$290 and the latter with ~160; both with
statistical significance. It is important to note the the stepwise AIC
had pruned out the LEED variable in one CV fold, but it is already known
that the green labels are not very important in out-of-sample RMSE
optimization from the lasso regressions. This is further understanding
is further solidified in the fact that the found effects from the green
labels only amount to about ~10% of the actual yearly revenue per square
foot.

Results
-------

By running models seperately for LEED/Energystar and "green rating", it
was found that there is a difference in effect between the LEED and
Energystar that should be taken into account. Therefore, the findings
will reflect the model with incorporates both rather than the combined
label.

In running the lasso regression with cross-validation, the importantance
of the green labels with regard to predicting yearly revenue per square
foot is actually fairly low. So, instead stepwise AIC was used to
measure the affects of each label. We found that the labels only account
to about ~10% of the actual yearly revenue per square foot. And, the
LEED rating would actually yield a larger bump in yearly revenue per
square foot than Energystar.

Conclusion
----------

Armed with the knowledge from the above models, it can be concluded with
reasonable certainty that a green rating label is not necessary if one
were to invest in a building. However, this data (and therefore the
model results) reflects the past social-political climate and feels
about green ratings may change over the lifetime of a bulding as they
stand for several decades. But having a green rating label at this point
in time could result in a minute increase in revenue stream, which may
be worth it depending on the cost of obtaining such a label.

3 Predictive model building: California housing
===============================================

Overview
--------

Here we wil be building a predictive model for the median market value
of all households in a census tract. Our model will be focusing on high
out-of-sample predictive performance without the need for
interpretability. In addition, the dimensions in the data set are fairly
modest, so the random forest algorithm would likely work well here. \#\#
Data and Model The data must first go through feature processing. In the
case of this data set, the features total bedrooms and total bathrooms
are odd as they are not quite representative of the the average
household in the area. So, they will be scaled by number of households.
Additionally, population will also be scaled in the same manner. The
data will be more representative of an average household in a particular
census tract. This is done as the outcome variable of interest is only
within the household scope.

First, a simple OLS model was used as the benchmark model to beat (a low
bar but still a point to measure relative improvement) with cross
validation. Our benchmark model produces a mean CV RMSE of about
~70,000.

Compared to the random forest algorithm, which produces an mean CV RMSE
of about ~50,000, which is a 30% decrease in mean CV RMSE. As expected,
random forest performs noticeably better in predictive capabilities than
just simple OLS.

Results
-------

Armed with this model, using the true data, the model's predictions and
the residuals, we can assemble plots of the median household market
value with respect to the latitude and longitude overlayed on a map.

    ## Source : https://maps.googleapis.com/maps/api/staticmap?center=california&zoom=6&size=640x640&scale=2&maptype=terrain&language=en-EN&key=xxx

    ## Source : https://maps.googleapis.com/maps/api/geocode/json?address=california&key=xxx

![](ECO395M_Exercise3_files/figure-markdown_strict/map%20plots-1.png)![](ECO395M_Exercise3_files/figure-markdown_strict/map%20plots-2.png)![](ECO395M_Exercise3_files/figure-markdown_strict/map%20plots-3.png)
When comparing the plots between the predictions and actual data Then
looking at the log residuals plot, there appears to be a great deal
mixing in the magnitude, which is especially noticable in highly
clustered areas. So, while the random forest model has given relatively
good out-of-sample performance, there is still a lot of variance not
captured.

Conclusion
----------

Using cross-validated mean RMSE as the metric for model predictive
performance, random forest was a good model producing better results
than simple OLS. However, given the nature of the two models this was
the expected outcome.
