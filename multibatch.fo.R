# Calculate the climatological mean and sd for each ob in ICOADS
#  Do for both R3 and Final R3+.

peak.no.jobs<-500

for (year in seq(1800,1869)) {
  in.system<-system('squeue --user hadpb',intern=TRUE)
  n.new.jobs<-peak.no.jobs-length(in.system)
  while(n.new.jobs<12) {
   Sys.sleep(10)
   in.system<-system('squeue --user hadpb',intern=TRUE)
   n.new.jobs<-peak.no.jobs-length(in.system)
  }
  for (month in seq(1,12)) {
      sink('ICOADS3+.fo.slm')
      cat('#!/bin/ksh -l\n')
      cat('#SBATCH --output=/scratch/hadpb/slurm_output/ICOADS3+.fo-%j.out\n')
      cat('#SBATCH --qos=normal\n')
      cat('#SBATCH --mem=5000\n')
      cat('#SBATCH --ntasks=1\n')
      cat('#SBATCH --ntasks-per-core=2\n')
      cat('#SBATCH --time=10\n')
         cat(sprintf("./obs_pressure_bias_original.R --year=%d --month=%d \n",
                     year,month))
         cat(sprintf("./obs_pressure_bias_corrected.R --year=%d --month=%d \n",
                     year,month))
     sink()
     system('sbatch ICOADS3+.fo.slm')
     unlink('ICOADS3+.fo.slm')
  }
}
