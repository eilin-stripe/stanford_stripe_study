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

local data_vars = "firm_id month customers gpv transactions mcc act_age cum_drought_length sale_dum cum_customers freq*"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

keep if mcc == 5734

sort firm_id
by firm_id: egen max_age = max(act_age)

keep if max_age >= 12

sort firm_id month
gen L_customers = L.customers
gen L_sale_dum = L.sale_dum
gen L2_sale_dum = L2.sale_dum
gen L3_sale_dum = L3.sale_dum
gen customer_growth = (D.customers / (0.5 * (customers + L_customers)))
gen log_cust = log(customers + 1)
gen L_log_cust = L.log_cust
replace freq_refunds = 0 if freq_refunds == .
replace freq_disputes = 0 if freq_disputes == .
replace freq_declines = 0 if freq_declines == .
gen log_freq_refunds = log(freq_refunds+ 1)
gen log_freq_disputes = log(freq_disputes + 1)
gen log_freq_declines = log(freq_declines + 1)
gen L_log_refunds = L.log_freq_refunds
gen L_log_declines = L.log_freq_declines
gen L_log_disputes = L.log_freq_disputes

zinb customers L_log_cust log_freq_refunds if act_age == 12 & max_age >= 12, inflate(L_log_cust log_freq_refunds)
zinb customers L_log_cust log_freq_declines if act_age == 12 & max_age >= 12, inflate(L_log_cust log_freq_declines)
zinb customers L_log_cust log_freq_disputes if act_age == 12 & max_age >= 12, inflate(L_log_cust log_freq_disputes)

zinb customers L_log_cust L_log_refunds if act_age == 12 & max_age >= 12, inflate(L_log_cust L_log_refunds)
zinb customers L_log_cust L_log_declines if act_age == 12 & max_age >= 12, inflate(L_log_cust L_log_declines)
zinb customers L_log_cust L_log_disputes if act_age == 12 & max_age >= 12, inflate(L_log_cust L_log_disputes)
