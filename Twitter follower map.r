Twitter Follower Map
Below is a simple example for plotting Twitter followers on a world map. Simply replace "RDataMining" with your Twitter account to produce your own follower map.

Note that Twitter API requires authentication. Please follow instructions in "Section 3 - Authentication with OAuth" in the twitteR vignettes on CRAN or this link to complete authentication before running the code below.

> source("http://biostat.jhsph.edu/~jleek/code/twitterMap.R")
> twitterMap("RDataMining", fileName="twitterMap.pdf", nMax=1500)

See a detailed post on the above function at the link below:
  An R function to map your Twitter Followers
