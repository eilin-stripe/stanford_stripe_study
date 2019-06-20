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

// read data

cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
*/


// read data

use "`clean_dir'/round1_dp.dta", clear

*******************************************************************************
** DHS GROWTH RATES
*******************************************************************************

* replace refunds to npv = 0
replace npv_monthly = 0 if npv_monthly < 0


//// 2018q1 - 2019q1

local j18 = date("2018-01-01", "YMD")
local f18 = date("2018-02-01", "YMD")
local m18 = date("2018-03-01", "YMD")

local j19 = date("2019-01-01", "YMD")
local f19 = date("2019-02-01", "YMD")
local m19 = date("2019-03-01", "YMD")

* npv_18q1
bysort merchant (timestamp_m): gen npv_18q1 = sum(npv_monthly) if (ndate >= `j18' & ndate <= `m18')
bysort merchant (timestamp_m): replace npv_18q1 = npv_18q1[_n - 1] if missing(npv_18q1)
bysort merchant (timestamp_m): replace npv_18q1 = npv_18q1[_N] if _n == 1
bysort merchant (timestamp_m): replace npv_18q1 = . if _n != 1

* npv_19q1
bysort merchant (timestamp_m): gen npv_19q1 = sum(npv_monthly) if (ndate >= `j19' & ndate <= `m19')
bysort merchant (timestamp_m): replace npv_19q1 = npv_19q1[_n - 1] if missing(npv_19q1)
bysort merchant (timestamp_m): replace npv_19q1 = npv_19q1[_N] if _n == 1
bysort merchant (timestamp_m): replace npv_19q1 = . if _n != 1


//// quarterly growth rate
gen num = npv_19q1 - npv_18q1
gen den = 0.5 * (npv_19q1 + npv_18q1)
gen dhs_q = num/den
label variable dhs_q "First quarter growth rate"

replace dhs_q = 0 if npv_18q1 == 0 & npv_19q1 == 0	//replace dhs_q = 0 for firms that had 0 npv in q1 of both years
drop num den

//// average mom 2018
bysort merchant (timestamp_m): gen  num = npv_monthly - npv_monthly[_n - 1] if year == 2018
bysort merchant (timestamp_m): gen  den = 0.5 * (npv_monthly + npv_monthly[_n - 1]) if year == 2018
gen dhs_18 = num/den
label variable dhs_18 "MoM growth rate (2018)"
drop num den

bysort merchant (timestamp_m): egen dhs_18_mean = mean(dhs_18)
bysort merchant (timestamp_m): replace dhs_18_mean = . if _n != 1
label variable dhs_18_mean "Mean growth 2018"


** merge survey data
merge m:1 merchant_id using "`clean_dir'/round1.dta"
keep if _merge == 3
drop _merge

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

// quarterly growth rates categories
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
catplot dhs_q_cat DaysToComplete2 if strata =="small", percent(DaysToComplete2)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(99 3 6)) bar(3, bcolor(33 66 0)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

** big, 13_ttc_f2
catplot dhs_q_cat DaysToComplete2 if strata =="big", percent(DaysToComplete2)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(99 3 6)) bar(3, bcolor(33 66 0))  graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

** funded, 13_ttc_f2
catplot dhs_q_cat DaysToComplete2 if strata =="funded", percent(DaysToComplete2)stack asyvars bar(1, bcolor("176 196 222")) bar(2, bcolor("32 178 170")) bar(3, bcolor("125 176 221")) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

// annual grwoth categories
gen dhs_m_cat = 1 if dhs_18_mean <= -0.05
replace dhs_m_cat = 2 if dhs_18_mean > -0.05 & dhs_18_mean < 0.05
replace dhs_m_cat = 3 if dhs_18_mean >= 0.05

catplot dhs_m_cat DaysToComplete2 if strata =="funded", percent(DaysToComplete2)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(99 3 6)) bar(3, bcolor(33 66 0)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 
catplot dhs_m_cat DaysToComplete2 if strata =="big", percent(DaysToComplete2)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(99 3 6)) bar(3, bcolor(33 66 0)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 
catplot dhs_m_cat DaysToComplete2 if strata =="small", percent(DaysToComplete2)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(99 3 6)) bar(3, bcolor(33 66 0)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


