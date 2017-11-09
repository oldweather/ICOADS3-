# Estimate SLP bias by year and deck 1800-1869

library(IMMA)
library(grid)

diffs<-numeric(0)
filter<-numeric(0)
yr<-numeric(0)
dck<-numeric(0)
for(year in seq(1662,1869)) {
  for(month in seq(1,12)) {
    rdf<-sprintf("%s/ICOADS3+/bias.checks/%04d.%02d.Rdata",Sys.getenv('SCRATCH'),year,month)
    if(!file.exists(rdf)) next
    obs<-readRDS(rdf)
    if(length(obs)==0) next
    diffs<-c(diffs,obs$SLP-obs$TWCR.prmsl.norm/100)
    yr<-c(yr,obs$YR)
    dck<-c(dck,obs$DCK)
  }
}
w<-which(!is.na(diffs))
d2<-diffs[w]
y2<-yr[w]
dck<-dck[w]
bias.year<-list()
for(y in seq(1800,1870)) {
    bias.year[[y]]<-list()
    for(deck in unique(dck)) {
       w<-which(y2==y & dck==deck)
       if(length(w)==0) next
       bias.year[[y]][[deck]]<-mean(d2[w],na.rm=TRUE)
     }
}
saveRDS(bias.year,sprintf("%s/ICOADS3+/bias.checks/bias.year.deck.Rdata",Sys.getenv('SCRATCH')))

