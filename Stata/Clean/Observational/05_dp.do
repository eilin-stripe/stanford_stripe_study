*******************************************************************************
** OVERVIEW
**
** this dofile pulls in dnapanel data on monthly npv from jan 2018 
** generates year, month and date variables
** generates quarterly growth rates for 2018
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
* drop 2016 dec values
drop if year == 2016

//// 2018q1 - 2019q1

local jan17 = date("2017-01-01", "YMD")
local feb17 = date("2017-02-01", "YMD")
local mar17 = date("2017-03-01", "YMD")
local apr17 = date("2017-04-01", "YMD")
local may17 = date("2017-05-01", "YMD")
local jun17 = date("2017-06-01", "YMD")
local jul17 = date("2017-07-01", "YMD")
local aug17 = date("2017-08-01", "YMD")
local sep17 = date("2017-09-01", "YMD")
local oct17 = date("2017-10-01", "YMD")
local nov17 = date("201711-01", "YMD")
local dec17 = date("2017-12-01", "YMD")

local jan18 = date("2018-01-01", "YMD")
local feb18 = date("2018-02-01", "YMD")
local mar18 = date("2018-03-01", "YMD")
local apr18 = date("2018-04-01", "YMD")
local may18 = date("2018-05-01", "YMD")
local jun18 = date("2018-06-01", "YMD")
local jul18 = date("2018-07-01", "YMD")
local aug18 = date("2018-08-01", "YMD")
local sep18 = date("2018-09-01", "YMD")
local oct18 = date("2018-10-01", "YMD")
local nov18 = date("201811-01", "YMD")
local dec18 = date("2018-12-01", "YMD")


local jan19 = date("2019-01-01", "YMD")
local feb19 = date("2019-02-01", "YMD")
local mar19 = date("2019-03-01", "YMD")
local apr19 = date("2019-04-01", "YMD")
local may19 = date("2019-05-01", "YMD")

* npv_17q*
bysort merchant (timestamp_m): gen npv_17q1 = sum(npv_monthly) if (ndate >= `jan17' & ndate <= `mar17')
bysort merchant (timestamp_m): gen npv_17q2 = sum(npv_monthly) if (ndate >= `apr17' & ndate <= `jun17')
bysort merchant (timestamp_m): gen npv_17q3 = sum(npv_monthly) if (ndate >= `jul17' & ndate <= `sep17')
bysort merchant (timestamp_m): gen npv_17q4 = sum(npv_monthly) if (ndate >= `oct17' & ndate <= `dec17')
foreach num of numlist 1/4{
bysort merchant (timestamp_m): replace npv_17q`num' = npv_17q`num'[_n - 1] if missing(npv_17q`num')
bysort merchant (timestamp_m): replace npv_17q`num' = npv_17q`num'[_N] if _n == 1
bysort merchant (timestamp_m): replace npv_17q`num' = . if _n != 1
}

* npv_18q*
bysort merchant (timestamp_m): gen npv_18q1 = sum(npv_monthly) if (ndate >= `jan18' & ndate <= `mar18')
bysort merchant (timestamp_m): gen npv_18q2 = sum(npv_monthly) if (ndate >= `apr18' & ndate <= `jun18')
bysort merchant (timestamp_m): gen npv_18q3 = sum(npv_monthly) if (ndate >= `jul18' & ndate <= `sep18')
bysort merchant (timestamp_m): gen npv_18q4 = sum(npv_monthly) if (ndate >= `oct18' & ndate <= `dec18')
foreach num of numlist 1/4{
bysort merchant (timestamp_m): replace npv_18q`num' = npv_18q`num'[_n - 1] if missing(npv_18q`num')
bysort merchant (timestamp_m): replace npv_18q`num' = npv_18q`num'[_N] if _n == 1
bysort merchant (timestamp_m): replace npv_18q`num' = . if _n != 1
}

* npv_19q1
bysort merchant (timestamp_m): gen npv_19q1 = sum(npv_monthly) if (ndate >= `jan19' & ndate <= `mar19')
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

gen dhs_q1_1718 = (npv_18q1 - npv_17q1)/(0.5*(npv_17q1 + npv_18q1))
label variable dhs_q1_1718 "Q1 growrth (17-18)"

save "`clean_dir'/round1_dp.dta", replace


