# Plot systematic comparisons of observed SLP and reanalysis climatology
#  1800-1870.

# Compare uncorrected with corrected data

library(IMMA)
library(grid)

diffs<-numeric(0)
yr<-numeric(0)
for(year in seq(1800,1869)) {
  for(month in seq(1,12)) {
    rdf<-sprintf("%s/ICOADS3+/bias.checks/original_%04d.%02d.Rdata",
                        Sys.getenv('SCRATCH'),year,month)
    if(!file.exists(rdf)) next
    obs<-readRDS(rdf)
    diffs<-c(diffs,obs$SLP-obs$TWCR.prmsl.norm/100)
    yr<-c(yr,obs$YR)
  }
}
diffs2<-numeric(0)
yr2<-numeric(0)
for(year in seq(1800,1869)) {
  for(month in seq(1,12)) {
    rdf<-sprintf("%s/ICOADS3+/bias.checks/final_%04d.%02d.Rdata",
                        Sys.getenv('SCRATCH'),year,month)
    if(!file.exists(rdf)) next
    obs<-readRDS(rdf)
    diffs2<-c(diffs2,obs$SLP-obs$TWCR.prmsl.norm/100)
    yr2<-c(yr,obs$YR)
  }
}

pdf(file="Check_corrections.pdf",
    height=20/sqrt(2),width=20,family='Helvetica',
    paper='special',pointsize=18,bg='white')

    pushViewport(viewport(width=1.0,height=1.0,x=0.0,y=0.0,
			  just=c("left","bottom"),name="Page",clip='on'))
       pushViewport(plotViewport(margins=c(4,6,0,0)))
	  pushViewport(dataViewport(seq(1800,1870),c(-15,15),clip='off'))
	     grid.xaxis(at=seq(1800,1870,10),main=T)
	     grid.text('Date',y=unit(-3,'lines'))
	     grid.yaxis(main=T)
	     grid.text("Mean bias",x=unit(-4,'lines'),rot=90)

             # horizontal line at 0
	     gp=gpar(col=rgb(0.5,0.5,0.5,1),fill=rgb(0.5,0.5,0.5,1),lwd=1)
             grid.lines(x=unit(c(1800,1869),'native'),
                        y=unit(0,'native'),gp=gp)

	     gp=gpar(col=rgb(1,0,0,1),fill=rgb(1,0,0,1),lwd=6)
	     gp2=gpar(col=rgb(0,0,1,1),fill=rgb(0,0,1,1),lwd=6)

             for(year in seq(1800,1869)) {
               w<-which(yr2==year)
               cd.bias.mean<-mean(diffs2[w],na.rm=TRUE)
               cd.bias.se<-sd(diffs2[w],na.rm=TRUE)/sqrt(length(w))
               grid.lines(x=unit(year,'native'),
                          y=unit(c(cd.bias.mean+2*cd.bias.se,
                                   cd.bias.mean-2*cd.bias.se),'native'),
                          gp=gp2)
               w<-which(yr==year)
               bias.mean<-mean(diffs[w],na.rm=TRUE)
               bias.se<-sd(diffs[w],na.rm=TRUE)/sqrt(length(w))
               grid.lines(x=unit(year,'native'),
                          y=unit(c(bias.mean+2*bias.se,
                                   bias.mean-2*bias.se),'native'),
                          gp=gp)
             }

	  popViewport()
       popViewport()
    popViewport()

dev.off()
