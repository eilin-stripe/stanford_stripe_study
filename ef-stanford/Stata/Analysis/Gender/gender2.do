*******************************************************************************
** OVERVIEW
** Look at the fraction of firms that have exited by gender of founder
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
gen female_L_log_cust = female*L_log_cust

*******************************************************************************
** Look at fraction of App firms failed over time
*******************************************************************************

keep if mcc == 5734
capture drop t inflate_est inflate_odds degenerate_prob_zip

local max_per = 13
gen t = .
replace t = _n if _n <= 1000

sort firm_id
by firm_id: egen max_age = max(act_age)

*******************************************************************************
** MALE
*******************************************************************************
capture drop dead_est_zinb_male_lb
capture drop dead_est_zinb_male_ub
capture drop dead_est_zinb_male
capture drop alive_est_zinb_male
capture drop hazard_male

gen num_firms_male = .
gen num_firms_active_male = .
gen avg_cust_male = .
gen avg_cust_male_lb = .
gen avg_cust_male_ub = .
gen dead_est_zinb_male  = .
gen dead_est_zinb_male_lb  = .
gen dead_est_zinb_male_ub  = .

foreach t of numlist 1/`max_per' {
    disp "age counter: `t' out of `max_per'"
    qui zinb customers L_log_cust if act_age == `t' & max_age >= `max_per' & ///
        female == 0  , inflate(L_log_cust)
    margin , predict(pr)
    matrix est = r(table)
    matrix N = r(_N)
    replace dead_est_zinb_male  = est[1, 1] if _n == `t'
    replace dead_est_zinb_male_lb  = est[5, 1] if _n == `t'
    replace dead_est_zinb_male_ub  = est[6, 1] if _n == `t'
    replace num_firms_male = N[1,1] if _n == `t'
    replace num_firms_active_male = N[1,1] * (1 - est[1,1]) if _n == `t'
    qui sum customers if act_age == `t' & female == 0 & max_age >= `max_per'
    replace avg_cust_male = r(sum) / num_firms_active_male if _n == `t'
    replace avg_cust_male_lb = avg_cust_male - 1.96 * (r(sd) / sqrt(r(N))) if _n == `t'
    replace avg_cust_male_ub = avg_cust_male + 1.96 * (r(sd) / sqrt(r(N))) if _n == `t'
}

gen alive_est_zinb_male = 1 - dead_est_zinb_male
gen hazard_male = (alive_est_zinb_male[_n] - alive_est_zinb_male[_n+1])/ ///
    (alive_est_zinb_male[_n])


*******************************************************************************
** FEMALE
*******************************************************************************

capture drop dead_est_zinb_female_lb
capture drop dead_est_zinb_female_ub
capture drop dead_est_zinb_female
capture drop alive_est_zinb_female
capture drop hazard_female

gen num_firms_female = .
gen num_firms_active_female = .
gen avg_cust_female = .
gen avg_cust_female_lb = .
gen avg_cust_female_ub = .
gen dead_est_zinb_female  = .
gen dead_est_zinb_female_lb  = .
gen dead_est_zinb_female_ub  = .

foreach t of numlist 1/`max_per' {
    disp "age counter: `t' out of `max_per'"
    qui zinb customers L_log_cust if act_age == `t' & max_age >= `max_per' & ///
        female == 1  , inflate(L_log_cust)
    margin , predict(pr)
    matrix est = r(table)
    matrix N = r(_N)
    replace dead_est_zinb_female  = est[1, 1] if _n == `t'
    replace dead_est_zinb_female_lb  = est[5, 1] if _n == `t'
    replace dead_est_zinb_female_ub  = est[6, 1] if _n == `t'
    replace num_firms_female = N[1,1] if _n == `t'
    replace num_firms_active_female = N[1,1] * (1 - est[1,1]) if _n == `t'
    qui sum customers if act_age == `t' & female == 1 & max_age >= `max_per'
    replace avg_cust_female = r(sum) / num_firms_active_female if _n == `t'
    replace avg_cust_female_lb = avg_cust_female - 1.96 * (r(sd) / sqrt(r(N))) if _n == `t'
    replace avg_cust_female_ub = avg_cust_female + 1.96 * (r(sd) / sqrt(r(N))) if _n == `t'
}

gen alive_est_zinb_female = 1 - dead_est_zinb_female
gen hazard_female = (alive_est_zinb_female[_n] - alive_est_zinb_female[_n+1])/ ///
    (alive_est_zinb_female[_n])

*******************************************************************************
** GRAPHS
*******************************************************************************

twoway (line dead_est_zinb_male t if t >= 1 & t <= 12, color(eltblue) lpattern(l)) ///
    (line dead_est_zinb_male_lb t if t >= 1 & t <= 12 , color(eltblue) lpattern(_)) ///
    (line dead_est_zinb_male_ub t if t >= 1 & t <= 12 , color(eltblue) lpattern(_)) ///
    (line dead_est_zinb_female t if t >= 1 & t <= 12, color(erose) lpattern(l)) ///
    (line dead_est_zinb_female_lb t if t >= 1 & t <= 12 , color(erose) lpattern(-)) ///
    (line dead_est_zinb_female_ub t if t >= 1 & t <= 12 , color(erose) lpattern(-)), ///
    name("zinb_dead_gender", replace) ///
    legend( on order(1 4)  label(1 "Male") label(4 "Female") label(2 off)) ///
    title("Percent Failure over Time ") ///
    xtitle("Age (Months)") ytitle("Percent of firms that failed") ///
    scheme(pretty1) xlabel(1/12)
graph export "`output'/ZinbDeadGenderApps.eps", replace

/*
twoway (line avg_cust_male t if t >= 1 & t <= 12, color(eltblue) lpattern(l)) ///
    (line avg_cust_male_ub t if t >= 1 & t <= 12, color(eltblue) lpattern(_)) ///
    (line avg_cust_male_lb t if t >= 1 & t <= 12, color(eltblue) lpattern(_)) ///
    (line avg_cust_female t if t >= 1 & t <= 12, color(erose) lpattern(l)) ///
    (line avg_cust_female_ub t if t >= 1 & t <= 12, color(erose) lpattern(_)) ///
    (line avg_cust_female_lb t if t >= 1 & t <= 12, color(erose) lpattern(_)) , ///
    name("zinb_customers_gender", replace) ///
    legend( on order(1 4)  label(1 "Male") label(4 "Female") label(2 off)) ///
    title("Average Customers of Survivors") ///
    xtitle("Age (Months)") ytitle("Average Customers of Survivors") ///
    scheme(pretty1) xlabel(1/12)
graph export "`output'/ZinbCustomerGenderApps.eps", replace
*/

twoway (line avg_cust_male t if t >= 1 & t <= 12, color(eltblue) lpattern(l)) ///
    (line avg_cust_female t if t >= 1 & t <= 12, color(erose) lpattern(-)),  ///
    name("zinb_customers_gender", replace) ///
    legend(label(1 "Male") label(2 "Female")) ///
    title("Average Customers of Survivors") ///
    xtitle("Age (Months)") ytitle("Average Customers of Survivors") ///
    scheme(pretty1) xlabel(1/12)
graph export "`output'/ZinbCustomerGenderApps.eps", replace


*******************************************************************************
** ZINB
*******************************************************************************

eststo clear
eststo: zinb customers L_log_cust female female_L_log_cust if act_age <= 12 & max_age >= 12, inflate(L_log_cust female female_L_log_cust) difficult
estadd local fixed "no" , replace
eststo: zinb customers L_log_cust female female_L_log_cust if act_age <= 12 & max_age >= 12, inflate(L_log_cust female female_L_log_cust i.act_age) difficult
estadd local fixed "yes" , replace
matrix params =  e(b)
local save_file = "`output'/zinb_gender.tex"
esttab using "`save_file'", replace style(tex) ///
    varlabels(L_log_cust "Ln(Cust_{t-1})" female_L_log_cust ///
    "Female X Ln(Cust\_{t-1})" _cons "Cons") ///
    s(fixed, label("Age Fixed Effects")) ///
    drop (*act_age) substitute(\_ _) mtitles("Customers" "Customers") ///
    starlevels(* 0.1 ** 0.05 *** 0.01)

local ln2 = log(2)
local ln3 = log(3)
local ln6 = log(6)
local ln11 = log(11)
local ln21 = log(21)
local ln51 = log(51)
local ln101 = log(101)
local ln201 = log(201)
local ln501 = log(501)
twoway (function y = params[1, 4] + params[1, 1] * x, color(eltblue) range(0 6)) ///
    (function y = params[1, 4]+params[1, 2] + (params[1, 1] + params[1, 3])* x, color(erose) range(0 6)) ///
    , name("GrowthGender", replace) scheme(pretty1) ///
     xtitle("Customers") ytitle("Next Period Expected Customers") ///
     title("Growth by Gender") ///
     legend(label(1 "Male") label(2 "Female") ) ///
     xlabel(0 "0" `ln2' "1" `ln3' "2" `ln6' "5" `ln11' "10" `ln21' "20" `ln51' "50" `ln101' "100" `ln201' "200" `ln501' "500") ///
     ylabel(0 "0" `ln2' "1" `ln3' "2" `ln6' "5" `ln11' "10" `ln21' "20" `ln51' "50" `ln101' "100" `ln201' "200" `ln501' "500")

graph export "`output'/ZinbCustomerGrowthGenderApps.eps", replace

twoway (function y = exp(params[1, 8] + params[1, 5] * x)/ (exp(params[1, 8] + params[1, 5] * x) + 1), color(eltblue) range(0 2)) ///
    (function y = exp(params[1, 8]+params[1, 6] + (params[1, 5] + params[1, 7])* x)/ (exp(params[1, 8]+params[1, 6] + (params[1, 5] + params[1, 7])* x) + 1), color(erose) range(0 2)) ///
     , name("ExitGender", replace) scheme(pretty1) ///
      xtitle("Customers") ytitle("Likelihood of Exiting") ///
      title("Likelihood of Exiting by Customers and Gender") ///
      legend(label(1 "Male") label(2 "Female") ) ///
      xlabel(0 "0" `ln2' "1" `ln3' "2" `ln6' "5" )
graph export "`output'/ZinbExitGenderApps.eps", replace

*******************************************************************************
** ENTERING FRACTION
*******************************************************************************

gen perc_female = .
gen perc_female_std_dev = .
gen perc_female_ub = .
gen perc_female_lb = .
local min_month = 646
local max_month = 688
foreach t of numlist `min_month'/`max_month' {
    count if female == 1 & month == `t' & max_age >= `max_per'
    local count_female = r(N)
    count if female == 0 & month == `t' & max_age >= `max_per'
    local count_male = r(N)
    local count_all = `count_female' + `count_male'
    replace perc_female  = `count_female' / (`count_all') if _n == `t' - 647
    replace perc_female_std  = (perc_female * (1 - perc_female)) / `count_all' if _n == `t' - 647
}

replace perc_female_ub = perc_female + 1.96 * perc_female_std
replace perc_female_lb = perc_female - 1.96 * perc_female_std

twoway (line perc_female t if t <= 30),  ///
    name("perc_female", replace) ///
    title("Percent of New Firms Founded by Women") ///
    xtitle("Time Period") ytitle("Percent Founded by Women") ///
    scheme(pretty1)
graph export "`output'/ZinbPercentGenderApps.eps", replace

/*
twoway (line perc_female t if t <= 30) ///
    (line perc_female_ub t if t <= 30, lpattern(-)) ///
    (line perc_female_lb t if t <= 30, lpattern(-)) , ///
    name("perc_female", replace) ///
    legend(label(1 "Male") label(2 "Female")) ///
    title("Average Customers of Survivors") ///
    xtitle("Age (Months)") ytitle("Average Customers of Survivors") ///
    scheme(pretty1) xlabel(1/12)
graph export "`output'/ZinbCustomerGenderApps.eps", replace
*/




*******************************************************************************
