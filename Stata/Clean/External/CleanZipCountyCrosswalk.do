*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/Stripe/Code/Stata/Clean/Survey/"
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
findbase "Stripe"
local base = r(base)
qui include `base'/Code/Stata/file_header.do

local in = "`raw_geo'/ZIP_COUNTY_032019.xlsx"
local out = "`clean_geo'/ZipToState.dta"

*******************************************************************************
**
*******************************************************************************
import excel "`in'", sheet("ZIP_COUNTY_032019") firstrow clear

rename zip Zipcode
rename county County
rename res_ratio ResRatio
rename bus_ratio BusRatio
rename oth_ratio OthRatio
rename tot_ratio TotRatio

destring Zipcode , replace
gen State = substr(County, 1, 2)
keep Zipcode State
duplicates drop
drop if Zipcode == 75501 & State == "05"

save "`out'", replace
