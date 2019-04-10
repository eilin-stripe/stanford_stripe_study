*******************************************************************************
** OVERVIEW
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do

local data_vars = "firm_id month first_month customers gpv transactions " + ///
    "total_customer mcc act_age"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

use "`main_panel'", clear
/*
keep if act_age == 2

gen FirmType1 = exp(rnormal(1, 2.15))
*gen FirmType1 = rgamma(.25, 50)
gen Customers1 = rpoisson(FirmType1)

twoway__histogram_gen customers, gen(cust_h cust_x) frequency width(3)
twoway__histogram_gen Customers1, gen(Cust1_h Cust1_x) frequency width(3)

twoway (scatter cust_h cust_x, msize(vsmall)) ///
    (scatter Cust1_h Cust1_x , msize(vsmall)), ///
    xscale(log) yscale(log) scheme(pretty1)
* pretty scatter cust_h cust_x
*/
qui {

* SynthData, obs(10000) alive(1) p(.5) r(2)
/*
twoway (function y1 = (x * exp(-x)), range(0 10)) ///
    (function y2 = (x^2 * exp(-x))/2, range(0 10)) ///
    (function y_mix = ((x^2 * exp(-x))/2 + (x * exp(-x)))/2 , range(0 10))
*/

/*
sum customers
local mean = r(mean)
local var = r(Var)
local p = 1 - sqrt(`mean'/`var')
local r = ((1-`p') * `mean')/`p'
disp "p = `p' and r = `r'"
gen cust_p1 = customers + 1
twoway (hist cust_p1, freq discrete) (function y = 14322 *nbinomialp(`r',x,`p'), range(1 10000)), xscale(log)
*/
}
