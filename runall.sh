# Run all the scripts to make ICOADS3+

# Operates on $SCRATCH - 
# Set up input and output directories for making ICOADS3+

# $SCRATCH/ICOADS3/IMMA should already contain the ICOADS3.0 records

mkdir $SCRATCH/ICOADS3+
mkdir $SCRATCH/ICOADS3+/merged
mkdir $SCRATCH/ICOADS3+/replacements
mkdir $SCRATCH/ICOADS3+/merged.filled
mkdir $SCRATCH/ICOADS3+/noon.assumptions
mkdir $SCRATCH/ICOADS3+/bias.checks
mkdir $SCRATCH/ICOADS3+/debiased
mkdir $SCRATCH/ICOADS3+/final

# Copy in the source directories for the replacement records
mkdir $SCRATCH/ICOADS3+/replacements/oldWeather1
cp -r $HOME/Projects/oldWeather1/imma/* $SCRATCH/ICOADS3+/replacements/oldWeather1
mkdir $SCRATCH/ICOADS3+/replacements/oldWeather3
cp -r $HOME/Projects/oldWeather3/imma/* $SCRATCH/ICOADS3+/replacements/oldWeather3
mkdir $SCRATCH/ICOADS3+/replacements/Expeditions
cp -r $HOME/Projects/Expeditions/imma/* $SCRATCH/ICOADS3+/replacements/Expeditions

# Run the merge - month by month
R --no-save < multibatch.cm.R
# This submits jobs to SPICE - don't continue until they have all stopped
sleep 60 # Might not be long enough

# Make a full 1800-1925 dataset including the merged records
for year in `seq 1800 1925`
do
  cp $SCRATCH/ICOADS3/IMMA/IMMA1_R3.0.0_$year-* $SCRATCH/ICOADS3+/merged.filled
done
cp $SCRATCH/ICOADS3+/merged/* $SCRATCH/ICOADS3+/merged.filled

# Assume obs with pressures, dates, positions, but no hour were made at noon
R --no-save < multibatch.na.R
# This submits jobs to SPICE - don't continue until they have all stopped
sleep 60 # Might not be long enough

# Bias adjust the pre-1870 pressures

# Make the climatology comparisons
R --no-save < multibatch.bc.R
# This submits jobs to SPICE - don't continue until they have all stopped
sleep 60 # Might not be long enough

# Make the bias estimates
R --no-save < Estimate_correction_for_named_ship.R
R --no-save < Estimate_correction_for_year+deck.R

# Apply the bias estimates
R --no-save < make_debiased_imma.R

# Assemble the complete final dataset 1800-1925
cp $SCRATCH/ICOADS3+/noon.assumptions/* $SCRATCH/ICOADS3+/final
cp $SCRATCH/ICOADS3+/debiased/* $SCRATCH/ICOADS3+/final
