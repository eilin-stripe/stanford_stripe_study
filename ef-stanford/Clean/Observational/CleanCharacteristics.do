*******************************************************************************
** OVERVIEW
** Takes the raw employee count data from Stripe and cleans it
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

** Load in the Stripe Panel data
use "`raw_stripe'/main_may12.dta"

qui ds, has(type string)
local string_vars = "`r(varlist)'"

// Deal with missing values in string variables
foreach var of varlist `string_vars' {
	replace `var' = "" if `var' == "null"
}
destring *, replace


*******************************************************************************
** DROP UNIMPORTANT VARIABLES
*******************************************************************************
// Country is US for all observations, so drop country
drop *country*

drop *address_city *tax_id_number_ciph

*******************************************************************************
** CLEAN-UP VARIABLE NAMES
*******************************************************************************
rename legal_entity__* *
rename unified_funnel__* *
rename unified__* *
rename usd_100k_run_rat usd_100k_run_rate
rename label__industry__primary_vertica primary_ind
rename cumulative* cum*
rename cum_npv_u cum_npv
rename cum_trans cum_tran
rename lifetime_max_vol max_vol
rename address_state state
rename address_zip zip
rename heavy_user_connect heavy_user
rename first_application_submitted_date first_app_date
rename last_successful_ last_tran_date
rename est_founding_date found_date
rename usd_10k_run_rate run_rate_10k
rename usd_100k_run_rate run_rate_100k
rename usd_1m_run_rate run_rate_1m
rename founded_year found_year

*******************************************************************************
** CLEAN DATES
*******************************************************************************
local date_vars = "activation_date first_app_date " + ///
	"last_tran_date run_rate_10k run_rate_100k run_rate_1m " + ///
	"found_date"

foreach var of varlist `date_vars' {
	replace `var' = subinstr(`var', "T00:00:00Z","", .)
	replace `var' = subinstr(`var', "-","", .)
	// destring `var', replace
	gen temp = date(`var', "YMD")
	drop `var'
	rename temp `var'
	format `var' %td
}


*******************************************************************************
** CLEAN-UP VARIABLE LABELS
*******************************************************************************
label variable cum_npv "Cummulative NPV USD"
label variable cum_tran "Cummulative transactions"
label variable max_vol "Lifetime Max Volume Tier"
label variable primary_ind "DNA Primary Industry"
label variable mcc "Merchant Category Code"
label variable heavy_user "Heavy Connect user"
label variable first_app_date "First application submitted date"
label variable last_tran_date "Last successful transaction date"
label variable found_date "Mattermark estimated found date"
label variable found_year "Clearbit founding year"
label variable last_28_gpv "Gross payment volume past 28 days"
label variable last_90_gpv "Gross payment volume past 90 days"
label variable activation_date "Date of 3rd active customer"
label variable type "Ownership type (Corp, LLC, etc.)"


*******************************************************************************
** FIX CODING ERRORS
*******************************************************************************
replace state = "TX" if state == "Texas"

*******************************************************************************
** ENCODING STRING VARS
*******************************************************************************
local encode_vars = "type primary_ind"
foreach var of varlist `encode_vars' {
	encode `var', gen(`var'_temp)
	drop `var'
	rename `var'_temp `var'
}

label define order  0 false  2 true
encode heavy_user, gen(heavy_user_temp) label(order)
drop heavy_user
rename heavy_user_temp heavy_user

compress


*******************************************************************************
** DROP VARIABLES OBSERVABLE IN PANEL
*******************************************************************************
drop max_vol
drop cum_*
drop last_*_gpv
drop run_rate*


*******************************************************************************
** APPLY INDUSTRY CLASSIFICATION LABELS
*******************************************************************************
merge m:1 mcc using "`clean_industry'/mcc_codes.dta", keep(master matched) nogen

** Assign the irs mcc labels to the mcc variable, and then drop them
labmask mcc, values(mcc_label)
drop mcc_label

*******************************************************************************
** APPLY GENDER LABELS
*******************************************************************************
merge 1:1 token using "`raw_stripe'/gender.dta", keep(master matched) nogen

*******************************************************************************
** SAVE THE DATA FOR MERGING WITH PANEL
*******************************************************************************
save "`clean_stripe'/FirmCharacteristics.dta", replace
