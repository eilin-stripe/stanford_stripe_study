*******************************************************************************
** OVERVIEW
** Look at which industries are prone to annual patterns in growth
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do
local num_per = 40

** Setup Output folder for results
local industry_output = "`output'/Industry"
capture erasedir "`industry_output'"
mkdir "`industry_output'"

local data_vars = "mcc act_age customer_growth"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

#delimit ;
local mcc_codes =
"5734
7372
7392
5691
8999
5499
8398
8699
7221
8299
8661
8641
5192
5399
7997
7333
7922" ;
#delimit cr


disp "`mcc_codes'"
local mcc_codes_csv = subinstr("`mcc_codes'", " ", ", ", .)

disp "`mcc_codes_csv'"
tab mcc if inlist(mcc, `mcc_codes_csv'), sort


sort act_age mcc
egen age_ind_tag = tag(act_age mcc)


foreach ind of local mcc_codes {
	local industry =  "`:label mcc `ind''"
	disp "`industry'"
	local industry_nospc = subinstr("`industry'", " ", "", .)
	local industry_nospc = subinstr("`industry_nospc'", ",", "", .)
	disp "`industry_nospc'"
	lpoly customer_growth  act_age if mcc == `ind', ///
	msize(vtiny) ci scheme(s2personal) ///
	title("`industry'") name("`industry_nospc'", replace)
	graph export "`industry_output'/`industry_nospc'.eps", replace
}


* Focus on just the specific ones that are not so annual
keep if inlist(mcc, 5734, 7372, 7392, 5691, 8999)



/*
Covers around 84% of the companies, ///
these are companies that are at least 1 % of the database
*/
