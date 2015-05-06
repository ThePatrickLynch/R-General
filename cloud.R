library(wordcloud)
library(tm)

# Changeme - Location of text files
dir="/home/aberg/Desktop/WORKSHOP-ETHICS/To-cloud"
mypdf="/home/aberg/Desktop/workshop.pdf"

myCorpus <-Corpus(DirSource(dir), readerControl = list(language="en"))
myCorpus = tm_map(myCorpus, content_transformer(tolower))
myCorpus = tm_map(myCorpus, removePunctuation)
myCorpus = tm_map(myCorpus, removeNumbers)
myCorpus = tm_map(myCorpus, removeWords, stopwords(kind="nl"))
myCorpus = tm_map(myCorpus, removeWords, stopwords(kind="en"))
myCorpus = tm_map(myCorpus, removeWords, 
            c("andor","however", "used","may","well","many","waar","gaan","binnen","july","can","gartner","use","stategienotadoc",
               "bestandsnaam","using","must","bij","also","even","business","will","services","market",
              "een","het","etc","btw", "first","much","might","field","given","right","whether",
               "ten","moeten","one","new","way","see", "include","need","example","best","cmt",
              "hoeft", "aantal","tussen","daarnaast", "door","goed","aanzien","gaat","zoals","vanaf","zullen"))
myDTM = TermDocumentMatrix(myCorpus, control = list(minWordLength = 4))
m = as.matrix(myDTM)
v = sort(rowSums(m), decreasing = TRUE)
set.seed(903993)
pdf(file=mypdf)
wordcloud(names(v), v, min.freq=80, random.color=FALSE,colors=brewer.pal(8, "Dark2"),
          random.order=FALSE, rot.per=.15,scale=c(8,.2) )
dev.off()

# Good for Workshop exercises
# Needs human filtering to find trigger words
findAssocs(myDTM, 'privacy', 0.80)
