*******************************************************************************
** OVERVIEW
** Look at the relationship between GDP and the number of businesses
** established. There are three methods that I try out here
** 1) Simply regress them on each other, but this is a not at all robust
** 	  strategy
** 2)
** 3)
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do

** Setup Output folder for results
local economic_output = "`output'/EconomicEnvironment"
capture erasedir "`economic_output'"
mkdir "`economic_output'"


** Load in the Stripe Panel data
local data_vars = "state stateFP state_ID  month firm_id gpv customers mcc"
use `data_vars' using "`main_panel'", clear

keep if mcc == 5734

****************************
** TIME VARIABLE: QUARTER **
****************************
** Set up the Date Variables and indentify the most recent observations
gen quarter = qofd(dofm(month))
format quarter %tq
sort state quarter

sum quarter
local max_quarter = `r(max)' - 1

************************************
** CONVERT TO QUARTER-BASED PANEL **
************************************
sort firm_id quarter
by firm_id quarter : egen quarter_gpv = sum(gpv)
by firm_id quarter : gen num_obs = _N
keep if num_obs == 3
keep state stateFP state_ID quarter firm_id quarter_gpv
duplicates drop

sort firm_id quarter
xtset firm_id quarter
gen first = 0
by firm_id : replace first = 1 if _n == 1

** Calculate quartelry firm growth rates to use instead of the monthly growth
** rates
gen quarter_gpv_growth = (D.quarter_gpv / (0.5 * (L.quarter_gpv + quarter_gpv)))


*****************************************************
** CALCULATE BUSINESS METRICS BY STATE AND QUARTER **
*****************************************************

gen freq = 1
sort state quarter
egen state_quarter_tag = tag(state quarter)
by state quarter : egen num_business = total(freq)
by state quarter : egen num_new_business = total(first)
by state quarter : egen tot_gpv = sum(quarter_gpv)
by state quarter : egen avg_gpv = mean(quarter_gpv)
by state quarter : egen avg_gpv_growth = mean(quarter_gpv_growth)
keep if state_quarter_tag == 1
keep state stateFP state_ID quarter num_business num_new_business avg_gpv ///
	avg_gpv_growth tot_gpv


****************************************************
** MAP MOST RECENT STATE BUSINESS CHARACTERISTICS **
****************************************************
local bus_char = 0
if `bus_char' == 1 {
	spmap num_business using "`tiger'/state_coor.dta"  ///
		if !inlist(state_ID, 41, 32, 50, 35, 37) & quarter == `max_quarter',  ///
		id(state_ID) fcolor(Blues2) ocolor(gs15 gs15 gs15 gs15) ///
		title("Number of Businesses Per State") ///
		name("BusPerState", replace)


	spmap num_new_business using "`tiger'/state_coor.dta"  ///
		if !inlist(state_ID, 41, 32, 50, 35, 37) & quarter == `max_quarter',  ///
		id(state_ID) fcolor(Blues2) ocolor(gs15 gs15 gs15 gs15) ///
		title("Number of New Businesses Per State") ///
		name("NewBusPerState", replace)
}


*************************************
** GDP VS BUSINESS GROWTH ANALYSIS **
*************************************
** Destring the state fips ID for merging
destring stateFP, replace

** Merge in Business Environment measurements
mmerge stateFP quarter using "`clean_economy'/state_gdp.dta", ///
	type(n:1) unmatched(master)
** drop the unnecessary merging indicator
drop _merge

** Create log versions of the GDP variables
gen log_RealGDP = log(RealGDP + 1)
gen log_num_new_business = log(num_new_business + 1)

** Create a panel to analyze so we can calculate growth statistics
xtset stateFP quarter

** Create growth variables
gen RealGDP_growth = (D.RealGDP / (0.5 * (L.RealGDP + RealGDP)))
gen num_new_business_growth = (D.num_new_business / (0.5 * (L.num_new_business + num_new_business)))


********************
** NAIVE METHOD 1 **
********************
** Simple look at relationship between GDP and New Business.
** Bad though if number of Stripe customers was growing and economy was also growing
** Which is definitely true.

local method1 = 0
if `method1'  == 1 {
	reg log_num_new_business log_RealGDP
	areg log_num_new_business log_RealGDP, absorb(stateFP)

	reg log_num_new_business i.stateFP
	predict log_new_bus_resid, residuals
	reg log_RealGDP i.stateFP
	predict log_RealGDP_resid, residuals

	twoway (scatter log_new_bus_resid log_RealGDP_resid, msize(vtiny)) ///
		(lfit log_new_bus_resid log_RealGDP_resid ) ,  ///
		scheme(s2personal) title("New Business Vs. Real GDP") ///
		xtitle("Log Real GDP") ytitle("Log Number of New Businesses") ///
		name("NewBusRealGDP", replace) ///
		legend(off)
	local save_file = "`economic_output'/NewBusRealGDPMethod1.eps"
	graph export "`save_file'", replace

	/*
	qui levelsof stateFP
	local states = "`r(levels)'"

	foreach state of numlist `states' {
		twoway (scatter log_RealGDP quarter if stateFP == `state' & state_quarter_tag == 1, yaxis(1)) ///
			(scatter log_num_new_business quarter if stateFP == `state' & state_quarter_tag == 1, yaxis(2)) ///
			(lpoly log_RealGDP quarter if stateFP == `state' & state_quarter_tag == 1, yaxis(1)) ///
			(lpoly log_num_new_business quarter if stateFP == `state' & state_quarter_tag == 1, yaxis(2)), ///
			scheme(s2personal) name("NewBusVsGDP_State`state'", replace)
	}
	*/

}

********************
** NAIVE METHOD 2 **
********************

local method2 = 1
if `method2' == 1 {
	* Sort by quarter to generate differences from average
	sort quarter
	* Generate
	by quarter: egen total_RealGDP = total(RealGDP), missing
	by quarter: egen avg_RealGDP_growth = mean(RealGDP_growth * RealGDP_growth)
	replace avg_RealGDP_growth = avg_RealGDP_growth / total_RealGDP
	gen RealGDP_growth_dif = RealGDP_growth - avg_RealGDP_growth

	by quarter: egen total_new_business = total(num_new_business), missing
	by quarter: egen avg_new_business_growth = mean(num_new_business_growth * num_new_business)
	replace avg_new_business_growth = avg_new_business_growth / total_RealGDP
	gen num_new_business_growth_dif = num_new_business_growth - avg_new_business_growth

	eststo method2: areg RealGDP_growth_dif num_new_business_growth_dif, absorb(stateFP)

	reg RealGDP_growth_dif i.stateFP
	predict RealGDP_growth_dif_resid, residuals
	reg num_new_business_growth i.stateFP
	predict num_new_business_growth_resid, residuals

	twoway (scatter num_new_business_growth_resid RealGDP_growth_dif_resid, msize(vtiny)) ///
		(lfit num_new_business_growth_resid RealGDP_growth_dif_resid ) ,  ///
		scheme(s2personal) title("New Business Vs. Real GDP") ///
		xtitle("Dif from average Real GDP Growth") ytitle("Dif from average New Business Growth") ///
		name("Method2", replace) ///
		legend(off)
	local save_file = "`economic_output'/NewBusRealGDPMethod2.eps"
	graph export "`save_file'", replace

	qui levelsof stateFP
	local states = "`r(levels)'"


	foreach state of numlist `states' {
		twoway (scatter RealGDP_growth_dif quarter if stateFP == `state', yaxis(1)) ///
			(scatter num_new_business_growth_dif quarter if stateFP == `state', yaxis(2)) ///
			(lpoly RealGDP_growth_dif quarter if stateFP == `state', yaxis(1)) ///
			(lpoly num_new_business_growth_dif quarter if stateFP == `state', yaxis(2)), ///
			scheme(s2personal) name("Method2_State`state'", replace)
	}

}

**************
** METHOD 3 **
**************
** This method suffers the flaw that it can't handle new states enterring
** in a very elegant way. If a new state enters, then the percentages will
** drop mechanically for other states, even though they didn't get less
** important.
local method3 = 1
if `method3' == 1 {
	sort quarter
	by quarter: egen tot_RealGDP = sum(RealGDP)
	gen RealGDP_perc = RealGDP/tot_RealGDP
	gen log_RealGDP_perc = log(RealGDP_perc + 1)

	by quarter: egen national_tot_gpv= sum(tot_gpv)
	gen gpv_perc = avg_gpv/national_tot_gpv
	gen log_gpv_perc = log(gpv_perc + 1)

	by quarter: egen tot_num_new_business = sum(num_new_business)
	gen num_new_business_perc = num_new_business/tot_num_new_business
	gen log_num_new_business_perc = log(num_new_business_perc + 1)

	areg RealGDP_perc num_new_business_perc, absorb(stateFP)

	reg RealGDP_perc i.stateFP
	predict RealGDP_perc_resid, residuals
	reg num_new_business_perc i.stateFP
	predict num_new_business_perc_resid, residuals

	twoway (scatter RealGDP_perc_resid num_new_business_perc_resid, msize(vtiny)) ///
		(lfit RealGDP_perc_resid num_new_business_perc_resid ) ,  ///
		scheme(s2personal) title("% of New US Business Vs. % of US Real GDP") ///
		xtitle("% of National Real GDP") ytitle("% of National New Businesses") ///
		name("Method3", replace) ///
		legend(off)
	local save_file = "`economic_output'/NewBusRealGDPMethod3.eps"
	graph export "`save_file'", replace

	qui levelsof stateFP
	local states = "`r(levels)'"

	foreach state of numlist `states' {
		twoway (scatter log_RealGDP_perc quarter if stateFP == `state', yaxis(1)) ///
			(scatter log_num_new_business_perc quarter if stateFP == `state', yaxis(2)) ///
			(lpoly log_RealGDP_perc quarter if stateFP == `state', yaxis(1)) ///
			(lpoly log_num_new_business_perc quarter if stateFP == `state', yaxis(2)), ///
			scheme(s2personal) name("NewBusVsGDP_State`state'", replace)
	}

}
