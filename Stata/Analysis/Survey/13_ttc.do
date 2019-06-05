*******************************************************************************
** OVERVIEW
**
** this dofile pulls in sampling 1 data, merges with round 1 qualtrics +
** dna panel data to look at growth
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
/*rf
findbase "Stripe"
local base = r(base)
qui include `base'/Code/Stata/file_header.do

** Load in the Stripe Panel data
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local prediction_check_sim = "`sim_data'/PredictionCheck.dta"
local demographics = "`clean_internal'/Demographics.dta"

local outdir = "`output'/NickLunch"
local PredictionList = "`outdir'/PredictionResults.dta"
local logbase = 1.4
*/

*ef
cd "/Users/eilin/Documents/SIE"
local clean_sampling "02_clean_sample"
*/
*******************************************************************************
** Set up Measures of How close they were
*******************************************************************************

* read in npv data
use "sta_files/round1_dp.dta", clear

* growth rate from 2018q1 to 2019 q1

////	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)
** first observation of user
bysort merchant (year month): gen n = _n

// changing negative npv; first pass
replace npv__monthly = 0 if npv__monthly < 0 


local j18 = date("01-01-2018", "MDY")
local f18 = date("02-01-2018", "MDY")
local m18 = date("03-01-2018", "MDY")

local j19 = date("01-01-2019", "MDY")
local f19 = date("02-01-2019", "MDY")
local m19 = date("03-01-2019", "MDY")

bysort merchant (ndate): gen npv_18_q1 = sum(npv__monthly) if ndate >= `j18' & ndate <= `m18'
gen npv_18_temp = npv_18_q1 if !missing(npv_18_q1)
bysort merchant (ndate): replace npv_18_temp = npv_18_temp[_n-1] if missing(npv_18_temp)
bysort merchant (ndate): replace npv_18_q1 = npv_18_temp[_N] if _n == 1
drop npv_18_temp

bysort merchant (ndate): gen npv_19_q1 = sum(npv__monthly) if ndate >= `j19' & ndate <= `m19'
gen npv_19_temp = npv_19_q1 if !missing(npv_19_q1)
bysort merchant (ndate): replace npv_19_temp = npv_19_temp[_n-1] if missing(npv_19_temp)
bysort merchant (ndate): replace npv_19_q1 = npv_19_temp[_N] if _n == 1
drop npv_19_temp

* keep one obs per user to merge
bysort merchant (ndate): keep if _n == 1


// merge with sampling data
merge 1:1 merchant_id using "`clean_sampling'/Sample.dta"
keep if _merge == 3
drop _merge

merge 1:1 merchant_id using "`clean_sampling'/Sample2.dta"
* keep completed surveys
drop if missing(EndDate)
drop _merge

// growth rates
gen num = npv_19_q1 - npv_18_q1
gen den = 0.5*(npv_19_q1 + npv_18_q1)
gen dhs_q = num/den
label variable dhs_q "DHS growth rate 18q1 to 19q1"

gen dhs_q_cat = 1 if dhs_q <= -0.30
replace dhs_q_cat = 2 if dhs_q > -0.30 & dhs_q < 0.30
replace dhs_q_cat = 3 if dhs_q >= 0.3 & dhs_q != .


// days to complete
gen DaysToComplete = EndDate - DateSent
gen DaysToComplete2 = .
replace DaysToComplete2 = 0 if DaysToComplete == 0
replace DaysToComplete2 = 1 if inlist(DaysToComplete, 1, 2)
replace DaysToComplete2 = 2 if inlist(DaysToComplete, 3, 4)
replace DaysToComplete2 = 3 if inlist(DaysToComplete, 5, 6)
replace DaysToComplete2 = 4 if DaysToComplete >= 7
label define DaysToComplete 0 "0 Days" 1 "1 to 2 Days" 2 "3 to 4 Days" ///
    3 "5 to 6 Days" 4 "7+ Days"
label values DaysToComplete2 DaysToComplete


// plot
** small, 13_ttc_f1
catplot dhs_q_cat DaysToComplete2 if strata =="small", percent(DaysToComplete2)stack asyvars bar(1, bcolor("176 196 222")) bar(2, bcolor("32 178 170")) bar(3, bcolor("125 176 221")) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

** big, 13_ttc_f2
catplot dhs_q_cat DaysToComplete2 if strata =="big", percent(DaysToComplete2)stack asyvars bar(1, bcolor("176 196 222")) bar(2, bcolor("32 178 170")) bar(3, bcolor("125 176 221")) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

** funded, 13_ttc_f2
catplot dhs_q_cat DaysToComplete2 if strata =="funded", percent(DaysToComplete2)stack asyvars bar(1, bcolor("176 196 222")) bar(2, bcolor("32 178 170")) bar(3, bcolor("125 176 221")) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 



// prediction categories
foreach var of varlist Predict3Months Bad3Months Good3Months{
	replace `var' = `var' * 1000
}

gen predict_cat = 1 if actual3months <= Bad3Months & actual3months != .
replace predict_cat = 2 if actual3months > Bad3Months & actual3months <= 0.9*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 3 if actual3months >= 0.9*Predict3Months & actual3months <= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 4 if actual3months >= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 5 if actual3months >= Good3Months & n == 1 & actual3months != .
