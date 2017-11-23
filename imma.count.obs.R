#!/usr/bin/env Rscript

# Count the weather observations in imma files
# 'observations' means total number of veather variables
#  in core. 1 record with SST, AT, SLP W and WD is 5 obs.

library(IMMA)
library(getopt)

f<-file('stdin')
o.count<-0
t.count<-0
open(f)
while(TRUE) {
    o<-ReadObs(f,n=1000)
    for(var in c('D','W','SLP','AT','WBT','SST')) {
      w<-which(!is.na(o[[var]]))
      o.count<-o.count+length(w)
    }
    t.count<-t.count+length(o$YR)
    if(length(o$YR)!=1000) break
}
print(sprintf("Total of %d observations from %d records",o.count,t.count))

