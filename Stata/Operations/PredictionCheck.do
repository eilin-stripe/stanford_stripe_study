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
qui include `base'/Code/Stata/file_header.do

** Load in the Stripe Panel data
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local prediction_check_sim = "`sim_data'/PredictionCheck.dta"

local outdir = "`output'/Predictions"
local PredictionList = "`outdir'/PredictionResults.dta"
local logbase = 1.4

*******************************************************************************
** Set up Measures of How close they were
*******************************************************************************
* use "`prediction_check'"
use "`prediction_check'"

gen Actual3MonthsHigh = (Actual3Months * 1.1)
gen Actual3MonthsLow = (Actual3Months / 1.1)

gen Actual3MonthsHighRound = round(Actual3MonthsHigh, 1000)
gen Actual3MonthsLowRound = round(Actual3MonthsLow, 1000)
gen Within10_1 = (Predict3Months >= Actual3MonthsLow & Predict3Months <= Actual3MonthsHigh) if Finished == 1
gen Within10_round = (Predict3Months >= Actual3MonthsLowRound & Predict3Months <= Actual3MonthsHighRound) if Finished == 1
gen Within10_2 = Within10_1 | Within10_round if Finished == 1
gen Within10_1000 = (Actual3Months <= 1000) & (Predict3Months == 1000 | Predict3Months == 0) if Finished == 1
gen Within10_3 = Within10_1 | Within10_round | Within10_1000 if Finished == 1

gen Winner = 0
replace Winner = 1 if Within10_2 == 1

order SurveyFirstName SurveyLastName Email Winner

gen PullDate = date("5/9/2019", "MDY")
gen DateDif = PullDate - ActivationDate
gen Denom = .
replace Denom = 365 if DateDif > 365
replace Denom = DateDif if DateDif <= 365


gen PrevMonthlyRev = (LastYearRevenue / Denom) * (30/100)
replace Finished = 0 if Finished == .
save "`PredictionList'", replace

save "`clean_sampling'/GiftCardsRound2.dta", replace
export delimited using "`clean_sampling'/GiftCardsRound2.csv", replace

keep if Finished == 1
keep *Name Email Winner PrevMonthlyRev ExternalReference

save "`clean_sampling'/ResurveyList.dta", replace
export delimited using "`clean_sampling'/ResurveyList.csv", replace

import excel "`raw_operations'/Round 2 GC Assignment.xlsx", sheet("MQT7") cellrange(A3:J53) firstrow clear
tempfile MQT7
save "`MQT7'", replace

import excel "`raw_operations'/Round 2 GC Assignment.xlsx", sheet("OM64") cellrange(A3:K203) firstrow clear
keep if Status == "Assigned"
append using "`MQT7'"

keep Name Email CLAIMCODE AccountID
rename CLAIMCODE ClaimCode
sort AccountID
bys AccountID : gen GiftCardNum = _n
reshape wide ClaimCode, i(Name Email AccountID) j(GiftCardNum)
rename ClaimCode1 ThankYouCode
rename ClaimCode2 RewardCode
rename AccountID ExternalReference

tempfile giftcards
save "`giftcards'" , replace

use "`clean_sampling'/ResurveyList.dta"
merge 1:1 ExternalReference using "`giftcards'"
drop _merge

export delimited using "`clean_sampling'/ResurveyList.csv", replace

use "`clean_sampling'/GiftCardsRound2.dta", replace

keep if Finished == 0
drop if OptedOut == 1
keep FirstName LastName Email ExternalReference

export delimited using "`clean_sampling'/ResurveyListNoAnswer.csv", replace



/*
gen Dif = abs(Predict3Months - Actual3Months)
gen WithinError = (Dif < 1000)
replace Within10 = 1 if Dif < 1000
*/

/*
// Calculate ratios of Predict To Actual
gen PredictOverActual3Months = Predict3Months/Actual3Months
replace PredictOverActual3Months = 1 if Predict3Months == 0 & Actual3Months == 0
gen ActualOverPredict3Months = Actual3Month/Predict3Months
replace ActualOverPredict3Months = 1 if Predict3Months == 0 & Actual3Months == 0

// Calculate adjusted measure by giving them the benefit of the doubt if they
// Are within 1000 of the actual, and also round to the nearest 1000
gen Actual3MonthsAdj = Actual3Months
replace Actual3MonthsAdj = Predict3Months if abs(Actual3MonthsAdj - Predict3Months) < 1000
replace Actual3MonthsAdj = round(Actual3MonthsAdj, 1000)

// Recalculate ratios with adjusted numbers
gen PredictOverActual3MonthsAdj = Predict3Months/Actual3MonthsAdj
replace PredictOverActual3MonthsAdj = 1 if Predict3Months == 0 & Actual3MonthsAdj == 0
gen ActualOverPredict3MonthsAdj = Actual3MonthsAdj/Predict3Months
replace ActualOverPredict3MonthsAdj = 1 if Predict3Months == 0 & Actual3MonthsAdj == 0

*******************************************************************************
**
*******************************************************************************
gen Actual3MonthsHigh = ceil((Actual3Months * 1.1)/1000)*1000
gen Actual3MonthsLow = floor((Actual3Months / 1.1)/1000)*1000
gen Within10 = (Predict3Months >= Actual3MonthsLow & Predict3Months <= Actual3MonthsHigh)

gen Within10_2 = 0
replace Within10_2 = 1 if (PredictOverActual3Months) < 1.1 ///
    & (ActualOverPredict3Months) < 1.1

gen Dif = abs(Predict3Months - Actual3Months)
gen WithinError = (Dif < 1000)
replace Within10 = 1 if Dif < 1000


order Within10 Within10_2 Actual3Months Predict3Months
br if Within10 != Within10_2
/*

*******************************************************************************
** Graphing
*******************************************************************************
pretty (scatter Actual3Months Predict3Months if Within10 == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3Months Predict3Months if Within10 == 0, xlogbase(`logbase') ylogbase(`logbase')) , ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Actual 3 Month Revenue") ///
    legend(label(1 "Within 10%") label(2 "Not Within 10%")) ///
    name("ActualVsPred3Month_1")

pretty (scatter Actual3Months Predict3Months if Within10_2 == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3Months Predict3Months if Within10_2 == 0, xlogbase(`logbase') ylogbase(`logbase')) , ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Actual 3 Month Revenue") ///
    legend(label(1 "Within 10%") label(2 "Not Within 10%")) ///
    name("ActualVsPred3Month_2")

*/
