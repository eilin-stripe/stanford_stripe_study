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

** Load in the Stripe Panel data
use "`main_panel'", clear

** Set directory for all output
** local file_output = "`output'/CustomerGrowth"

*******************************************************************************
** Explore GPV per customer
*******************************************************************************
** See if older firms sell more to each customer or less
sort firm_id
by firm_id : egen max_age = max(act_age)
keep if max_age >= 36
collapse (sum) gpv customers , by(act_age)


gen gpv_per_customers = gpv / customers

scatter gpv_per_customers act_age, scheme(s2personal) ///
    title("Average GPV per Customer By Firm Age") ///
    xtitle("Firm Age (Months)") ytitle("GPV per Customer") ///
    name("GPVPerCustByFirmAge")
graph export "`output'/GPVPerCustByFirmAge.eps", replace
