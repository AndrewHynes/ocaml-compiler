#!/bin/sh

echo "-----------"
echo "Running tests that should properly compile..."
echo "-----------"
echo ""
for file in "testCases/shouldSucceed"/*
do
    echo "----- TEST STARTING -----"
    printf "Running: $file\n"
    ./mainParser.native $file
    echo "----- TEST FINISHED -----"
    printf "\n"
done

echo "-----------"
echo "Running tests that should not properly compile..."
echo "-----------"
echo ""
for file in "testCases/shouldFail"/*
do
    echo "----- TEST STARTING -----"
    printf "Running: $file\n"
    ./mainParser.native $file
    echo "----- TEST FINISHED -----"
    printf "\n"
done

