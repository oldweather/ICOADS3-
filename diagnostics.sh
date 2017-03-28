# Tools to check ICOADS3+

# Calculate the SLP bias for each ob in both R3 and R3+
R --no-save < multibatch.fo.R

# Wait for them to finish and then make the plot.


# Also comparison scripts 

# Compare effect of merging three improved decks.
#
# cm_compare.R --year=1801 --month=6  

# Compare effect of imputing obs at missing hours.
#
# na_compare.R --year=1801 --month=6  

# Compare effect of bias adjustment.
#
# bc_compare.R --year=1801 --month=6  

# Compare R3+ with R3
#
# plus_compare.R --year=1801 --month=6  

