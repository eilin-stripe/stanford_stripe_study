*******************************************************************************
** 
** Summary Statistics for Gender blog
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

cd "~/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local tables "07_Output"

use "`raw_dir'/Combined.dta", clear


gen female=1 if Female==1
replace female=0 if Female==0

// using weights to pool across groups
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.133 if strata_int==0
replace strata_wt=1.447 if strata_int==1
replace strata_wt=1.160 if strata_int==2


mean Age [pw=strata_wt]

////	max hours per week is set to 16*7
replace HoursPerWeek = 112 if HoursPerWeek > 112 & HoursPerWeek != .
mean HoursPerWeek [pw=strata_wt]

// previous business
replace NumBusOwned =. if NumBusOwned < 0		//replace num bus=. for non-owner respondents
mean NumBusOwned [pw=strata_wt]

// co-founders
gen cofounder=1 if NumFounders > 1 & !missing(NumFounders)
replace cofounder=0 if NumFounders==1
mean cofounder [pw=strata_wt]

