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


local data_vars = "firm_id month customers gpv transactions mcc act_age cum_state_length cum_sale_length cum_drought_length female"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

keep if mcc == 5734

sort firm_id
by firm_id: egen max_age = max(act_age)

sort firm_id month
gen log_cust = log(customers + 1)
gen L_log_cust = L.log_cust
gen female_L_log_cust = female*L_log_cust
foreach lag of numlist 2/12 {
    gen L`lag'_log_cust = L`lag'.log_cust
    gen female_L`lag'_log_cust = female*L`lag'_log_cust
}

gen log_gpv = log(gpv + 1)
gen L_log_gpv = L.log_gpv
gen female_L_log_gpv = female*L_log_gpv
foreach lag of numlist 2/12 {
    gen L`lag'_log_gpv = L`lag'.log_gpv
    gen female_L`lag'_log_gpv = female*L`lag'_log_gpv
}

gen F_customers = F.customers
gen customer_growth = (D.F_customers / (0.5 * (customers + F_customers)))
replace customer_growth = 0 if F.customers == 0 & customers ==0

gsort act_age customers F_customers - max_age
by act_age customers F_customers : gen rank = _n
gen prob_degen = .
gen t = .
gen avg_growth = .
local max_per = 15
local extra = `max_per' + 1
foreach age of numlist 1/`max_per' {
    zinb customers L_log_cust if act_age == `age' & max_age >= `extra', inflate(L_log_cust)

    predict prob_degen_temp if act_age == `age' & max_age >= `extra', pr
    replace prob_degen = prob_degen_temp if act_age == `age'  & max_age >= `extra'
    drop prob_degen_temp
    sum prob_degen if act_age == `age'  & max_age >= `extra'
    local failed_`age' = floor(`r(mean)' * `r(N)')
    disp "`failed_`age''"

    replace customer_growth = . if rank <= `failed_`age'' & customers == 0 & F_customers == 0 & act_age == `age'
    sum customer_growth  if act_age == `age' & max_age >= `extra'
    replace t = `age' if _n == `age'
    replace avg_growth = `r(mean)' if _n == `age'
}



**
