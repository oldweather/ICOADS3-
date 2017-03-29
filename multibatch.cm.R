# Run the ICOADS3+ monthly merge on SPICE

peak.no.jobs<-500

for (year in seq(1800,1925)) {
  in.system<-system('squeue --user hadpb',intern=TRUE)
  n.new.jobs<-peak.no.jobs-length(in.system)
  while(n.new.jobs<12) {
   Sys.sleep(10)
   in.system<-system('squeue --user hadpb',intern=TRUE)
   n.new.jobs<-peak.no.jobs-length(in.system)
  }
  for (month in seq(1,12)) {
      sink('ICOADS3+.merge.slm')
      cat('#!/bin/ksh -l\n')
      cat('#SBATCH --output=/scratch/hadpb/slurm_output/ICOADS3+.merge-%j.out\n')
      cat('#SBATCH --qos=normal\n')
      cat('#SBATCH --mem=5000\n')
      cat('#SBATCH --ntasks=1\n')
      cat('#SBATCH --ntasks-per-core=2\n')
      cat('#SBATCH --time=10\n')
         cat(sprintf("./copy_and_merge_month.R --year=%d --month=%d \n",
                     year,month))
     sink()
     system('sbatch ICOADS3+.merge.slm')
     unlink('ICOADS3+.merge.slm')
  }
}
