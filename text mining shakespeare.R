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

# This left me with a list of 218 documents. On further inspection, 
# some of them appeared to be a little on the short side (in my limited experience, 
# the bard is not known for brevity). As it turns out, the short documents were 
# the dramatis personae for his plays. I removed them as well.

(dramatis.personae <- grep("Dramatis Personae", shakespeare, ignore.case = TRUE))
shakespeare = shakespeare[-dramatis.personae]
length(shakespeare)

# Down to 182 documents, each of which is a complete work.
# The next task was to convert these documents into a corpus.

library(tm)

doc.vec <- VectorSource(shakespeare)
doc.corpus <- Corpus(doc.vec)
summary(doc.corpus)

A corpus with 182 text documents

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

doc.corpus <- tm_map(doc.corpus, tolower)
doc.corpus <- tm_map(doc.corpus, removePunctuation)
doc.corpus <- tm_map(doc.corpus, removeNumbers)
doc.corpus <- tm_map(doc.corpus, removeWords, stopwords("english"))

# Next we perform stemming, which removes affixes from words (so, for example,
# "run”, “runs” and “running” all become “run”).

library(SnowballC)
doc.corpus <- tm_map(doc.corpus, stemDocument)

# All of these transformations have resulted in a lot of whitespace, which is then removed.
doc.corpus <- tm_map(doc.corpus, stripWhitespace)

# If we have a look at what’s left, we find that it’s just the lowercase, stripped down version 
# of the text (which I have truncated here)
inspect(doc.corpus[8])

# This is where things start to get interesting. Next we create a Term Document Matrix (TDM) 
# which reflects the number of times each word in the corpus is found in each of the documents.

TDM <- TermDocumentMatrix(doc.corpus)
TDM

# http://www.r-bloggers.com/text-mining-the-complete-works-of-william-shakespeare/

