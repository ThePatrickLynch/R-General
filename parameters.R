args <- commandArgs(trailingOnly = TRUE)
rnorm(n=as.numeric(args[1]), mean=as.numeric(args[2]))