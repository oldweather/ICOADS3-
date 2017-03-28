# ICOADS3+

Updates to ICOADSR3 to provide better input for ISPD4.

ICOADSR3 has some problems with early data: 
* Some data was deleted by the land mask - ships in port and on rivers. These should be replaced.
* Improved versions are available for the oldWeather input datasets. These updates should be incoporated.
* Many early observations have a pressure, but no hour (becaused the record they are based on didn't say when the pressure observation was made). It is likely that they were made at local noon and using this assumption would make all the observations useable.
* [http://reanalyses.org/index.php/observations/pressure-biases-early-ship-observations](Pre-1870 pressure observations are systematically biased low). We believe this is because early marine barometers were systematically defective, and we should remove the bias by applying a correction to each ship. 

The scripts in this directory make all these corrections, producing an equivalent to ICOADSR3 (covering 1800 to 1950). We are calling this ICOADS3+, but note that it's not an official ICOADS release or product. 


Selected decks are:

1) ACRE expeditionary data.

  ICOADS3 deck - 246
  Raw obs - https://github.com/oldweather/Expeditions
  local Raw - ../Expeditions/imma/

2) oldWeather 1/2 - RN WW1 obs

  ICOADS3 deck - 249
  Raw obs - https://github.com/oldweather/oldWeather1
  local Raw - ../oldWeather1/imma/

3) oldWeather 3 - US Arctic obs

  ICOADS3 deck - 710
  Raw obs - https://github.com/oldweather/oldWeather3
  local Raw - ../oldWeather3/imma/

Don't need to do this for the EEIC data (deck 248), as it included no port observations.

It would be great to do this for other decks, but I don't have the original
obs.
