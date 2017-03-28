# Make a set of IMMA files identical to R3.0 except with
#  ship-by-ship bias adjustments applied to SLP.

library(IMMA)
bias.ship<-readRDS(sprintf("%s/ICOADS3+/bias.checks/bias.ship.Rdata",Sys.getenv('SCRATCH')))
bias.year<-readRDS(sprintf("%s/ICOADS3+/bias.checks/bias.year.deck.Rdata",Sys.getenv('SCRATCH')))

for(year in seq(1800,1869,1)) {
  for(month in seq(1,12)) {
    i.file<-sprintf("%s/ICOADS3+/noon.assumptions/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),year,month)
    if(!file.exists(i.file)) next
    obs<-ReadObs(i.file)
    w<-which(is.null(obs$SUPD) | is.na(obs$SUPD))
    if(length(w)>0) obs$SUPD[w]<-' ' 
    ids<-unique(obs$ID)
    for(f in ids) {
       if(is.null(bias.ship[[f]])) next
       w<-which(obs$ID==f & !is.na(obs$SLP))
       if(length(w)==0) next
       obs$has.C99[w]<-TRUE
       obs$SLP[w]<-obs$SLP[w]-bias.ship[[f]]
       obs$SUPD[w]<-sprintf("%s Ship SLP bias=%5.2f",obs$SUPD[w],bias.ship[[f]])
     }
    for(deck in unique(obs$DCK)) {
        if(length(bias.year[[year]])<deck) next
        if(is.null(bias.year[[year]][[deck]])) next
        w<-which(!(obs$ID %in% names(bias.ship)) & !is.na(obs$SLP) & obs$DCK==deck)
        if(length(w)>0) {
           obs$has.C99[w]<-TRUE
           obs$SLP[w]<-obs$SLP[w]-bias.year[[year]][[deck]]
           obs$SUPD[w]<-sprintf("%s deck/year SLP bias=%5.2f",obs$SUPD[w],bias.year[[year]][[deck]])
        }
    }
    o.file<-gzfile(sprintf("%s/ICOADS3+/debiased/IMMA1_R3.0.0_%04d-%02d.gz",
                        Sys.getenv('SCRATCH'),year,month),open='w')
    WriteObs(obs,o.file)
    close(o.file)
  }
}
warnings()
