*******************************************************************************
** OVERVIEW
** Clean the GDP data from the (Need to look up where I got this again)
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear


** Setup Paths
findbase "Stripe"
local base = r(base)
include `base'/Code/Stata/file_header.do

import delimited "`raw_economy'/qgsp_all/qgsp_all.csv", varnames(1) ///
	encoding(ISO-8859-1) clear

*******************************************************************************
** This data came from an excel file so parse out all the non-data
*******************************************************************************
drop if regexm(geofips, "For Levels: *")
drop if regexm(geofips, "GeoFIPS")
drop if regexm(geofips, "Note: *")
drop if regexm(geofips, "Source: *")

foreach var of varlist q* v* {
	replace `var' = "" if `var' == "(D)"
	replace `var' = "" if `var' == "(L)"
	destring `var', replace
	local lab: variable label `var'
	local lab = subinstr("`lab'", "Q", "", .)
	rename `var' gdp`lab'
}


destring industryid, replace
drop if industryid  == .

drop componentid
replace componentname = "GDP" ///
	if componentname == "Gross domestic product (GDP) by state"
replace componentname = "IndexRealGDP" ///
	if componentname == "Quantity indexes for real GDP by state"
replace componentname = "RealGDP" ///
	if componentname == "Real GDP by state"

replace geofips = substr(geofips, 1, 2)
destring geofips, replace
labmask geofips, val(geoname)
drop geoname
rename geofips stateFP

reshape long "gdp", i(stateFP region componentname ///
	industryid industryclassification description) j(period)

tostring period, replace

gen year = substr(period, 1, 4)
gen quarter = substr(period, 5, .)
gen quarter_str = year + "Q" + quarter
drop year quarter period
gen quarter = quarterly(quarter_str, "YQ")
format quarter %tq
drop quarter_str

reshape wide gdp, i(stateFP region industryid ///
	industryclassification description quarter) j(componentname) string

compress

rename gdpGDP GDP
rename gdpIndexRealGDP IndexRealGDP
rename gdpRealGDP RealGDP


save "`clean_economy'/state_gdp_industry.dta", replace

keep if description == "All industry total"
drop industry* description

save "`clean_economy'/state_gdp.dta", replace
