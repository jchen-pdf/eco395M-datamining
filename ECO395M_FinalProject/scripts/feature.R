###############
####FEATURE####
###############
#load packages
library(fastDummies)
library(tidyverse)

#drop columns
chess <- chess %>%
  mutate(id=NULL,white_id=NULL,black_id=NULL, #no information
         created_at=NULL,last_move_at=NULL, #times are not sensitive enough
         moves=NULL, #moves have too many  dimensions
         opening_name=NULL) #already have opening codes

####LOGIT####
#dummy
chess.dum <- dummy_cols(chess,select_columns=c('victory_status','opening_eco'),remove_first_dummy=TRUE)
chess.dum <- chess.dum %>%
  mutate(opening_eco=NULL,victory_status=NULL)

#winner to binary (or factor)
chess.dum$winner <- as.factor(chess.dum$winner)
chess.dum$winner <- ifelse(chess.dum$winner=='white',1,0)

#rated into numerics
chess.dum$rated <- as.integer(as.logical(chess.dum$rated))

#increment
in1 <- rep(NA,length(chess.dum$increment_code))
in2 <- rep(NA,length(chess.dum$increment_code))
for(i in 1:length(chess.dum$increment_code)){
  in1[i] <- strtoi(strsplit(chess.dum$increment_code[i],"[+]")[[1]][1])
  in2[i] <- strtoi(strsplit(chess.dum$increment_code[i],"[+]")[[1]][2])
}
chess.dum <- chess.dum %>% mutate(increment1=in1,increment2=in2,increment_code=NULL)
rm(in1,in2)

####RF####
#factors
chess.fac <- chess %>% 
  mutate(winner=as.factor(winner),rated=as.factor(rated),victory_status=as.factor(victory_status),opening_eco=NULL) 

#increment
in1 <- rep(NA,length(chess.fac$increment_code))
in2 <- rep(NA,length(chess.fac$increment_code))
for(i in 1:length(chess.fac$increment_code)){
  in1[i] <- strtoi(strsplit(chess.fac$increment_code[i],"[+]")[[1]][1])
  in2[i] <- strtoi(strsplit(chess.fac$increment_code[i],"[+]")[[1]][2])
}
chess.fac <- chess.fac %>% mutate(increment1=in1,increment2=in2,increment_code=NULL)
rm(in1,in2)
