*******************************************************************************
** OVERVIEW
**
** analysis on predictions
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

/* re

*/

*ef
cd "/Users/eilin/Documents/SIE"
local clean_dir "sta_files"



// read dna panel data
use "`clean_dir'/round1_dp.dta", clear

* merge with survey data
merge m:1 merchant_id using "`clean_dir'/round1.dta"
keep if _merge == 3
drop _merge
