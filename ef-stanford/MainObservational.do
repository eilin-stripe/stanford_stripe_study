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
/*
capture erasedir "`clean_stripe'"
capture erasedir "`clean_industry'"
capture erasedir "`clean_economy'"
capture erasedir "`clean_data'"
mkdir "`clean_data'"
mkdir "`clean_stripe'"
mkdir "`clean_industry'"
mkdir "`clean_economy'"
*/

** Run Cleaning first
cd "Clean/External"
run CleanMCC
run CleanGDP
cd ../..

cd "Clean/Observational"
run CleanEmployeePanel
run CleanCharacteristics
run CleanPanel
cd ../..

/*
** Run Analysis
cd "../Analysis"

cd ".."
*/
