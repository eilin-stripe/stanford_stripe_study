*******************************************************************************
** OVERVIEW
** Takes the raw firm panel data from Stripe and cleans it
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
use "`raw_stripe'/panel_may11.dta"

*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************

** Rename variables for convenience
rename gross_processing_volume gpv
rename unique_payers customers
rename total_transactions transactions

** Clean up the date variable to create month variables as a time index
replace month = subinstr(month, "T00:00:00Z","", .)
replace month = subinstr(month, "-","", .)
gen day = date(month, "YMD")
drop month
gen int month = mofd(day)
drop day
format month %tm

sum month
local max_month = `r(max)' - 1

gen max_month_flag = 0
replace max_month_flag = 1 if month == `max_month'

****************************
** MERGE IN EMPLOYEE DATA **
****************************
* merge m:1 token month using "`base'/Data/Clean/employee_panel.dta", keep(matched) nogen

merge m:1 token month using "`base'/Data/Clean/Stripe/disputes.dta", keep(matched master) nogen


********************************
** SETUP PANEL DATA STRUCTURE **
********************************

** Create a more usable firm id from the token
egen int firm_id = group(token)

** Set the data up as panel dat
xtset firm_id month, monthly

** Fill in the data for months where there weren't any customers
* Add the observations
tsfill, full
* Refill in the token numbers for each firm
gsort firm_id -month
by firm_id : replace token = token[_n+1] if missing(token)
by firm_id : replace token = token[_n-1] if missing(token)

gsort firm_id month
by firm_id : replace token = token[_n+1] if missing(token)
by firm_id : replace token = token[_n-1] if missing(token)

* Set all sales variables to zero for months that were missing
local vars = "gpv transactions customers"
foreach v of varlist `vars' {
	replace `v' = 0 if `v' == .
}

** Tag one observation for each firm for easy reference to collapsed data
egen firm_tag = tag(firm_id)

***********************************************
** CLEAN CUSTOMERS, TRANSACTIONS, AND VOLUME **
***********************************************

* Now that all the sales variables are filled in, create log versions
foreach v of varlist `vars' {
	gen log_`v' = log(`v' + 1)
	label variable log_`v' "Log `v'"
}


** Generate and label the relative metrics
gen gpv_per_cust = gpv / customers
label variable gpv_per_cust "GPV Per Customer"

gen log_gpv_per_cust = log(gpv_per_cust + 1)
label variable log_gpv_per_cust "Log GPV Per Customer"

gen gpv_per_transaction = gpv / transactions
label variable gpv_per_transaction "GPV Per Transaction"

gen log_gpv_per_transaction = log(gpv_per_transaction + 1)
label variable log_gpv_per_transaction "Log GPV Per Transaction"

gen transactions_per_customer = transactions / customers
label variable transactions_per_customer "Transactions Per Customer"

gen log_transactions_per_customer = log(transactions_per_customer + 1)
label variable log_transactions_per_customer "Log Transactions Per Customer"



* Generate growth rates
gen customer_growth = (D.customers / (0.5 * (L.customers + customers)))
label variable customer_growth "Customer Growth"
gen transaction_growth = (D.transactions / (0.5 * (L.transactions + transactions)))
label variable transaction_growth "Transaction Growth"
gen gpv_growth = (D.gpv / (0.5 * (L.gpv + gpv)))
label variable gpv_growth "GPV Growth"

gen gpv_per_cust_growth = (D.gpv_per_cust / (0.5 * (L.gpv_per_cust + gpv_per_cust)))
label variable gpv_per_cust_growth "GPV Per Customer Growth"
gen gpv_per_cust2_growth = (D.gpv_per_cust / (L.gpv_per_cust))

gen gpv_per_trans_growth = (D.gpv_per_transaction / (0.5 * (L.gpv_per_transaction + gpv_per_transaction)))
gen trans_per_cust_growth = (D.transactions_per_customer / (0.5 * (L.transactions_per_customer + transactions_per_customer)))


** Generate approximate lifetime totals. cum_* is the running total and
** total is the complete total at the last period in the dataset
sort firm_id month
foreach v of varlist `vars' {
	by firm_id: gen cum_`v' = sum(`v')
	by firm_id: egen total_`v' = sum(`v')
	gen log_cum_`v' = log(cum_`v' + 1)
}

***********************************
** GENERATE USEFUL SALES METRICS **
***********************************

* Generate a sales dummy for when there was a sale in a month
gen byte sale_dum = 0
replace sale_dum = 1 if customers > 0
replace sale_dum = . if customers == .

* Find the first month with a sale and the last month with a sale
gen int month_w_sale = sale_dum * month
replace month_w_sale = . if month_w_sale == 0
by firm_id: egen int firm_data_start = min(month_w_sale)
by firm_id: egen int firm_data_end = max(month_w_sale)

** Remove observations for any firm that occur before the firms first
** month with a customer
drop if month < firm_data_start

* Generate an age variable, which is the length of time since a given
* firm first appeared in our dataset.
gen byte firm_data_age = month - firm_data_start + 1

* Generate a variable, which is the length of time since a given
* firm last had a sale in our dataset.
gen byte months_since_last = month - firm_data_end

** Not dead for sure demarcates firms that have at least one sale in the future
gen byte not_dead_for_sure = 0
by firm_id : replace not_dead_for_sure = 1 if firm_data_end >= month


***********************************
** MERGE IN FIRM CHARACTERISTICS **
***********************************
merge m:1 token using "`clean_stripe'/FirmCharacteristics.dta", keep(matched)

** Clean up Activation data
gen int activation_month = mofd(activation_date)
gen byte activated = 0
replace activated = 1 if month >= activation_month
gen int act_year = year(dofm(activation_month))
gen byte act_month = month(dofm(activation_month))
gen act_age = month - activation_month

*** I'm only going to keep observations following activation. This can be removed
*** to keep pre-activation data
drop if activated == 0

** Create tag for firms activation_month
gen byte first_month = 0
replace first_month = 1 if activation_month == month


***********************************
** MERGE IN GEO CODES **
***********************************

mmerge state using "`tiger'/state.dta", ///
	type(n:1) umatch(STUSPS) ///
    unmatched(master) uname("state") ukeep(_ID STATEFP)
drop _merge
rename stateSTATEFP stateFP


***********************
** CREATE PHASE DATA **
***********************
* A Phase will be a streak of entirely sales, or entirely no sales. If the
* phase is one with no sales, then it is a drought phase . If the phase is
* one with sales every period, then it is a sales phase.

sort firm_id month

** Identify any time a firm goes from a month with a sale to one without, or
** vice-versa
gen byte flip = 0
by firm_id : replace flip = 1 if sale_dum != sale_dum[_n - 1]

** Create an id for what phase a firm is in a given period
by firm_id : gen byte phase_count = sum(flip)

** For each phase calculate the length of the phase
sort firm_id phase_count month
by firm_id phase_count : gen byte total_phase_length = _N
by firm_id phase_count : gen byte cum_phase_length = _n

** Calculate the number of phases that each business goes through
by firm_id: egen byte num_phase = max(phase_count)
** create a tag to select any given phase at any given firm
egen phase_tag = tag(firm_id phase_count)

** Create a drought_length variable for phases that are droughts
gen byte total_drought_length = total_phase_length * (1 - sale_dum)
** Create a sale length variable for phases that are sale
gen byte total_sale_length = total_phase_length * sale_dum
** Create a fixed drought length variable for phases that are droughts, but that
** eventually come to an end with a sale
gen byte total_fixed_drought_length = total_drought_length * not_dead_for_sure

** Create a drought_length variable for phases that are droughts
gen byte cum_drought_length = cum_phase_length * (1 - sale_dum)
** Create a sale length variable for phases that are sale
gen byte cum_sale_length = cum_phase_length * sale_dum
** Create a fixed drought length variable for phases that are droughts, but that
** eventually come to an end with a sale
gen byte cum_fixed_drought_length = cum_drought_length * not_dead_for_sure


** Create a cumulative state variable where droughts are negative and sales are
** positive
gen cum_state_length = cum_sale_length
replace cum_state_length = - cum_drought_length if cum_drought_length > 0

save "`main_panel'", replace
