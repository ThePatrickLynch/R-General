library("RCurl")
library(XML)

# TODO: Iterate over a text file or spider links
# WGET is cheap in effort for website crawling

# Changeme
url="http://www.rogerclarke.com/DV/CanModel.html"
dir="/home/aberg/Desktop/WORKSHOP-ETHICS/To-cloud/"

# TODO make
file= paste(runif(1),".txt", sep="")

html <- getURL(url, followlocation = TRUE)
# parse html
doc = htmlParse(html, asText=TRUE)
plain.text <- xpathSApply(doc, "//text()[not(ancestor::script)][not(ancestor::style)][not(ancestor::noscript)][not(ancestor::form)]", xmlValue)
sink(paste(dir,file,sep=""))
cat(paste(plain.text, collapse = " "))
sink()
