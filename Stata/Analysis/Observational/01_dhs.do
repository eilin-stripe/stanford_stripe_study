*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data and generates dhs growth rates for q1 
** and mean mom growth in 2018
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
/*rf

*/

*ef
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

bysort merchant (timestamp_m): egen dhs_18_mean = mean(dhs_18)
bysort merchant (timestamp_m): replace dhs_18_mean = . if _n != 1
label variable dhs_18_mean "Mean growth 2018"


** merge survey data
merge m:1 merchant_id using "`clean_dir'/round1.dta"
keep if _merge == 3
drop _merge


/// keep surveys completed by March 31
keep if EndDateTemp <= "2019-03-31"

** for january 2019 survey completion
local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
loca j3 = date("2019-03-01", "YMD")

bysort merchant_id (year month): gen actual3months = sum(npv_monthly) if EndDateTemp <= "2019-01-31" & (ndate == `j1' | ndate == `j2' | ndate == `j3')

bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >="2019-01-01" & EndDateTemp <= "2019-01-31")
drop actual3m_temp


** february 2019 completion
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-02-28" & (ndate == `f1' | ndate == `f2' | ndate == `f3')

bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-02-01" & EndDateTemp <= "2019-02-28")
drop actual3m_temp


** march 2019 completion
local m1 = date("2019-03-01", "YMD")
local m2 = date("2019-04-01", "YMD")
local m3 = date("2019-05-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-03-31" & (ndate == `m1' | ndate == `m2' | ndate == `m3')

bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-03-01" & EndDateTemp <= "2019-03-31")
drop actual3m_temp






** rouding correction
gen Actual3MonthsHigh = (npv_19q1 * 1.1)
gen Actual3MonthsLow = (npv_19q1 / 1.1)
gen Actual3MonthsHighRound = round(npv_19q1, 1000)
gen Actual3MonthsLowRound = round(npv_19q1, 1000)


** multiplying qualtrics entry by 1000
foreach var of varlist Bad3Months Predict3Months Good3Months{
	replace `var' = `var' * 1000
}


