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

save "`clean_dir'/round1_dp.dta", replace
