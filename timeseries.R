rm(list=ls())

setwd('d:/Data/Working Analytics')
getwd()

####
# to start with I want to get a list of student ids from the cohort - I only want those who passed the essay
# this file has results data for the module
####

users <- read.csv('CMPST_00699 essay data.csv')
events <- read.csv('CMPST_00699 events.csv')

str(events)
as.character(events$EVENT_DATE)

events$EVENT_DATE <- as.POSIXct(as.character(events$EVENT_DATE), format="%d/%m/%Y %H:%M")

justDates <- events$EVENT_DATE

justDates
str(justDates)
attributes(justDates)
plot(justDates, )
apts <- ts(justDates, frequency=12)
f <- decompose(apts)
f
apts
f$figure
plot(f)
