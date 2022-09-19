#!/bin/bash

# You can use "./clean cleandata" for clear data folder

echo "----- cleaning ----- "

echo "Removing exp ..."
rm -rf exp

echo "Removing data/lang ..."
rm -rf data/lang

echo "Removing data/lang_*"
rm -rf data/lang_*

echo "Removing data/test/*"
rm -rf data/test/*

echo "Removing data/local/tmp"
rm -rf data/local/tmp


if [ "$1" = cleandata ]; then
    echo "Wipe data folder ..."
    rm -rf data/*
fi


