#Retrieving Text from Twitter

# couldn't resolve stemming words and then completing them - otherwise kinbd of good stuff here


rm(list=ls())

#Twitter API requires authentication since March 2013. Please follow instructions in "Section 3 - Authentication with OAuth" in the twitteR vignettes on # CRAN or this link to complete authentication before running the code below.

library(twitteR)
setup_twitter_oauth("dr83qJt5IfcuqmicXPI9yINlA", "c0bSVElsvFtuHQnlZhnvphup98486t1Qm3BJEezTqIlNfSzvM6","37933003-LSHwa6XzUtCwXnt3HN4nw0cq37Qd8ALtnyTEAYsI3", "hXrLrYqKkzmoqyaZJsfmTI5bO5zv3yPVytR9fMDWVuSpl")

# retrieve the first 100 tweets (or all tweets if fewer than 100)
# from the user timeline of @rdatammining

twitter.user<-"iLearningUK"

rdmTweets <- userTimeline(twitter.user, n=100)
n <- length(rdmTweets)

#Transforming Text

#The tweets are first converted to a data frame and then to a corpus.

df <- do.call("rbind", lapply(rdmTweets, as.data.frame))
df$text

library(tm)
# build a corpus, which is a collection of text documents
# VectorSource specifies that the source is character vectors.
myCorpus <- Corpus(VectorSource(df$text))

dictCorpus <- myCorpus # used later in stemCompletion

#After that, the corpus needs a couple of transformations, including changing letters to lower case, removing punctuations/numbers and removing stop words. The general English stop-word list is tailored by adding "available" and "via" and removing "r".
myCorpus <- tm_map(myCorpus, content_transformer(tolower))
#myCorpus <- tm_map(myCorpus, content_transformer(removePunctuation)) # remove punctuation - does remove the @ and # symbols
#myCorpus <- tm_map(myCorpus, content_transformer(removeNumbers))   # remove numbers 


# get rid of URLs
removeURL <- function(x) gsub("http[[:alnum:][:punct:]]*", "", x)
myCorpus <- tm_map(myCorpus, removeURL)
removeHandle <- function(x) gsub("@[[:alnum:][:punct:]]*","",x)
myCorpus <- tm_map(myCorpus, removeHandle)
removeHash <- function(x) gsub("#[[:alnum:][:punct:]]*","",x)
myCorpus <- tm_map(myCorpus, removeHash)

myCorpus <- tm_map(myCorpus, PlainTextDocument)

for(j in seq(myCorpus))   
{   
  #  myCorpus[[j]] <- gsub("/", " ", myCorpus[[j]])   
  myCorpus[[j]] <- gsub(",", " ", myCorpus[[j]])   
  #  myCorpus[[j]] <- gsub("\\|", " ", myCorpus[[j]])   
  #  myCorpus[[j]] <- gsub(". ", " ", myCorpus[[j]])   
  myCorpus[[j]] <- gsub("\\?", " ", myCorpus[[j]])  
  myCorpus[[j]] <- gsub(":", " ", myCorpus[[j]])  
  myCorpus[[j]] <- gsub("!", " ", myCorpus[[j]]) 
  myCorpus[[j]] <- gsub("&amp;", " ", myCorpus[[j]]) 
  myCorpus[[j]] <- gsub('"', " ", myCorpus[[j]])   
#  myCorpus[[j]] <- gsub("'", " ", myCorpus[[j]])   
} 

inspect(myCorpus)


# add some other stop words
myStopwords <- c(stopwords('english'), 'the', '&amp;', 'my', 'via', '\n')

# keep "r" by removing it from stopwords
# idx <- which(myStopwords == "r")
# myStopwords <- myStopwords[-idx]

myCorpus <- tm_map(myCorpus, removeWords, myStopwords)
#myStopwords

#str(myCorpus)
#inspect(myCorpus)
#meta(myCorpus[[3]])

#Stemming Words
#In many cases, words need to be stemmed to retrieve their radicals. For instance, "example" and "examples" are both stemmed to "exampl". However, after that, one may want to complete the stems to their original forms, so that the words would look "normal".

library(Snowballc)
library("SnowballC", lib.loc="d:/Program Files/R/R-3.1.3/library")

#myCorpus <- tm_map(myCorpus, PlainTextDocument)

# stem words in a text document with the snowball stemmers,
# which requires packages Snowball, RWeka, rJava, RWekajars
##myCorpus <- tm_map(myCorpus, stemDocument, language="english")

##identical(myCorpus, dictCorpus)
# inspect the first three ``documents"
#inspect(myCorpus[4:8])
#inspect(dictCorpus[4:8])



# stem completion
##dictCorpus<-myCorpus
##inspect(dictCorpus)
##stemCompletion("messi", dictCorpus)

# i needed to gurgle a solution as proferred approach did not work
#myCorpus <- tm_map(myCorpus, stemCompletion, dictionary=dictCorpus)
#str(myCorpus)
##inspect(myCorpus)

#myCorpus <- tm_map(myCorpus, PlainTextDocument)
####
####
#### dont know why function or original won't work here
####
####
#meta(myCorpus[[3]])
#
##stemCompletion_mod <- function(x,dict=dictCorpus) {
##  PlainTextDocument(stripWhitespace(paste(stemCompletion(unlist(strsplit(as.character(x)," ")),dictionary=dict, type="shortest"),sep="", collapse=" ")))
##}
##mynewCorpus <- lapply(myCorpus, stemCompletion_mod)
##mynewCorpus

##str(myCorpus)
##myCorpus[[1]]
##meta(myCorpus[[3]])

# Print the first three documents in the built corpus.
myCorpus <- tm_map(myCorpus, PlainTextDocument)
##myCorpus

############
# I have added some meta data so that the different documents are identified
# PlainTextDocument killed the metadata
#
#twit<-paste("@", twitter.user, sep="")  

#for (n in 1:length(myCorpus)) {
#  meta(myCorpus[[n]], tag='creator') <- twit
#  meta(myCorpus[[n]], tag='author') <- twit
#  meta(myCorpus[[n]], tag='heading') <- n
#  meta(myCorpus[[n]], tag='id') <- n
#  meta(myCorpus[[n]], tag='description') <- n
#}
#meta(myCorpus[[3]])

# Building a Document-Term Matrix

myDtm <- TermDocumentMatrix(myCorpus)  # , control = list(minWordLength = 1)

myDtm
inspect(myDtm[10:12,31:40])

#Based on the above matrix, many data mining tasks can be done, for example, clustering, classification and association analysis.
#Frequent Terms and Associations
findFreqTerms(myDtm, lowfreq=10)

# which words are associated with "r"?
findAssocs(myDtm, 'minecraft', 0.30)

findAssocs(myDtm, 'hullcraft', 0.30)

#Word Cloud

#After building a document-term matrix, we can show the importance of words 
# with a word cloud (also kown as a tag cloud) . In the code below, word "miners" 
# are changed back to "mining".

library(wordcloud)
m <- as.matrix(myDtm)
# calculate the frequency of words
v <- sort(rowSums(m), decreasing=TRUE)
myNames <- names(v)
k <- which(names(v)=="@thecommonpeopl")
myNames[k] <- "@thecommonpeopl"
d <- data.frame(word=myNames, freq=v)
wordcloud(d$word, d$freq, min.freq=3)





