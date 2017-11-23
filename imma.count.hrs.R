#!/usr/bin/env Rscript

# Count the hour records in imma files

library(IMMA)
library(getopt)

count<-0
rec<-0
files=system("ls /scratch/hadpb/ICOADS3/IMMA//IMMA1_R3.0.0_18{0,1,2,3,4,5,6}*.gz",intern=TRUE)
for(f in files) {
   o<-ReadObs(f)
   for(var in c('HR')) {
     w<-which(!is.na(o[[var]]))
     count<-count+length(w)
     rec<-rec+length(o$YR)
   }
 }
print(sprintf("Total of %d hours in %d records",count,rec))

