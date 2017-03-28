# ICOADS3+

Updates to ICOADSR3 to provide better input for ISPD4.

ICOADSR3 has some problems with early data: 
* Some data was deleted by the land mask - ships in port and on rivers. These should be replaced.
* Improved versions are available for the oldWeather input datasets. These updates should be incoporated.
* Many early observations have a pressure, but no hour (becaused the record they are based on didn't say when the pressure observation was made). It is likely that they were made at local noon and using this assumption would make all the observations useable.
* [Pre-1870 pressure observations are systematically biased low](http://reanalyses.org/index.php/observations/pressure-biases-early-ship-observations). We believe this is because early marine barometers were systematically defective, and we should remove the bias by applying a correction to each ship. 

The scripts in this directory make all these corrections, producing an equivalent to ICOADSR3 (covering 1800 to 1950). We are calling this ICOADS3+, but note that it's not an official ICOADS release or product. 

Master script is [runall.sh](runall.sh)

Decks to replace are:
1 ACRE expeditionary data: ICOADS3 deck 246, replacement data from  https://github.com/oldweather/Expeditions
2 oldWeather 1/2 - RN WW1 obs: ICOADS3 deck 249, replacement data from https://github.com/oldweather/oldWeather1
3 oldWeather 3 - US Arctic obs: ICOADS3 deck 710, replacement data from https://github.com/oldweather/oldWeather3

Don't need to replace the EEIC data (deck 248), as it included no port observations.

For diagnostics see [diagnostics.sh](disgnostics.sh)
