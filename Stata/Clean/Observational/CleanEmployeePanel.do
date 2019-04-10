*******************************************************************************
** OVERVIEW
** Takes the raw employee count data from Stripe and cleans it
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

** Load in the Stripe Panel data
use "`raw_stripe'/employee_panel_may19.dta"

*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************
** Clean up the date variable to create month variables as a time index
replace month = subinstr(month, "T00:00:00Z","", .)
replace month = subinstr(month, "-","", .)
gen day = date(month, "YMD")
drop month
gen int month = mofd(day)
drop day
format month %tm

save "`clean_stripe'/employee_panel.dta", replace
