#!/usr/bin/env Rscript

# Update components of ICOADS3 to add new obs.

library(IMMA)
library(getopt)
opt = getopt(matrix(c(
  'year',   'y', 2, "integer",
  'month',  'm', 2, "integer"
), byrow=TRUE, ncol=4))
if ( is.null(opt$year  ) )   { stop("Year not specified") }
if ( is.null(opt$month ) )   { stop("Month not specified") }

decks.to.filter<-c(249,710)

# Find all the obs to be added for this month
dirs.to.add<-c('oldWeather1','oldWeather3')
decks.to.add<-list(oldWeather1=249,oldWeather3=710)
to.add<-NULL
for(dir in dirs.to.add) {
  files.to.add<-list.files(sprintf("%s/ICOADS3+/replacements/%s",
                                   Sys.getenv('SCRATCH'),
                                   dir))
  for(file in files.to.add) {
    o<-ReadObs(sprintf("%s/ICOADS3+/replacements/%s/%s",
                                   Sys.getenv('SCRATCH'),
                                   dir,file))
    # Add the deck to the new ob - for later bias adjustment
    o$has.C1<-TRUE
    o$DCK<-decks.to.add[[dir]]
    w<-which(o$YR==opt$year & o$MO==opt$month)
    if(length(w)>0) {
      o<-o[w,]
      w<-which(!is.na(o$LON) & o$LON<0)
      if(length(w)>0) o$LON[w]<-o$LON[w]+360
      if(length(to.add)==0) {
        to.add<-o
      } else {
          pad1<-setdiff(colnames(to.add), colnames(o))
          for(pd in pad1) {
            o[[pd]]<-rep(NA,length(o$YR))
          }
          pad2<-setdiff(colnames(o), colnames(to.add))
          for(pd in pad2) {
            to.add[[pd]]<-rep(NA,length(to.add$YR))
          }
          cols <- union(colnames(to.add), colnames(o))
          to.add<-rbind(to.add[,cols], o[,cols])
        
      }
    }
  }
}

# Get the ICOADS3 data for the month
orig<-ReadObs(sprintf("%s/ICOADS3/IMMA/IMMA1_R3.0.0_%04d-%02d.gz",
                      Sys.getenv('SCRATCH'),opt$year,opt$month))
w<-which(orig$DCK %in% decks.to.filter)
if(length(w)==0 && length(to.add)==0) {
  q('no') # Nothing to do this month
}

if(length(w)>0) {
  orig<-orig[-w,]
}

if(length(to.add)>0) {
      pad1<-setdiff(colnames(to.add), colnames(orig))
      for(pd in pad1) {
        orig[[pd]]<-rep(NA,length(orig$YR))
      }
      pad2<-setdiff(colnames(orig), colnames(to.add))
      for(pd in pad2) {
        to.add[[pd]]<-rep(NA,length(to.add$YR))
      }
     cols <- union(colnames(to.add), colnames(orig))
    orig<-rbind(to.add[,cols], orig[,cols])
    orig<-orig[order(orig$DY,orig$HR,na.last=FALSE),]
}

# Output the result
o.file<-gzfile(sprintf(sprintf("%s/ICOADS3+/merged/IMMA1_R3.0.0_%04d-%02d.gz",
                       Sys.getenv('SCRATCH'),opt$year,opt$month)))
WriteObs(orig,o.file)
