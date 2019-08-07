*******************************************************************************
** OVERVIEW
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear
graph drop _all

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do

** Load in the Stripe Panel data
local data_vars = "state stateFP state_ID  month firm_id gpv mcc"
local data_vars = "*"
local data_vars = "firm_id gpv_per_cust max_month_flag customers gpv sale_dum"
local data_vars = "firm_id month customers gpv transactions mcc act_age "
use `data_vars' using "`main_panel'", clear


sort firm_id month
gen log_cust = log(customers + 1)
gen L_log_cust = L.log_cust
gen L12_log_cust = L12.log_cust

gen log_gpv= log(gpv + 1)
gen L_log_gpv = L.log_gpv
gen L12_log_gpv = L12.log_gpv

eststo clear
eststo : zinb customers L12_log_cust L12_log_gpv if act_age == 13, inflate(L12_log_cust L12_log_gpv)
eststo : zinb customers L12_log_cust L12_log_gpv if act_age == 13 & mcc == 5734, inflate(L12_log_cust L12_log_gpv)
// eststo : zinb customers L_log_cust L_log_gpv , inflate(L_log_cust L_log_gpv)

local save_file = "`output'/gpv_cust_growth.tex"
esttab using "`save_file'", replace label se

**************************************
** Look into Customer Concentration **
**************************************
** GPV per customer looks at something app
** Transactions per customer seems like a better measure of loyalty
**


pretty_loghist gpv_per_cust if max_month_flag == 1, ///
	title("Histogram of GPV per Customer") ///
	xtitle("GPV per Customer") ///
	name("gpv_per_cust") save("`output'/gpv_per_cust.eps")

xtile customers_bin = customers if customers != 0, nquantiles(20)
xtile  gpv_bin = gpv if customers != 0, nquantiles(20)


matrix mat_mean = J(20,20, 0)
matrix mat_sd = J(20,20, 0)

sort firm_id month

local metrics = " cum_drought_length"

***************************
** Sale Dummy in 2 Years **
***************************
forvalues ii = 1/20 {
	forvalues jj = 1/20 {
		qui sum F24.sale_dum if customers_bin == `ii' & gpv_bin == `jj'
		local ii = 21 - `ii'
		if "`r(mean)'" == "" {
			matrix mat_mean[`ii' , `jj'] = .
		}
		else {
			matrix mat_mean[`ii' , `jj'] = `r(mean)'
		}
		if "`r(sd)'" == "" {
			matrix mat_sd[`ii' , `jj'] = .
		}
		else {
			matrix mat_sd[`ii' , `jj'] = `r(sd)'
		}
	}
}

plotmatrix , mat(mat_mean) maxticks(0) ///
	xtitle("Binned GPV") ytitle("Binned Number of Customers") ///
	title("Probability of Sale in 2 year by binned GPV and Customers") ///
	ylabel(-20 " ") name("saleprob_heatmap") ///
	split(0(0.1)1)

*	legend(off)
graph export "`output'/customer_gpv_mean_saleprob_heatmap.eps", replace


***************************
** Sale Dummy in 2 Years **
***************************
forvalues ii = 1/20 {
	forvalues jj = 1/20 {
		qui sum F24.cum_drought_length if customers_bin == `ii' & gpv_bin == `jj'
		local ii = 21 - `ii'
		if "`r(mean)'" == "" {
			matrix mat_mean[`ii' , `jj'] = .
		}
		else {
			matrix mat_mean[`ii' , `jj'] = `r(mean)'
		}
		if "`r(sd)'" == "" {
			matrix mat_sd[`ii' , `jj'] = .
		}
		else {
			matrix mat_sd[`ii' , `jj'] = `r(sd)'
		}
	}
}

plotmatrix , mat(mat_mean) maxticks(0) ///
	xtitle("Binned GPV") ytitle("Binned Number of Customers") ///
	title("Drought Length in 2 year by binned GPV and Customers") ///
	split(0(1)10) ylabel(-20 " ") name("drought_heatmap")
graph export "`output'/customer_gpv_mean_drought_heatmap.eps", replace



********************************************************************************




xtile customer_growth_bin = customer_growth if customers != 0, nquantiles(20)
xtile  gpv_growth_bin = gpv_growth if customers != 0, nquantiles(20)


matrix mat_growth_mean = J(20,20, 0)
matrix mat_growth_sd = J(20,20, 0)

sort firm_id month

local metrics = " cum_drought_length"

***************************
** Sale Dummy in 2 Years **
***************************
forvalues ii = 1/20 {
	forvalues jj = 1/20 {
		qui sum F24.sale_dum if customer_growth_bin == `ii' & gpv_growth_bin == `jj'
		local ii = 21 - `ii'
		if "`r(mean)'" == "" {
			matrix mat_growth_mean[`ii' , `jj'] = .
		}
		else {
			matrix mat_growth_mean[`ii' , `jj'] = `r(mean)'
		}
		if "`r(sd)'" == "" {
			matrix mat_growth_sd[`ii' , `jj'] = .
		}
		else {
			matrix mat_growth_sd[`ii' , `jj'] = `r(sd)'
		}
	}
}

plotmatrix , mat(mat_growth_mean) maxticks(0) ///
	xtitle("Binned GPV Growth") ytitle("Binned Customer Growth") ///
	title("Probability of Sale in 2 year by binned GPV and Customer Growth") ///
	ylabel(-20 " ") name("saleprob_growth_heatmap") ///
	split(0(0.1)1)
graph export "`output'/customer_gpv_growth_saleprob_heatmap.eps", replace


***************************
** Sale Dummy in 2 Years **
***************************
forvalues ii = 1/20 {
	forvalues jj = 1/20 {
		qui sum F24.cum_drought_length if customer_growth_bin == `ii' & gpv_growth_bin == `jj'
		local ii = 21 - `ii'
		if "`r(mean)'" == "" {
			matrix mat_growth_mean[`ii' , `jj'] = .
		}
		else {
			matrix mat_growth_mean[`ii' , `jj'] = `r(mean)'
		}
		if "`r(sd)'" == "" {
			matrix mat_growth_sd[`ii' , `jj'] = .
		}
		else {
			matrix mat_growth_sd[`ii' , `jj'] = `r(sd)'
		}
	}
}

plotmatrix , mat(mat_growth_mean) maxticks(0) ///
	xtitle("Binned GPV Growth") ytitle("Binned Customer Growth") ///
	title("Drought Length in 2 year by binned GPV and Customer Growth") ///
	split(0(1)10) ylabel(-20 " ") name("drought_growth_heatmap")
graph export "`output'/customer_gpv_growth_drought_heatmap.eps", replace



*****************
** REGRESSIONS **
*****************
gen F24_sale_dum = F24.sale_dum
label variable F24_sale_dum "Future Sale Dummy"

eststo clear
eststo : logit F24_sale_dum log_gpv_per_cust, vce(cluster firm_id)
eststo : logit F24_sale_dum log_gpv log_gpv_per_cust, vce(cluster firm_id)
*eststo : logit F24.sale_dum log_gpv log_gpv_per_cust i.mcc, vce(cluster firm_id)

local save_file = "`output'/gpv_per_cust.tex"
esttab using "`save_file'", replace label se


eststo clear
eststo : logit F24_sale_dum customer_growth ,vce(cluster firm_id)
eststo : logit F24_sale_dum gpv_growth ,vce(cluster firm_id)
eststo : logit F24_sale_dum customer_growth gpv_growth ,vce(cluster firm_id)
eststo : logit F24_sale_dum gpv_per_cust_growth ,vce(cluster firm_id)

local save_file = "`output'/gpv_cust_growth.tex"
esttab using "`save_file'", replace label se

save "/tmp/tbd.dta", replace
*/
use "/tmp/tbd.dta"
eststo clear
eststo: logit F24.sale_dum log_gpv log_gpv_per_cust c.log_gpv_per_cust#i.mcc, vce(cluster firm_id)
eststo: reg F24.cum_drought_length log_gpv log_gpv_per_cust c.log_gpv_per_cust#i.mcc, vce(cluster firm_id)
local save_file = "`output'/tbd.csv"
esttab using "`save_file'", replace label not nostar







/*
reg F24.cum_drought_length log_gpv
predict drought_resids, residuals
reg log_gpv_per_cust log_gpv
predict gpv_per_cust_resids, residuals

reg drought_resids gpv_per_cust_resids

reg F24.cum_drought_length log_gpv log_gpv_per_cust

reg log_customers act_age
predict customer_resids, residuals
reg log_gpv_per_cust act_age
predict gpv_per_cust_resids, residuals

reg customer_resids gpv_per_cust_resids
reg log_customers log_gpv_per_cust act_age

sort firm_id month


*keep if first_month == 1
keep if inlist(mcc, 5734, 7372, 7392, 5691, 8999)



reg F12_state_length log_customers

reg F12_state_length log_customers log_gpv

reg F12_state_length log_customers log_gpv gpv_per_cust

reg F12_customer_growth log_customers log_gpv gpv_per_cust
reg F12_gpv_growth log_customers log_gpv gpv_per_cust

pretty_logscatter log_gpv customers , msize(tiny)
*/

* It really seems like the correlation between sales and previous sales is very small once the most
* recent month has been included. So really, if you know how it did last month, you almost surely
* know how it will do this month.

* logit F24.sale_dum log_gpv log_gpv_per_cust log_gpv_per_transaction c.log_transactions#c.log_gpv_per_transaction i.mcc, vce(cluster firm_id)

/*
reg F12_state_length F11_state_length F10_state_length F9_state_length F8_state_length F7_state_length F6_state_length F5_state_length F4_state_length F3_state_length F2_state_length F1_state_length cum_state_length

areg F24.sale_dum log_gpv_per_cust, absorb(mcc)
eststo: areg F24.sale_dum log_gpv log_gpv_per_cust, absorb(mcc)
eststo: areg F24.sale_dum log_gpv log_gpv_per_cust log_gpv_per_transaction c.log_transactions#c.log_gpv_per_transaction , absorb(mcc)
*/
