#Retrieving Text from Twitter

rm(list=ls())

#Twitter API requires authentication since March 2013. Please follow instructions in "Section 3 - Authentication with OAuth" in the twitteR vignettes on # CRAN or this link to complete authentication before running the code below.

library(twitteR)
library(tm)
library(Snowballc)
#library(RWeka)
#library(rJava)
#library(RWekajars)


setup_twitter_oauth("dr83qJt5IfcuqmicXPI9yINlA", "c0bSVElsvFtuHQnlZhnvphup98486t1Qm3BJEezTqIlNfSzvM6","37933003-LSHwa6XzUtCwXnt3HN4nw0cq37Qd8ALtnyTEAYsI3", "hXrLrYqKkzmoqyaZJsfmTI5bO5zv3yPVytR9fMDWVuSpl")
1

# retrieve the first 100 tweets (or all tweets if fewer than 100)
# from the user timeline of @rdatammining
rdmTweets <- userTimeline("thebigparticle", n=100)
ndocs<-length(rdmTweets)

#########################
#Transforming Text
#The tweets are first converted to a data frame and then to a corpus.

df <- do.call("rbind", lapply(rdmTweets, as.data.frame))

> # build a corpus, which is a collection of text documents
> # VectorSource specifies that the source is character vectors.
myCorpus <- Corpus(VectorSource(df$text))

#After that, the corpus needs a couple of transformations, including changing letters to lower case, removing punctuations/numbers and removing stop words. The general English stop-word list is tailored by adding "available" and "via" and removing "r".
myCorpus <- tm_map(myCorpus, tolower)           # convert to lower
myCorpus <- tm_map(myCorpus, removePunctuation) # remove punctuation
myCorpus <- tm_map(myCorpus, removeNumbers)     # remove numbers
removeURL <- function(x) gsub("http[[:alnum:]]*","",x) # [[:alnum:]]* is a string of anynumber of alphanumeric characters
myCorpus <- tm_map(myCorpus, removeURL)         #remove URLs

####################
# remove stopwords
# keep "r" by removing it from stopwords
myStopwords <- c(stopwords('english'), "available", "via")
myStopword <- setdiff(myStopwords, c("r", "big")) # remove big and r from stopwords
#idx <- which(myStopwords == "r")
#myStopwords <- myStopwords[-idx]
myCorpus <- tm_map(myCorpus, removeWords, myStopwords)

####################
#Stemming Words
#In many cases, words need to be stemmed to retrieve their radicals. For instance, "example" and "examples" are both stemmed to "exampl". However, after that, one may want to complete the stems to their original forms, so that the words would look "normal".
#library(RWeka)

dictCorpus <- myCorpus
# stem words in a text document with the snowball stemmers,
# which requires packages Snowball, RWeka, rJava, RWekajars
myCorpus <- tm_map(myCorpus, stemDocument)
# inspect the first three ``documents"
inspect(myCorpus[1:3])

# stem completion
myCorpus <- tm_map(myCorpus, stemCompletion, dictionary=dictCorpus)

# Print the first three documents in the built corpus.

inspect(myCorpus[1:3])

#Something unexpected in the above stemming and stem completion is that, word "mining" is first stemmed to "mine", and then is completed to "miners", instead of "mining", although there are many instances of "mining" in the tweets, compared to only one instance of "miners".
# Building a Document-Term Matrix

myDtm <- TermDocumentMatrix(myCorpus, control = list(minWordLength = 1))
inspect(myDtm[266:270,31:40])



#Based on the above matrix, many data mining tasks can be done, for example, clustering, classification and association analysis.

#Frequent Terms and Associations

> findFreqTerms(myDtm, lowfreq=10)
[1] "analysis" "data" "examples" "miners" "package" "r" "slides"
[8] "tutorial" "users"

> # which words are associated with "r"?
> findAssocs(myDtm, 'r', 0.30)
   r  users examples package canberra cran list
1.00   0.44     0.34    0.31     0.30 0.30 0.30

> # which words are associated with "mining"?
> # Here "miners" is used instead of "mining",
> # because the latter is stemmed and then completed to "miners". :-(
> findAssocs(myDtm, 'miners', 0.30)
miners data classification httptcogbnpv mahout
  1.00 0.56           0.47         0.47   0.47
recommendation sets supports frequent itemset
          0.47 0.47     0.47     0.40    0.39

Word Cloud

After building a document-term matrix, we can show the importance of words with a word cloud (also kown as a tag cloud) . In the code below, word "miners" are changed back to "mining".

> library(wordcloud)
> m <- as.matrix(myDtm)
> # calculate the frequency of words
> v <- sort(rowSums(m), decreasing=TRUE)
> myNames <- names(v)
> k <- which(names(v)=="miners")
> myNames[k] <- "mining"
> d <- data.frame(word=myNames, freq=v)
> wordcloud(d$word, d$freq, min.freq=3)


Word cloud of @RDataMining tweets

The above word cloud clearly shows that "r", "data" and "mining" are the three most important words, which validates that the @RDataMining tweets present information on R and data mining. The other important words are "analysis", "examples", "slides", "tutorial" and "package", which shows that it focuses on documents and examples on analysis and R packages.