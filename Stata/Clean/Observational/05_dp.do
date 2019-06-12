*******************************************************************************
** OVERVIEW
**
** this dofile pulls in dnapanel data on monthly npv from jan 2018 
** generates year, month and date variables
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
import delimited "`raw_dir'/r1_npv.csv", varnames(1) encoding(ISO-8859-1) clear

// change npv from cents to dollars
rename npv__total npv_monthly
replace npv_monthly = npv_monthly/100
label variable npv_monthly "Monthly NPV ($)"

// generate year month variable
gen year = regexs(0) if regexm(timestamp_m,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp_m, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp_m, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)

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


save "`clean_dir'/round1_dp.dta", replace


