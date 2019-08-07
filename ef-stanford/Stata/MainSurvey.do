*******************************************************************************
** OVERVIEW
** Takes the raw firm panel data from Stripe and cleans it
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
findbase "Stripe"
local base = r(base)
include `base'/Code/Stata/file_header.do

cd "`stata'"
clear
findbase "Stripe"
local base = r(base)
include `base'/Code/Stata/file_header.do


*******************************************************************************
** RUN PROJECT FROM START TO FINISH
*******************************************************************************
** Cleanout clean data folder for fresh start.

** Run Cleaning first
cd "Clean/Survey"
run CleanDemographicData
run CleanRecords
run CleanSampling
run CleanSampling2
run CleanSurveyData
run MergeData
cd ../..
