#!/usr/bin/Rscript --no-save

# Compare ICOADS3+ with v3

library(GSDF)
library(GSDF.WeatherMap)
library(getopt)
library(lubridate)
library(RColorBrewer)
library(IMMA)

opt = getopt(matrix(c(
  'year',   'd', 2, "integer",
  'month',  'm', 2, "integer",
  'day',    'e', 2, "integer",
  'hour',   'h', 2, "integer",
  'spread', 's', 2, "integer"
),ncol=4,byrow=TRUE))
if ( is.null(opt$year) )   { stop("Year not specified") }
if ( is.null(opt$month) )  { stop("Month not specified") }
if ( is.null(opt$day) )    { stop("Day not specified") }
if ( is.null(opt$hour) )   { stop("Hour not specified") }
if ( is.null(opt$spread) ) { stop("Spread not specified") }

Imagedir<-sprintf("%s/images/ICOADS3v3p",Sys.getenv('SCRATCH'))
if(!file.exists(Imagedir)) dir.create(Imagedir,recursive=TRUE)

Options<-WeatherMap.set.option(NULL)
Options<-WeatherMap.set.option(Options,'land.colour',rgb(0,0,0,255,
                                                       maxColorValue=255))
Options<-WeatherMap.set.option(Options,'sea.colour',rgb(150,150,150,255,
                                                       maxColorValue=255))
Options<-WeatherMap.set.option(Options,'ice.colour',Options$land.colour)
Options<-WeatherMap.set.option(Options,'background.resolution','high')

Options<-WeatherMap.set.option(Options,'lat.min',-90)
Options<-WeatherMap.set.option(Options,'lat.max',90)
Options<-WeatherMap.set.option(Options,'lon.min',-180)
Options<-WeatherMap.set.option(Options,'lon.max',180)
Options$vp.lon.min<- -180
Options$vp.lon.max<-  180
Options$obs.size<- 2.0

land<-WeatherMap.get.land(Options)
land<-GSDF:::GSDF.pad.longitude(land)

ReadObs.cache<-function(file.name,start,end) {
  result<-data.frame()
  batch.length<-100000
  f.in<-file(file.name)
  open(f.in)
  while(batch.length==100000) {
      result.batch<-ReadObs(f.in,100000)
      batch.length<-length(result.batch$HR)
      w<-which(is.na(result.batch$HR))
      if(length(w)>0) result.batch$HR[w]<-12
      result.dates<-ymd_hms(sprintf("%04d-%02d-%02d %02d:%02d:00",
                                    as.integer(result.batch$YR),
                                    as.integer(result.batch$MO),
                                    as.integer(result.batch$DY),
                                    as.integer(result.batch$HR),
                                    as.integer((result.batch$HR%%1)*60)))
      is.na(result.batch$HR[w])<-TRUE
      w<-which(result.dates>=start & result.dates<end)
      if(length(w)==0) next
      result.batch<-result.batch[w,]
        if(length(colnames(result))==0) {
          result<-result.batch
        } else {
          result<-merge(result, result.batch, all=TRUE)
        }
     gc(verbose=FALSE)
  }
  close(f.in)
  return(result)
}

ICOADS.3.0.get.obs<-function(year,month,day,hour,duration) {
  start<-ymd_hms(sprintf("%04d-%02d-%02d %02d:30:00",year,month,day,hour))-
    hours(duration/2)
  end<-start+hours(duration)
  files<-unique(c(sprintf("%s/ICOADS3/IMMA/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),as.integer(year(start)),
                                as.integer(month(start))),
                  sprintf("%s/ICOADS3/IMMA/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),as.integer(year(end)),
                                as.integer(month(end)))))
  result<-data.frame()
  for(file in files) {
    if(!file.exists(file)) next
    o<-ReadObs.cache(file,start,end)
    if(length(o$YR)==0) next
    if(length(colnames(result))==0) {
      result<-o
    } else {
      result<-merge(result, o, all=TRUE)
    }
  }
  w<-which(result$LON>180)
  if(length(w)>0) result$LON[w]<- result$LON[w]-360
  return(result)
}
ICOADS.3.p.get.obs<-function(year,month,day,hour,duration) {
  start<-ymd_hms(sprintf("%04d-%02d-%02d %02d:30:00",year,month,day,hour))-
    hours(duration/2)
  end<-start+hours(duration)
  files<-unique(c(sprintf("%s/ICOADS3+/final/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),as.integer(year(start)),
                                as.integer(month(start))),
                  sprintf("%s/ICOADS3+/final/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),as.integer(year(end)),
                                as.integer(month(end)))))
  result<-data.frame()
  for(file in files) {
    if(!file.exists(file)) next
    o<-ReadObs.cache(file,start,end)
    if(length(o$YR)==0) next
    if(length(colnames(result))==0) {
      result<-o
    } else {
      result<-merge(result, o, all=TRUE)
    }
  }
  w<-which(result$LON>180)
  if(length(w)>0) result$LON[w]<- result$LON[w]-360
  return(result)
}

# Functions to find which obs have been replaced/added
is.replacement<-function(after) {
  w<-which(!after$has.C98)
  if(length(w)==0) return(NULL)
  return(after[w,])               
}
has.new.hour<-function(before,after) {
  w<-which(!is.na(after$LAT) & !is.na(after$LON) &
           !is.na(after$SLP) & !is.na(after$HR)  &
           after$has.C98     & !is.na(after$UID))
  if(length(w)==0) return(NULL)
  after<-after[w,]
  w<-which(!is.na(before$LAT) & !is.na(before$LON) &
           !is.na(before$SLP) & !is.na(before$HR)   &
           before$has.C98     & !is.na(before$UID))
  if(length(w)==0) return(after)
  before<-before[w,]
  w<-which(after$UID %in% before$UID)
  if(length(w)==0) return(after)
  return(after[-w,])               
}
is.bias.corrected<-function(after) {
  w<-which(!is.na(after$SUPD))
  after<-after[w,]
  w<-which(grepl('SLP bias=',after$SUPD))
  after<-after[w,]
  r<-regmatches(after$SUPD,regexpr('SLP bias=(.*)',after$SUPD))
  after$bias<-as.numeric(sub('SLP bias=(.*)','\\1',r))
  return(after)
}

# Plot a subset of the obs
plot.obs.set<-function(obs,colour,Options) {
  w<-which(!is.na(obs$LAT) & !is.na(obs$LON))
  if(length(w)==0) return()
  obs<-obs[w,]
  Options<-WeatherMap.set.option(Options,'obs.colour',colour)
  obs$Latitude<-obs$LAT
  obs$Longitude<-obs$LON
  WeatherMap.draw.obs(obs,Options)
}
  

plot.day<-function(year,month,day,hour,duration) {    

    image.name<-sprintf("%04d-%02d-%02d:%02d.png",year,month,day,hour)
    ifile.name<-sprintf("%s/%s",Imagedir,image.name)
    if(file.exists(ifile.name) && file.info(ifile.name)$size>0) return()

    obs.3<-ICOADS.3.0.get.obs(year,month,day,hour,duration)
    obs.3p<-ICOADS.3.p.get.obs(year,month,day,hour,duration)
   
     png(ifile.name,
             width=1080*16/9,
             height=1080,
             bg=Options$sea.colour,
             pointsize=24,
             type='cairo-png')
    Options$label<-sprintf("%04d-%02d-%02d",year,month,day)
  
  	   pushViewport(dataViewport(c(Options$vp.lon.min,Options$vp.lon.max),
  				     c(Options$lat.min,Options$lat.max),
  				      extension=0))
      WeatherMap.draw.land(land,Options)
      if(length(obs.3)>0) {
          w<-which(is.na(obs.3p$SLP))
          if(length(w)>0) plot.obs.set(obs.3p[w,],rgb(0.65,0.65,0.65),Options)
          w<-which(!is.na(obs.3p$SLP))
          if(length(w)>0) plot.obs.set(obs.3p[w,],rgb(0.3,0.3,0.3),Options)
          debiased<-is.bias.corrected(obs.3p)
          w<-which(debiased$bias>5)
          if(length(w)>0) {
            plot.obs.set(debiased[w,],rgb(1,0,0),Options)
          }             
          w<-which(debiased$bias>1 & debiased$bias<=5)
          if(length(w)>0) {
            plot.obs.set(debiased[w,],rgb(0.65,0.35,0.35),Options)
          }             
          w<-which(debiased$bias< -1 & debiased$bias>= -5)
          if(length(w)>0) {
            plot.obs.set(debiased[w,],rgb(0.35,0.35,0.65),Options)
          }             
          w<-which(debiased$bias< -5)
          if(length(w)>0) {
            plot.obs.set(debiased[w,],rgb(0,0,1),Options)
          }                     
          added<-is.replacement(obs.3p)
          if(!is.null(added) && length(added$YR)>0) {
            plot.obs.set(added,rgb(1,0.84,0.1),Options)
          }
          new.hour<-has.new.hour(obs.3,obs.3p)
          if(!is.null(new.hour) && length(new.hour$YR)>0) {
            plot.obs.set(new.hour,rgb(1,0.5,0),Options)
          }
        }
     Options<-WeatherMap.set.option(Options,'land.colour',rgb(100,100,100,255,
                                                           maxColorValue=255))
      WeatherMap.draw.label(Options)
    dev.off()
  }


plot.day(opt$year,opt$month,opt$day,opt$hour,opt$spread)

