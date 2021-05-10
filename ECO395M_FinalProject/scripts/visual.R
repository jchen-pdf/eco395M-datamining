#####################
####VISUALIZATION####
#####################
library(ggplot2)

#prelims (looking to beat about 50/50)
ggplot(data=chess) +
  geom_bar(mapping=aes(x=winner)) +
  labs(title='Outcomes in 20,0058 Games')
ggplot(data=chess.dum) +
  geom_bar(mapping=aes(x=winner)) +
  labs(title='Outcomes in 20,0058 Games (Binary)')
