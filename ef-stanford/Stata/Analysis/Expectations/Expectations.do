*******************************************************************************
** OVERVIEW
** Look at the fraction of firms that have exited
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do


local data_vars = "firm_id month customers cum_customers mcc act_age"


* use "`main_panel'"
** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

drop if cum_customers <= 2

keep if mcc == 5734

sort firm_id
by firm_id: egen max_age = max(act_age)

gen lb = .
gen ub = .
gen cust_count = .

foreach cust of numlist 0/200 {
    cii means 1 `cust' , poisson
    replace lb = r(lb) if _n == `cust'
    replace ub = r(ub) if _n == `cust'
    replace cust_count = `cust' if _n == `cust'
}

gen ub_perc0 = (ub - cust_count)/cust_count
gen lb_perc0 = (lb - cust_count)/cust_count
gen zeros  = 0

gen ub_perc1 = (ub)/cust_count
gen lb_perc1 = (lb)/cust_count
gen ones = 1

/*
pretty (line lb_perc0 cust_count) (line ub_perc0 cust_count) (line zeros cust_count)
pretty (line lb cust_count) (line ub cust_count) (line cust_count cust_count)
*/
pretty (line lb_perc1 cust_count if cust_count >= 10, lpattern(-) lcolor(eltblue)) ///
    (line ub_perc1 cust_count if cust_count >= 10, lpattern(-) lcolor(eltblue)) ///
    (line ones cust_count if cust_count >= 10 , lpattern(l)), ///
    xscale(log) xlabel(10 20 50 100 200)  ylabel(0(.25)2) ///
    legend(order(3 "Customers" 1 "Poisson Confidence Interval" )) ///
    xtitle("Customers") ytitle("Normalized Deviation")
graph export "`output'/ConfidenceIntervals.eps", replace






/*
foreach t of numlist 0/12 {
    pretty (hist cum_customers if act_age == `t' & max_age >= 13, xlogbase(1.2) fraction), name("CumCustAge`t'")
}

foreach t of numlist 0/12 {
    pretty (hist customers if act_age == `t' & max_age >= 13, xlogbase(1.2) fraction zeros(1)), name("CustAge`t'")
}
*/
* pretty hist cum_customers if act_age == 12, xlogbase(1.2) fraction
/*

gen first_month = 0
replace first_month = 1 if act_age == 0
gen total_customers_start_temp = first_month * cum_customers
by firm_id : egen total_customers_start = max(total_customers_start_temp)
gen cust_since_start = total_customers - total_customers_start

pretty hist cust_since_start if act_age == 12, xlogbase(1.2) fraction
*/

cii means 1 10 , poisson
