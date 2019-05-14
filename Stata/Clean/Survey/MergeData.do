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
local survey = "`clean_main_survey'/Survey.dta"
local records = "`clean_internal'/Records.dta"
local sample = "`clean_sampling'/Sample.dta"
local main = "`clean_main_survey'/Main.dta"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local history = "`clean_survey'/History/HistoryWave1.dta"
*******************************************************************************
**
*******************************************************************************

// Merge in the Internal records on sales volumes to the survey data
use "`survey'"
keep if SurveyRound == 1
merge 1:1 ExternalReference using "`records'"
keep if _merge == 3
drop _merge

// Also merge in the sampling data so we know what Strata they are from
merge 1:1 ExternalReference using "`sample'"
keep if Wave == 1
drop _merge

compress

merge 1:1 ExternalReference using "`history'"
drop _merge

save "`main'", replace

*******************************************************************************
** Clean up vars For Prediction Check
*******************************************************************************
keep ExternalReference SurveyFirstName SurveyLastName Email FirstName ///
    LastName EndDate StartDate *Rev *3Months Finished ActivationDate ///
    LastYearRev OptedOut
rename LastYearRev LastYearRevenue
* keep if Finished == 1
* drop Finished

// set the last month revenue based on what month they completed the survey
gen EndMonth = month(EndDate)
gen StartMonth = month(StartDate)
gen Month = EndMonth
drop StartMonth EndMonth StartDate EndDate

foreach revvar of varlist *Rev {
    replace `revvar' = `revvar' / 100
}

gen Actual3Months = (JanRev + FebRev + MarRev) if Month == 1
replace Actual3Months = (FebRev + MarRev + AprRev) if Month == 2
drop *Rev Month

replace Predict3Months = Predict3Months * 1000
replace Bad3Months = Bad3Months * 1000
replace Good3Months = Good3Months * 1000

order Actual3Months Predict3Months Bad3Months Good3Months
save "`prediction_check'", replace



*******************************************************************************
