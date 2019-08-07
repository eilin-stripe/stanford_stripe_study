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

local data_vars = "firm_id month customers mcc act_age total_customers"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

** Only keep activated firms
drop if total_customers < 3

* Only keep the Computer Software Stores industry (Apps)
keep if mcc == 5734

keep if act_age == 2

*******************************************************************************
** Produce the overlay plot
*******************************************************************************


gen i = _n - 1
poisson_lognormalp i, out("pdf1") mu(.8) sigma(2.2)
twoway__histogram_gen customers , discrete gen(x y)
twoway (line pdf1 i if i>= 1, color(black)) ///
    (line x y if y > = 1, color(red)) , xscale(log) ///
    xlabel(1 2 3 4 5 10 50 100 500 1000 5000 ) scheme(pretty1) ///
    legend(label(1 "Fitted") label(2 "Data")) ///
    xtitle("Customers") ytitle("Fraction") title("Firm Size Distribution")

local save_file = "`output'/Overlay.eps"
graph export "`save_file'", replace
