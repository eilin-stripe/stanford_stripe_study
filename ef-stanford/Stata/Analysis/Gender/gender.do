*******************************************************************************
** OVERVIEW
** Look at the fraction of firms that have exited
*******************************************************************************
/*
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

*******************************************************************************
** Look at fraction of App firms failed over time
*******************************************************************************

keep if mcc == 5734

sort firm_id
by firm_id: egen max_age = max(act_age)

capture drop t
capture drop inflate_est_female
capture drop inflate_est_male
capture drop inflate_odds_female
capture drop inflate_odds_male
capture drop degenerate_prob_zinb
capture drop dead_est_zinb_female
capture drop dead_est_zinb_male
capture drop alive_est_zinb_female
capture drop alive_est_zinb_male
capture drop hazard

gen t = .
replace t = _n - 1 if _n <= 40
gen inflate_est_female = .
gen inflate_est_male = .

gen degenerate_prob_zinb = .

*******************************************************************************
** FEMALE SURVIVAL AND SIZE COMPUTATIONS
*******************************************************************************

foreach t of numlist 1/13 {
    disp "age counter: `t' out of 13"
    tempvar tmp
    qui zinb customers L_log_cust if act_age == `t' & female == 1 & max_age >= 13, inflate(L_log_cust)
    qui predict `tmp', pr
    qui replace degenerate_prob_zinb  = `tmp' if act_age == `t' & female == 1
    matrix betas = e(b)
    local inflate = betas[1, 4]
    qui replace inflate_est_female = `inflate' if _n == `t' + 1
    drop `tmp'
    sum degenerate_prob_zinb if act_age == `t' & female == 1
}

gen dead_est_zinb_female  = .
gen num_firms_female  = .
gen avg_cust_female  = .
sum customers if act_age == 0 & female == 1
replace avg_cust_female = r(mean) if _n == 1
foreach t of numlist 1/13 {
    qui sum degenerate_prob_zinb  if act_age == `t' & female == 1
    replace dead_est_zinb_female  = r(mean) if _n == `t' + 1
    replace num_firms_female  = r(N) if _n == `t' + 1
    local num_firms_female_alive = r(N) * (1 - r(mean))
    sum customers if act_age == `t' & female == 1
    replace avg_cust_female = r(sum) / `num_firms_female_alive' if _n == `t' + 1
}

gen alive_est_zinb_female = 1-dead_est_zinb_female
gen hazard_female  = (alive_est_zinb_female[_n]-alive_est_zinb_female[_n+1]) ///
    /(alive_est_zinb_female[_n])

*******************************************************************************
** MALE SURVIVAL AND SIZE COMPUTATIONS
*******************************************************************************

foreach t of numlist 1/13 {
    disp "age counter: `t' out of 13"
    tempvar tmp
    qui zinb customers L_log_cust if act_age == `t' & female == 0 & max_age >= 13 , inflate(L_log_cust)
    qui predict `tmp', pr
    qui replace degenerate_prob_zinb  = `tmp' if act_age == `t' & female == 0
    matrix betas = e(b)
    local inflate = betas[1, 4]
    qui replace inflate_est_male = `inflate' if _n == `t' + 1
    drop `tmp'
    sum degenerate_prob_zinb if act_age == `t' & female == 0
}

gen dead_est_zinb_male  = .
gen num_firms_male  = .
gen avg_cust_male  = .
sum customers if act_age == 0 & female == 0
replace avg_cust_male = r(mean) if _n == 1
foreach t of numlist 1/13 {
    qui sum degenerate_prob_zinb  if act_age == `t' & female == 0
    replace dead_est_zinb_male  = r(mean) if _n == `t' + 1
    replace num_firms_male  = r(N) if _n == `t' + 1
    local num_firms_male_alive = r(N) * (1 - r(mean))
    sum customers if act_age == `t' & female == 0
    replace avg_cust_male = r(sum) / `num_firms_male_alive' if _n == `t' + 1
}


gen alive_est_zinb_male = 1-dead_est_zinb_male
gen hazard_male  = (alive_est_zinb_male[_n]-alive_est_zinb_male[_n+1]) ///
    / (alive_est_zinb_male[_n])

twoway (scatter alive_est_zinb_male t) ///
    (scatter alive_est_zinb_female t) if t <= 12, ///
    scheme(pretty1) xlabel(1(1)12) xscale(range(1 12)) ///
    xtitle("Age (Months)") ytitle("Fraction In Business") ///
    title("Percent of Firms Alive by Month and Gender") ///
    name("PercentAliveGender", replace) ///
    legend(label(1 "Male") label(2 "Female"))
graph export "`output'/PercentAliveGender.eps"

twoway (scatter avg_cust_male t) (scatter avg_cust_female t) if t <= 12, ///
    scheme(pretty1) name("AvgCustomersGender", replace) ///
    xtitle("Age (Months)") ytitle("Average # of Customers") ///
    title("Average Number of Customers by Month and Gender") ///
    legend(label(1 "Male") label(2 "Female"))
graph export "`output'/AvgCustomersGender.eps"
*/





/*
zinb customers L_log_cust female female_L_log_cust if act_age >= 13 & act_age <= 24 & max_age >= 24, inflate(L_log_cust female female_L_log_cust) difficult
zinb customers L_log_cust female female_L_log_cust if act_age >= 25 & act_age <= 36 & max_age >= 36, inflate(L_log_cust female female_L_log_cust) difficult
*/
