*******************************************************************************
** OVERVIEW
** Analyze what growth looks like in the dataset, using customers, gpv, and
** transactions to measure growth. The growth formula used is the DHS growth
** Formula described in the Reference Folder.
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do

** Setup Output folder for results
local growth_output = "`output'/Growth"
capture erasedir "`growth_output'"
mkdir "`growth_output'"

local data_vars = "firm_id month first_month total_customers cum_customers " ///
	+ "customer_growth gpv_growth transaction_growth act_age " ///
	+ "gpv_per_cust gpv_per_transaction trans_per_cust gpv_per_cust2 " ///
	+ "customers gpv transactions"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

** Only keep activated firms
drop if total_customers < 3

*******************************************************************************
** HISTOGRAMS OF CUMULATIVE # OF CUSTOMERS OVER TIME
*******************************************************************************

preserve

sort firm_id month

gen F12_cum_customers = F12.cum_customers
gen F24_cum_customers = F24.cum_customers
gen F36_cum_customers = F36.cum_customers

keep if first_month == 1

pretty_loghist F12_cum_customers, name("CumCustomersAfter1Year") ///
	xtitle("Total Customers") ///
	title("Histogram of Number of Customers within 12 Months of Activation") ///
	save("`growth_output'/Customers_hist_12.eps")


pretty_loghist F24_cum_customers, name("CumCustomersAfter2Years") ///
	xtitle("Total Customers") ///
	title("Histogram of Number of Customers within 24 Months of Activation") ///
	save("`growth_output'/Customers_hist_24.eps")


pretty_loghist F36_cum_customers, name("CumCustomersAfter3Years") ///
	xtitle("Total Customers") ///
	title("Histogram of Number of Customers within 36 Months of Activation") ///
	save("`growth_output'/Customers_hist_36.eps")

restore

*******************************************************************************
** GROWTH HISTOGRAMS
*******************************************************************************
hist customer_growth, width(.001) graphregion(color(white)) frac ///
	xtitle("Customer Growth") ///
	title("Monthly Customer Growth")
graph export "`growth_output'/hist_customer_growth.eps", replace

hist gpv_growth, width(.001) graphregion(color(white)) frac ///
	xtitle("GPV Growth") ///
	title("Monthly GPV Growth")
graph export "`growth_output'/hist_gpv_growth.eps", replace

hist transaction_growth, width(.001) graphregion(color(white)) frac ///
	xtitle("Transaction Count Growth") ///
	title("Monthly Transactions Growth")
graph export "`growth_output'/hist_trans_growth.eps", replace

*****************************
** AVERAGE GROWTH BY GROUP **
*****************************
sort act_age
egen age_tag = tag(act_age)

local metrics = "customer transaction gpv"

foreach metric of local metrics {
	* Create a capitalized version of the metric name for the graph output
	local capital_metric = strproper("`metric'")

	by act_age : egen avg_`metric'_growth_by_age = mean(`metric'_growth)
	by act_age : egen SD_`metric'_growth_by_age = sd(`metric'_growth)


	pretty_scatter avg_`metric'_growth_by_age act_age if age_tag, ///
		title("Average `capital_metric' Growth By Age") ///
		xtitle("Age (Months)") ytitle("Average `capital_metric' Growth") ///
		name("Avg`capital_metric'GrowthByAge") ///
		save("`growth_output'/Avg`capital_metric'GrowthByAge.eps")
}

gen dif = avg_customer_growth_by_age - avg_gpv_growth_by_age

pretty_scatter dif act_age if age_tag, ///
	title("Average dif Growth By Age") ///
	xtitle("Age (Months)") ytitle("Average dif Growth") ///
	name("dif") ///
	save("`growth_output'/dif.eps")

*******************************************
** STANDARD DEVIATION OF GROWTH BY GROUP **
*******************************************

* Age Groups

twoway (scatter SD_customer_growth_by_age act_age if age_tag == 1 & act_age <= 50, msize(small)) ///
	(scatter SD_transaction_growth_by_age act_age if age_tag == 1 & act_age <= 50, msize(small)) ///
	(scatter SD_gpv_growth_by_age act_age if age_tag == 1 & act_age <= 50, msize(small)), ///
	graphregion(color(white)) xtitle("Age") ///
	legend(label(1 "Customers") label(2 "Transactions") ///
	label(3 "GPV")) ytitle("Standard Deviation")  ///
	title("Std. Dev. of Monthly Growth by Age") ///
	scheme(s2personal)
graph export "`growth_output'/growth_std_by_age.eps", replace


* Customers
egen customer_rank = rank(customers), field
egen customer_cut = cut(customer_rank), group(50)
egen customer_cut_tag = tag(customer_cut)
sort customer_cut
by customer_cut : egen SD_customer_growth_by_cust = sd(customer_growth)
by customer_cut : egen mean_customers_by_cust = mean(customers)


pretty_logscatter SD_customer_growth_by_cust mean_customers_by_cust ///
	if customer_cut_tag == 1, ///
	xtitle("Number of Unique Customers") ytitle("Standard Deviation") ///
	title("Std. Dev. of Customer Growth by Number of Customers") ///
	name("CustGrowthDevByCustomers") ///
	save("`growth_output'/customer_growth_std.eps")


* GPV
egen gpv_rank = rank(gpv), field
egen gpv_cut = cut(gpv_rank), group(50)
egen gpv_cut_tag = tag(gpv_cut)
sort gpv_cut
by gpv_cut : egen SD_gpv_growth_by_gpv= sd(gpv_growth)
by gpv_cut : egen mean_gpv_by_gpv = mean(gpv)

pretty_logscatter SD_gpv_growth_by_gpv mean_gpv_by_gpv if gpv_cut_tag == 1, ///
	xtitle("GPV") ytitle("Standard Deviation") ///
	title("Std. Dev. of GPV Growth by GPV") ///
	name("GPVGrowthDevByGPV") ///
	save("`growth_output'/gpv_growth_std.eps")


* Transactions
egen transact_rank = rank(transactions), field
egen transact_cut = cut(transact_rank), group(50)
egen transact_cut_tag = tag(transact_cut)
sort transact_cut
by transact_cut : egen SD_transact_growth_by_transact= sd(transaction_growth)
by transact_cut : egen mean_transact_by_transact = mean(transactions)

pretty_logscatter SD_transact_growth_by_transact mean_transact_by_transact ///
	if transact_cut_tag == 1, ///
	xtitle("Number of Transactions") ytitle("Standard Deviation") ///
	title("Std. Dev. of Transaction Growth by Number of Transactions") ///
	name("TransGrowthDevByTrans") ///
	save("`growth_output'/trans_growth_std.eps")



ttest customer_growth == 0
ttest transaction_growth == 0
ttest gpv_growth == 0

pretty_hist act_age if max_month_flag == 1, discrete ///
	xtitle("Firm Age") title("Firm Age distribution, cross") ///
	save("`growth_output'/hist_firm_age_cross.eps")


/*
preserve
collapse (count) firm_id, by(month)
line firm_id month
restore
*/
