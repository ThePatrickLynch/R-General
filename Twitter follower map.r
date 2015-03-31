#Twitter Follower Map
# Below is a simple example for plotting Twitter followers on a world map. 
# Simply replace "RDataMining" with your Twitter account to produce your own follower map.

# Note that Twitter API requires authentication. Please follow instructions in 
# "Section 3 - Authentication with OAuth" in the twitteR vignettes on CRAN or 
# this link to complete authentication before running the code below.

rm(list=ls())

#Twitter API requires authentication since March 2013. Please follow instructions in "Section 3 - Authentication with OAuth" in the twitteR vignettes on # CRAN or this link to complete authentication before running the code below.

library(twitteR)
setup_twitter_oauth("dr83qJt5IfcuqmicXPI9yINlA", "c0bSVElsvFtuHQnlZhnvphup98486t1Qm3BJEezTqIlNfSzvM6","37933003-LSHwa6XzUtCwXnt3HN4nw0cq37Qd8ALtnyTEAYsI3", "hXrLrYqKkzmoqyaZJsfmTI5bO5zv3yPVytR9fMDWVuSpl")


source("http://biostat.jhsph.edu/~jleek/code/twitterMap.R")
twitterMap("iLearningUK", fileName="twitterMap.pdf", nMax=1500)

#See a detailed post on the above function at the link below:
#  An R function to map your Twitter Followers
