#!/usr/bin/env Rscript

# Compare merged files

library(getopt)
opt = getopt(matrix(c(
  'year',   'y', 2, "integer",
  'month',  'm', 2, "integer"
), byrow=TRUE, ncol=4))
if ( is.null(opt$year  ) )   { stop("Year not specified") }
if ( is.null(opt$month ) )   { stop("Month not specified") }

system(sprintf("cp %s/ICOADS3/IMMA/IMMA1_R3.0.0_%04d-%02d.gz pre.gz",
                 Sys.getenv('SCRATCH'),opt$year,opt$month))
system('gunzip pre.gz')

system(sprintf("cp %s/ICOADS3+/merged/IMMA1_R3.0.0_%04d-%02d.gz post.gz",
                 Sys.getenv('SCRATCH'),opt$year,opt$month))
system('gunzip post.gz')

system('tkdiff pre post')

system('rm pre post')

