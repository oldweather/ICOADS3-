# Estimate SLP bias by year and deck 1800-1869

library(IMMA)
library(grid)

diffs<-numeric(0)
filter<-numeric(0)
yr<-numeric(0)
for(year in seq(1800,1870)) {
  for(month in seq(1,12)) {
    rdf<-sprintf("%s/ICOADS3+/bias.checks/%04d.%02d.Rdata",Sys.getenv('SCRATCH'),year,month)
    if(!file.exists(rdf)) next
    obs<-readRDS(rdf)
    diffs<-c(diffs,obs$SLP-obs$TWCR.prmsl.norm/100)
    filter<-c(filter,obs$ID)
    yr<-c(yr,obs$YR)
  }
}
w<-which(!is.na(diffs))
d2<-diffs[w]
y2<-yr[w]
f2<-filter[w]
t<-table(f2)
w<-which(t>10)
filters<-attr(t,'dimnames')$f2[w]
bias.ship<-list()
#bias.ship[unique(filter)]<-0
for(f in seq_along(filters)) {
    w<-which(filter==filters[f])
    bias.ship[[filters[f]]]<-mean(diffs[w],na.rm=TRUE)
}
saveRDS(bias.ship,sprintf("%s/ICOADS3+/bias.checks/bias.ship.Rdata",Sys.getenv('SCRATCH'),year,month))

