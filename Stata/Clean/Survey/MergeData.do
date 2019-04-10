*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/Stripe/Code/Stata/Clean/Survey/"
**
**
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
local survey = "`clean_survey'/Survey.dta"
local records = "`clean_survey'/Records.dta"
local sample = "`clean_survey'/Sample.dta"
local main = "`clean_survey'/Main.dta"

*******************************************************************************
**
*******************************************************************************

// Merge in the Internal records on sales volumes to the survey data
use "`survey'"
keep if SurveyRound == 0
merge 1:1 ExternalReference using "`records'"
keep if _merge == 3
drop _merge

// Also merge in the sampling data so we know what Strata they are from
merge 1:1 ExternalReference using "`sample'", keep(1 3)
drop _merge

compress

save "`main'", replace
