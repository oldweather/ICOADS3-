# ICOADS3+

Updates to ICOADS R3 to provide better input for ISPD4.

ICOADS R3 has some problems with early data: 

* Improved versions are available for the oldWeather input datasets. These updates should be included.
* Many early observations have a pressure, but no hour (becaused the record they are based on didn't say when the pressure observation was made). It is likely that they were made at local noon and using this assumption would make all the observations useable.
* [Pre-1870 pressure observations are systematically biased low](http://reanalyses.org/index.php/observations/pressure-biases-early-ship-observations). We believe this is because early marine barometers were systematically defective, and we should remove the bias by applying a correction to each ship. 

The scripts in this directory make all these corrections, producing an equivalent to ICOADS R3 (covering 1800 to 1925). The idea is that this replacement can serve as a replacement for ICOADS R3 over this period. We are calling it ICOADS3+, but note that it's not an official ICOADS release or product. 

Master script is [runall.sh](runall.sh)

Decks to replace are:

1. oldWeather 1/2 - RN WW1 obs: ICOADS3 deck 249, replacement data from https://github.com/oldweather/oldWeather1
2. oldWeather 3 - US Arctic obs obs: ICOADS3 deck 710, replacement data from https://github.com/oldweather/oldWeather3

For diagnostics see [diagnostics.sh](disgnostics.sh)
