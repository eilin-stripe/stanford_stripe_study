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

local data_vars = "firm_id month customers gpv transactions mcc act_age cum_drought_length sale_dum cum_customers"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

keep if mcc == 5734

sort firm_id
by firm_id: egen max_age = max(act_age)

keep if max_age >= 12
*******************************************************************************
** Customer Hist
*******************************************************************************

pretty (hist customers if act_age == 12, zeros(1) xlogbase(1.2)), ///
    title("Histogram of Customers in Month 12") name("CustomerHist12") ///
    save("`output'/CustomerHist12.eps") ///
    xtitle("Customers (log scale)")

sort firm_id month
gen L_customers = L.customers
gen L_sale_dum = L.sale_dum
gen L2_sale_dum = L2.sale_dum
gen L3_sale_dum = L3.sale_dum
gen customer_growth = (D.customers / (0.5 * (customers + L_customers)))
gen log_cust = log(customers + 1)
gen L_log_cust = L.log_cust

*******************************************************************************
** 12 Months Growth Hist
*******************************************************************************

twoway (hist customer_growth if act_age == 12 , frac start(-2.05) width(.1)) , ///
    title("Histogram of DHS Customer Growth in Month 12") ///
    name("CustomerGrowthHist12", replace) xtitle("DHS Customer Growth") ///
    scheme(pretty1)
graph export "`output'/CustomerGrowthHist12.eps", replace

*******************************************************************************
** ZINB Table
*******************************************************************************

eststo clear
eststo: zinb customers L_log_cust if act_age == 12 & max_age >= 12 , ///
    inflate(L_log_cust)
estadd local N "." , replace
margin , predict(pr)
matrix est = r(table)
local dead_est_zinb  = est[1, 1]

eststo: zinb customers L_log_cust if act_age == 12 & max_age >= 12 , ///
    inflate(L_log_cust L_sale_dum L2_sale_dum L3_sale_dum)
estadd local N "." , replace
local save_file = "`output'/zinb.tex"
esttab using "`save_file'", replace style(tex) ///
    varlabels(L_log_cust "\$Ln(Cust_{t-1})\$" _cons "Cons" ///
    L_sale_dum "\$SaleDum_{t-1}\$" L2_sale_dum "\$SaleDum_{t-2}\$" ///
    L3_sale_dum "\$SaleDum_{t-3}\$" ) ///
    s(N, label("Observations")) ///
    substitute(\_ _) mtitles("Customers" "Customers") ///
    starlevels(* 0.1 ** 0.05 *** 0.01)

keep if act_age == 12
sort customers
gen rank = _n
drop if rank <= `dead_est_zinb'*_N
pretty (hist customers if act_age == 12, zeros(1) xlogbase(1.2)), ///
    title("Histogram of Customers in Month 12") name("CustomerAltHist12") ///
    save("`output'/CustomerAltHist12.eps") ///
    xtitle("Customers (log scale)")

eststo clear
rename cum_customers TotalCustomers
rename customers Customers
estpost tabstat Customers TotalCustomers, statistics(p10 p25 p50 p75 p90 )  columns(variables)
esttab using "`output'/Percentiles12.tex", replace nonum noobs cells("Customers TotalCustomers")

*******************************************************************************
