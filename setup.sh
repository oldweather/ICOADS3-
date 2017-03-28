#!/usr/bin/sh

# Set up input and output directories for making ICOADS3+

mkdir $SCRATCH/ICOADS3+
mkdir $SCRATCH/ICOADS3+/merged
mkdir $SCRATCH/ICOADS3+/replacements

mkdir $SCRATCH/ICOADS3+/replacements/oldWeather1
cp -r $HOME/Projects/oldWeather1/imma/* $SCRATCH/ICOADS3+/replacements/oldWeather1
mkdir $SCRATCH/ICOADS3+/replacements/oldWeather3
cp -r $HOME/Projects/oldWeather3/imma/* $SCRATCH/ICOADS3+/replacements/oldWeather3
mkdir $SCRATCH/ICOADS3+/replacements/Expeditions
cp -r $HOME/Projects/Expeditions/imma/* $SCRATCH/ICOADS3+/replacements/Expeditions
