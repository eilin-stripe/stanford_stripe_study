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


local data_vars = "firm_id month customers mcc act_age cum_drought_length female"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

sort firm_id month
gen log_cust = log(customers + 1)
gen L_log_cust = L.log_cust

*******************************************************************************
** Look at fraction of App firms failed over time
*******************************************************************************

keep if mcc == 5734
capture drop t inflate_est inflate_odds degenerate_prob_zip

local max_per = 12
gen t = .
replace t = _n if _n <= `max_per'

sort firm_id
by firm_id: egen max_age = max(act_age)

capture drop dead_est_zinb_lb
capture drop dead_est_zinb_ub
capture drop dead_est_zinb
capture drop alive_est_zinb
capture drop hazard

gen num_firms = .
gen num_firms_active = .
gen avg_cust_cond = .
gen avg_cust_uncond = .
gen dead_est_zinb  = .
gen dead_est_zinb_lb  = .
gen dead_est_zinb_ub  = .

foreach t of numlist 1/`max_per' {
    disp "age counter: `t' out of `max_per'"
    qui zinb customers L_log_cust if act_age == `t' & max_age >= `max_per' , inflate(L_log_cust)
    margin , predict(pr)
    matrix est = r(table)
    matrix N = r(_N)
    replace dead_est_zinb  = est[1, 1] if _n == `t'
    replace dead_est_zinb_lb  = est[5, 1] if _n == `t'
    replace dead_est_zinb_ub  = est[6, 1] if _n == `t'
    replace num_firms = N[1,1] if _n == `t'
    replace num_firms_active = N[1,1] * (1 - est[1,1]) if _n == `t'
    qui sum customers if act_age == `t' & max_age >= `max_per'
    replace avg_cust_cond = r(sum) / num_firms_active if _n == `t'
    replace avg_cust_uncond = r(sum) / num_firms if _n == `t'
}

gen alive_est_zinb = 1 - dead_est_zinb
gen hazard = (alive_est_zinb[_n] - alive_est_zinb[_n+1])/(alive_est_zinb[_n])

twoway (line dead_est_zinb t if t >= 1 & t <= `max_per') ///
    (line dead_est_zinb_lb t if t >= 1 & t <= `max_per' , lpattern(-)) ///
    (line dead_est_zinb_ub t if t >= 1 & t <= `max_per' , lpattern(-)) , ///
    name("zinb_dead", replace) legend(off) ///
    title("Percent Failure over Time ") ///
    xtitle("Age (Months)") ytitle("Percent of firms that failed") ///
    scheme(pretty1) xlabel(1/`max_per')
graph export "`output'/ZinbDeadApps.eps", replace

twoway (line avg_cust_cond t if t >= 1 & t <= `max_per') ///
    (line avg_cust_uncond t if t >= 1 & t <= `max_per'), ///
    name("zinb_customers", replace) ///
    legend(label(1 "Condtional on Survival") label(2 "Unconditional on Survival")) ///
    title("Average Customers of Survivors") ///
    xtitle("Age (Months)") ytitle("Average Customers of Survivors") ///
    scheme(pretty1) xlabel(1/`max_per')
graph export "`output'/ZinbCustomerApps.eps", replace

local min1 = `max_per'-1
twoway (qfit hazard t) (scatter hazard t) , name("zinb_hazard", replace) ///
    xlabel(1/`min1') scheme(pretty1) ///
    title("Monthly Hazard Rate over Time ") ///
    xtitle("Age (Months)") ytitle("Hazard Rate (Monthly)")
graph export "`output'/ZinbHazardApps.eps", replace

/*
*******************************************************************************
** Look at If this lines up with what we expect from our histogram
*******************************************************************************

pretty (hist customers if act_age == 40, xlogbase(1.2) zeros(1)) , ///
    save("`output'/CustomersHist40Apps.eps")

lpoly log_cust act_age , noscatter
lpoly log_cust act_age if max_age >= 36, noscatter

gen zero_sale = 0
replace zero_sale = 1 if customers == 0

lpoly zero_sale act_age , noscatter
lpoly zero_sale act_age if max_age >= 36 , noscatter
*/
