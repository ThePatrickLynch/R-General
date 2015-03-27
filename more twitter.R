setwd("d:/Data/github/a-new-one")

library("twitteR")
library("wordcloud")
library("tm")

setup_twitter_oauth("dr83qJt5IfcuqmicXPI9yINlA", "c0bSVElsvFtuHQnlZhnvphup98486t1Qm3BJEezTqIlNfSzvM6","37933003-LSHwa6XzUtCwXnt3HN4nw0cq37Qd8ALtnyTEAYsI3", "hXrLrYqKkzmoqyaZJsfmTI5bO5zv3yPVytR9fMDWVuSpl")
1

# retrieve the first 100 tweets (or all tweets if fewer than 100)
# from the user timeline 
userTimeline('@thebigparticle',n=10) # tweets from a user

homeTimeline (n=15) # get tweets from home timeline
mentions (n=15) # get your tweets that were retweeted
favs <- favorites("r_programming", n =10) # tweets a user has favorited


tweets <- searchTwitter("thebigparticle", n=200) # top 25 tweets that contain search term

tweetsDF <- twListToDF(tweets) # more info about tweets.

# searchTwitter('apartment hunting', geocode='40.7361,-73.9901,5mi',  n=5000, retryOnRateLimit=1) # hmm geollocation too!



#######
#necessary file for Windows
download.file(url="http://curl.haxx.se/ca/cacert.pem", destfile="cacert.pem")
# some form of certificates


r_stats<- searchTwitter("#Rstats", n=1500, cainfo="cacert.pem")

r_stats_text <- sapply(r_stats, function(x) x$getText())
#create corpus
r_stats_text_corpus <- Corpus(VectorSource(r_stats_text))

#clean up
r_stats_text_corpus <- tm_map(r_stats_text_corpus, content_transformer(tolower)) 
r_stats_text_corpus <- tm_map(r_stats_text_corpus, removePunctuation)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, function(x)removeWords(x,stopwords()))
wordcloud(r_stats_text_corpus)

#alternative steps if you're running into problems 
r_stats<- searchTwitter("#Rstats", n=1500, cainfo="cacert.pem")
#save text
r_stats_text <- sapply(r_stats, function(x) x$getText())
#create corpus
r_stats_text_corpus <- Corpus(VectorSource(r_stats_text))

#if you get the below error
#In mclapply(content(x), FUN, ...) :
#  all scheduled cores encountered errors in user code
#add mc.cores=1 into each function

#run this step if you get the error:
#(please break it!)' in 'utf8towcs'
r_stats_text_corpus <- tm_map(r_stats_text_corpus,
                              content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
                              mc.cores=1
)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, content_transformer(tolower), mc.cores=1)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, removePunctuation, mc.cores=1)
r_stats_text_corpus <- tm_map(r_stats_text_corpus, function(x)removeWords(x,stopwords()), mc.cores=1)
wordcloud(r_stats_text_corpus)


#Let's try the hash tag #bioinformatics

bioinformatics <- searchTwitter("#bioinformatics", n=1500)
bioinformatics_text <- sapply(bioinformatics, function(x) x$getText())
bioinformatics_text_corpus <- Corpus(VectorSource(bioinformatics_text))
bioinformatics_text_corpus <- tm_map(bioinformatics_text_corpus,
                                     content_transformer(function(x) iconv(x, to='UTF-8-MAC', sub='byte')),
                                     mc.cores=1
)
bioinformatics_text_corpus <- tm_map(bioinformatics_text_corpus, content_transformer(tolower), mc.cores=1)
bioinformatics_text_corpus <- tm_map(bioinformatics_text_corpus, removePunctuation, mc.cores=1)
bioinformatics_text_corpus <- tm_map(bioinformatics_text_corpus, function(x)removeWords(x,stopwords()), mc.cores=1)
wordcloud(bioinformatics_text_corpus)

#if you're getting the error:
#could not be fit on page. It will not be plotted.
#try changing the scale, like
#wordcloud(bioinformatics_text_corpus, scale=c(2,0.2))

library(RColorBrewer)
pal2 <- brewer.pal(8,"Dark2")
wordcloud(bioinformatics_text_corpus,min.freq=2,max.words=100, random.order=T, colors=pal2)

