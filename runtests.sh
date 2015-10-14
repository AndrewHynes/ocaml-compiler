#!/bin/sh

for file in "testCases"/*
do
    echo "----- TEST STARTING -----"
    printf "Running: $file\n"
    ./mainParser.native $file
    echo "----- TEST FINISHED -----"
    printf "\n"
done

