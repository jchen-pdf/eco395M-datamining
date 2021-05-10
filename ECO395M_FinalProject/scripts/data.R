############
####DATA####
############
#package load
library(tidyverse)

#credit card fraud (https://www.kaggle.com/mlg-ulb/creditcardfraud)
cc <- read.table('data/creditcard.csv',sep=',',header=TRUE)
colnames(cc)[length(cc)] <- 'fraud'

#mushroom (https://www.kaggle.com/adhyanmaji31/mushroom-classification)
mr <- read.table('data/mushrooms.csv',sep=',',header=TRUE)

#kobe beef distribution (https://www.kaggle.com/betweentherows/kobe-beef-global-distribution)
beef <- read.table('data/Kobe_distro_data_2020_cleaned.csv',sep=',',header=TRUE)

#chess games (https://www.kaggle.com/datasnaek/chess)
#opening codes (https://www.365chess.com/eco.php)
chess <- read.table('data/games.csv',sep=',',header=TRUE,fill=TRUE,quote='',comment.char='')

