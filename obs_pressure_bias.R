#!/usr/bin/Rscript --no-save

# Month-by-month pressure bias information in ICOADS

library(parallel)
library(lubridate)
library(IMMA)
library(GSDF.TWCR)
library(getopt)

opt = getopt(c(
  'year',   'y', 2, "integer",
  'month',  'm', 2, "integer"
));
if ( is.null(opt$year  ) )   { stop("Year not specified") }

year<-opt$year
month<-opt$month
n.total<-days_in_month(ymd(sprintf("%04d-%02d-01",year,month)))*24

datadir<-Sys.getenv('SCRATCH')

# load the R3 obs
o<-ReadObs(sprintf("%s/ICOADS3+/noon.assumptions/IMMA1_R3.0.0_%04d-%02d.gz",
                   datadir,year,month))

# Add the pressure comparisons for a selected hour
compare<-function(n.hour) {
  day<-as.integer(n.hour/24)+1
  hour<-n.hour%%24
  w<-which(!is.na(o$DY) & !is.na(o$HR) & !is.na(o$SLP) &
           !is.na(o$LAT) & !is.na(o$LON))
  if(length(w)==0) return(NULL)
  o2<-o[w,]
  w<-which(o2$DY==day & as.integer(o2$HR)==hour)
  if(length(w)==0) return()
  o3<-o2[w,]
  p.norm<-TWCR.get.slice.at.hour('prmsl',2014,month,day,hour,
                                 type='normal',version='3.4.1')
  p.sd<-TWCR.get.slice.at.hour('prmsl',2014,month,day,hour,
                                 type='standard.deviation',version='3.4.1')
  TWCR.prmsl.norm<-GSDF.interpolate.ll(p.norm,o3$LAT,o3$LON)
  o3<-cbind(o3,TWCR.prmsl.norm)
  TWCR.prmsl.sd<-GSDF.interpolate.ll(p.sd,o3$LAT,o3$LON)
  o3<-cbind(o3,TWCR.prmsl.sd)
  return(o3)
}
  

res<-lapply(seq(0,n.total),compare)
result<-list()
for(i in seq_along(res)) {
  if(!is.null(res[[i]])) result<-rbind(result,res[[i]])
}
saveRDS(result,sprintf("%s/ICOADS3+/bias.checks/%04d.%02d.Rdata",
                   datadir,year,month))
