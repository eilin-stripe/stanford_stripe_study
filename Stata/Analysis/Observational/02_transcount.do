*******************************************************************************
** OVERVIEW
**
** this dofile looks at transaction count in 2018 for participants  
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
import delimited "`raw_dir'/05_trans_count.csv", varnames(1) encoding(ISO-8859-1) clear

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

bysort merchant_id year (month): gen trans_annual = sum(trans_count)
bysort merchant_id year (month): replace trans_annual = trans_annual[_N] if _n == 1
bysort merchant_id year (month): replace trans_annual = . if _n != 1
keep if year == 2018 & month == 1
save "`clean_dir'/trans_count.dta", replace
