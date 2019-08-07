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
local sample2 = "`clean_sampling'/Sample2.dta"
local main = "`clean_main_survey'/Main.dta"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local history = "`clean_survey'/History/HistoryWave1.dta"
local history2 = "`clean_survey'/History/HistoryWave2.dta"
*******************************************************************************
**
*******************************************************************************
use "`history'"
append using "`history2'"
tempfile histcombined
save "`histcombined'"

// Merge in the Internal records on sales volumes to the survey data
use "`survey'"
keep if Finished == 1
drop if ExternalReference == ""
keep if inlist(SurveyRound, 1, 2)
merge 1:1 ExternalReference using "`records'"
keep if _merge == 3
drop _merge

tempfile WithRecords
save "`WithRecords'"

// Also merge in the sampling data so we know what Strata they are from
merge 1:1 ExternalReference using "`sample'"
keep if inlist(Wave, 1, 2)
drop _merge

compress

merge 1:1 ExternalReference using "`histcombined'"
drop _merge

save "`main'", replace

*******************************************************************************
** Clean up vars For Prediction Check
*******************************************************************************
keep ExternalReference SurveyFirstName SurveyLastName Email FirstName ///
    LastName EndDate StartDate *Rev *3Months Finished LastYearRev ///
    OptedOut FirstSaleYear ActivationDate ApplicationDate LastYearTrans ///
    PreviousBusinesses AllTrans Age NumBusOwned Female Education FounderFlag ///
    HoursPerWeek OtherJobFlag Degree* Strata Founder DateSent
rename LastYearRev LastYearRevenue
* keep if Finished == 1
* drop Finished

// set the last month revenue based on what month they completed the survey
gen EndMonth = month(EndDate)
gen StartMonth = month(StartDate)
gen Month = EndMonth
drop StartMonth EndMonth

foreach revvar of varlist *Rev {
    replace `revvar' = `revvar' / 100
}

gen Actual3Months = (JanRev + FebRev + MarRev) if Month == 1
replace Actual3Months = (FebRev + MarRev + AprRev) if Month == 2
replace Actual3Months = (MarRev + AprRev + MayRev) if Month == 3
drop *Rev Month

replace Predict3Months = Predict3Months * 1000
replace Bad3Months = Bad3Months * 1000
replace Good3Months = Good3Months * 1000

order Actual3Months Predict3Months Bad3Months Good3Months
save "`prediction_check'", replace



*******************************************************************************
