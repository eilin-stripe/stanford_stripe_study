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

replace DateSent = DateSent2 if missing(DateSent)
drop DateSent2




