set more off
clear


local base = "../../.."
use "`base'/Data/Clean/FirmCharacteristics.dta", clear

***************************
** Create SUMMARY GRAPHS **
***************************

hist log_last_28_gpv, graphregion(color(white)) ///
	xtitle("Log Gross Payment Volume, Past 28 Days") ///
	title("Histogram of Log Gross Payment Volume, Past 28 Days")
graph export "`base'/Output/hist_last28.eps", replace

hist log_last_90_gpv, graphregion(color(white)) ///
	xtitle("Log Gross Payment Volume, Past 90 Days") ///
	title("Histogram of Log Gross Payment Volume, Past 90 Days")
graph export "`base'/Output/hist_last90.eps", replace

hist log_cum_npv, graphregion(color(white)) /// 
	xtitle("Log Net Present Value") ///
	title("Log Net Present Value of All Past Transactions")
graph export "`base'/Output/hist_npv.eps", replace

hist log_cum_tran, graphregion(color(white)) /// 
	xtitle("Log Transactions") ///
	title("Log Cummulative Transactions to Date")
graph export "`base'/Output/hist_tran.eps", replace



/*
gen num_firms = 1
collapse (count) num_firms, by(state)
save state_count_temp.dta, replace

mmerge state using "`base'/Data/Raw/state_index.dta", umatch(stusab) _merge(match)
keep if match == 3
drop match

*/
