*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data and generates prediction categories  
** 
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

** merge survey data
merge m:1 merchant_id using "`clean_dir'/round1.dta"
keep if _merge == 3			//_merge == 2 for non-completed surveys
drop _merge 

//// indicator for first obs
bysort merchant_id: gen n = 1 if _n == 1

** multiplying qualtrics entry by 1000
foreach var of varlist Predict3Months Bad3Months Good3Months{
	replace `var' = `var' * 1000
}


** for january 2019 survey completion
local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
local j3 = date("2019-03-01", "YMD")
local j4 = date("2018-01-01", "YMD")
local j5 = date("2018-02-01", "YMD")
local j6 = date("2018-03-01", "YMD")

bysort merchant_id (year month): gen actual3months = sum(npv_monthly) if EndDateTemp <= "2019-01-31" & (ndate == `j1' | ndate == `j2' | ndate == `j3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >="2019-01-01" & EndDateTemp <= "2019-01-31")
drop actual3m_temp

bysort merchant_id (year month): gen actual3months_18 = sum(npv_monthly) if EndDateTemp <= "2019-01-31" & (ndate == `j4' | ndate == `j5' | ndate == `j6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >="2019-01-01" & EndDateTemp <= "2019-01-31")
drop actual3m_18temp


** february 2019 completion
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")
local f4 = date("2018-02-01", "YMD")
local f5 = date("2018-03-01", "YMD")
loca f6 = date("2018-04-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-02-28" & (ndate == `f1' | ndate == `f2' | ndate == `f3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-02-01" & EndDateTemp <= "2019-02-28")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18 = sum(npv_monthly) if EndDateTemp <= "2019-02-28" & (ndate == `f4' | ndate == `f5' | ndate == `f6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-02-01" & EndDateTemp <= "2019-02-28")
drop actual3m_18temp


** march 2019 completion
local m1 = date("2019-03-01", "YMD")
local m2 = date("2019-04-01", "YMD")
local m3 = date("2019-05-01", "YMD")
local m4 = date("2018-03-01", "YMD")
local m5 = date("2018-04-01", "YMD")
local m6 = date("2018-05-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-03-31" & (ndate == `m1' | ndate == `m2' | ndate == `m3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-03-01" & EndDateTemp <= "2019-03-31")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18= sum(npv_monthly) if EndDateTemp <= "2019-03-31" & (ndate == `m4' | ndate == `m5' | ndate == `m6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-03-01" & EndDateTemp <= "2019-03-31")
drop actual3m_18temp

bysort merchant_id (year month): replace actual3months = . if _n != 1 

gen predict_cat = 1 if actual3months <= Bad3Months & actual3months != .
replace predict_cat = 2 if actual3months > Bad3Months & actual3months <= 0.9*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 3 if actual3months >= 0.9*Predict3Months & actual3months <= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 4 if actual3months >= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 5 if actual3months >= Good3Months & n == 1 & actual3months != .
// replace predict_cat to missing for those who did not make a prediction
replace predict_cat = . if Predict3Months == .
//replace predict_cat to 3 for those who had a revenue of 0 and predicted both expected and worst case to be 0
replace predict_cat = 3 if actual3months == 0 & Predict3Months == 0 & Good3Months == 0
