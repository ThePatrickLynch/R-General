# http://www.r-bloggers.com/text-mining-the-complete-works-of-william-shakespeare/
#
# Reads the entire works of Shakespeare form the Gutenburg project
# Creates a document term matrix - this can allow inspection of word associations and frequencies
# finishes by plotting frequencies of most common terms by document
#
# some great transformations on the text data shown as well
#
# none structured data - yay!
####

rm(list=ls()) 

library(tm)
library(SnowballC)
library(slam)
library(reshape2)
library(ggplot2)


TEXTFILE = "d:/data/pg100.txt"
if (!file.exists(TEXTFILE)) {
     download.file("http://www.gutenberg.org/cache/epub/100/pg100.txt", destfile = TEXTFILE)
}
shakespeare = readLines(TEXTFILE)
length(shakespeare)
head(shakespeare)

# There seems to be some header and footer text. We will want to get rid of that! 
# Using a text editor I checked to see how many lines were occupied with metadata 
# and then removed them before concatenating all of the lines into a single long, long, long string.

shakespeare = shakespeare[-(1:173)]
shakespeare = shakespeare[-(124195:length(shakespeare))]
shakespeare = paste(shakespeare, collapse = " ")
nchar(shakespeare)

# While I had the text open in the editor I noticed that sections in the 
# document were separated by the following text:
# <<THIS ELECTRONIC VERSION OF THE COMPLETE WORKS OF WILLIAM
# SHAKESPEARE IS COPYRIGHT 1990-1993 BY WORLD LIBRARY, INC., AND IS
# PROVIDED BY PROJECT GUTENBERG ETEXT OF ILLINOIS BENEDICTINE COLLEGE
# WITH PERMISSION.  ELECTRONIC AND MACHINE READABLE COPIES MAY BE
# DISTRIBUTED SO LONG AS SUCH COPIES (1) ARE FOR YOUR OR OTHERS
# PERSONAL USE ONLY, AND (2) ARE NOT DISTRIBUTED OR USED
# COMMERCIALLY.  PROHIBITED COMMERCIAL DISTRIBUTION INCLUDES BY ANY
# SERVICE THAT CHARGES FOR DOWNLOAD TIME OR FOR MEMBERSHIP.>>

# Obviously that is going to taint the analysis. But it also serves as a 
# convenient marker to divide that long, long, long string into separate documents.

shakespeare = strsplit(shakespeare, "<<[^>]*>>")[[1]]
length(shakespeare)
str(shakespeare)

summary(shakespeare)

# This left me with a list of 218 documents. On further inspection, 
# some of them appeared to be a little on the short side (in my limited experience, 
# the bard is not known for brevity). As it turns out, the short documents were 
# the dramatis personae for his plays. I removed them as well.

(dramatis.personae <- grep("Dramatis Personae", shakespeare, ignore.case = TRUE))
shakespeare = shakespeare[-dramatis.personae]
length(shakespeare)
str(shakespeare)
summary(shakespeare)

# Down to 182 documents, each of which is a complete work.
# The next task was to convert these documents into a corpus.

library(tm)

doc.vec <- VectorSource(shakespeare)
doc.corpus <- Corpus(doc.vec)
inspect(doc.corpus)
length(doc.corpus)

str(doc.corpus)
summary(doc.corpus)

meta(doc.corpus[[1]])

# A corpus with 182 text documents

# The metadata consists of 2 tag-value pairs and a data frame
# Available tags are:
#   create_date creator 
# Available variables in the data frame are:
#   MetaID

# There is a lot of information in those documents which is not particularly 
# useful for text mining. So before proceeding any further, we will clean 
# things up a bit. First we convert all of the text to lowercase and then 
# remove punctuation, numbers and common English stopwords. Possibly the 
# list of English stop words is not entirely appropriate for Shakespearean 
# English, but it is a reasonable starting point.

#doc.corpus <- tm_map(doc.corpus, tolower)
#doc.corpus <- tm_map(doc.corpus, removePunctuation)
#doc.corpus <- tm_map(doc.corpus, removeNumbers)

# above changes from char structure so below is recommended

doc.corpus <- tm_map(doc.corpus, content_transformer(tolower))
doc.corpus <- tm_map(doc.corpus, content_transformer(removePunctuation)) # remove punctuation
doc.corpus <- tm_map(doc.corpus, content_transformer(removeNumbers))

doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))

# apparently tm used to convert tolower etc as text, but it changed so need to make PlainTextDocument
#doc.corpus <- tm_map(doc.corpus, PlainTextDocument)

############
# I have added some meta data so that the different documents are identified
# 
# I only needed this when I had to use PlainText

#for (n in 1:length(doc.corpus)) {
#  meta(doc.corpus[[n]], tag='creator') <- 'Will Shakespeare'
#  meta(doc.corpus[[n]], tag='heading') <- n
#  meta(doc.corpus[[n]], tag='id') <- n
#  meta(doc.corpus[[n]], tag='description') <- n
#}

#meta(doc.corpus[[6]])


# Next we perform stemming, which removes affixes from words (so, for example,
# "run�, �runs� and �running� all become �run�).

library(SnowballC)
doc.corpus <- tm_map(doc.corpus, stemDocument)

# All of these transformations have resulted in a lot of whitespace, which is then removed.
doc.corpus <- tm_map(doc.corpus, stripWhitespace)

# If we have a look at what�s left, we find that it�s just the lowercase, stripped down version 
# of the text (which I have truncated here)
inspect(doc.corpus[8])

# This is where things start to get interesting. Next we create a Term Document Matrix (TDM) 
# which reflects the number of times each word in the corpus is found in each of the documents.

TDM <- TermDocumentMatrix(doc.corpus)
TDM
inspect(TDM[1:10,1:10])

# The extract from the TDM shows, for example, that the word �abandond� occurred 
# once in document number 2 but was not present in any of the other first ten documents. 
# We could have generated the transpose of the DTM as well.

DTM <- DocumentTermMatrix(doc.corpus)
inspect(DTM[1:10,1:10])

# Which of these proves to be most convenient will depend on the relative number 
# of documents and terms in your data.

# Now we can start asking questions like: what are the most frequently occurring terms?
findFreqTerms(TDM, 2000)


freqTerms <- rowSums(as.matrix(TDM))
freqTerms
freqTerms <- subset(freqTerms, freqTerms>=2000)
names(freqTerms)
str(freqTerms)

barplot(freqTerms, las=2)

# Each of these words occurred more that 2000 times.
# What about associations between words? Let�s have a look at what other words had a high association with �love�.

findAssocs(TDM, "love", 0.8)
findAssocs(TDM, "exeunt", 0.8)

# Well that�s not too surprising!

# From our first look at the TDM we know that there are many terms which do not 
# occur very often. It might make sense to simply remove these sparse terms from the analysis.

TDM.common = removeSparseTerms(TDM, 0.1)
dim(TDM)
dim(TDM.common)

# From the 18651 terms that we started with, we are now left with a TDM which considers 
# on 61 commonly occurring terms.

inspect(TDM.common[1:10,1:10])

# Finally we are going to put together a visualisation. The TDM is stored as a sparse matrix. 
# This was an apt representation for the initial TDM, but the reduced TDM containing only 
# frequently occurring words is probably better stored as a normal matrix. We�ll make the conversion and see.

library(slam)
TDM.dense <- as.matrix(TDM.common)
TDM.dense
object.size(TDM.common)
object.size(TDM.dense)

# So, as it turns out the sparse representation was actually wasting space! 
# (This will generally not be true though: it will only apply for a matrix consisting of 
# just the common terms). Anyway, we need the data as a normal matrix in order to produce 
# the visualisation. The next step is to convert it into a tidy format.

library(reshape2)

TDM.dense = melt(TDM.dense, value.name = "count")
head(TDM.dense)

# And finally generate the visualisation.
library(ggplot2)

ggplot(TDM.dense, aes(x = Docs, y = Terms, fill = log10(count))) +
       geom_tile(colour = "white") +
       scale_fill_gradient(high="#FF0000" , low="#FFFFFF") +
       ylab("") +
       theme(panel.background = element_blank()) +
       theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) 

# The colour scale indicates the number of times that each of the terms 
# cropped up in each of the documents. I applied a logarithmic transform 
# to the counts since there was a very large disparity in the numbers across 
# terms and documents. The grey tiles correspond to terms which are not found 
# in the corresponding document.

# One can see that some terms, like �will� turn up frequently in most documents, 
# while �love� is common in some and rare or absent in others.


