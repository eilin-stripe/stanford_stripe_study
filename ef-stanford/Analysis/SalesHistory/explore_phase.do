
set more off
clear
set matsize 10000
// set graphics off


** Setup
local base = "../../.."
local num_per = 40
use "`base'/Data/Clean/PanelActivated.dta", replace



sort firm_id month
foreach x of num 1/40 {
	gen F`x'_drought_length = F`x'.cum_drought_length
	gen F`x'_sale_length = F`x'.cum_sale_length
	gen F`x'_state_length = F`x'.cum_state_length
}

keep if first_month == 1

// gen state_tag = .
/*
foreach x of num 1/40 {

	twoway (hist F`x'_state_length if F`x'_state_length < 0, ///
		discrete freq fcolor(red) lcolor(cranberry)) ///
		(hist F`x'_state_length if F`x'_state_length > 0, ///
		discrete freq fcolor(ebblue) lcolor(blue)), ///
		ylab(, grid) ytitle("Number of Firms") ///
		xlab(, grid) title("History States at `x' months after activation ") ///
		graphregion(color(white)) xtitle("History State") ///
		legend(label(1 "Drought") label(2 "Sale Streak"))
	graph export "`base'/Output/State/State_hist_`x'.eps", replace



    qui mmerge F`x'_state_length using "`base'/Data/Clean/YearOutByHistory.dta", type(n:1) umatch(cum_state_length) unmatched(master)
	drop state_tag
	egen state_tag = tag(F`x'_state_length)
	twoway (hist F`x'_state_length if F`x'_state_length < 0, ///
		discrete freq fcolor(red) lcolor(cranberry) yaxis(1)) ///
		(hist F`x'_state_length if F`x'_state_length > 0, ///
		discrete freq fcolor(ebblue) lcolor(blue) yaxis(1)) ///
		(scatter year_out_1year_drought F`x'_state_length ///
		if state_tag == 1 & F`x'_state_length <= `x' + 1 & ///
		F`x'_state_length >= -`x', ///
		yaxis(2) yscale(range(0 1) axis(2)) msize(small) color(black)), ///
		ylab(, grid) ytitle("Number of Firms") ///
		xlab(, grid) title("History States at `x' months after activation ") ///
		graphregion(color(white)) xtitle("History State") ///
		legend(label(1 "Drought") label(2 "Sale Streak") ///
			label(3 "Probability of No Sales in Following Year"))
	graph export "`base'/Output/State/State_hist_prob_`x'.eps", replace

	drop year_out_1year_drought two_year_out_2year_drought ///
		three_year_out_3year_drought
}
*/

qui unique state
local num_state = `r(sum)' - 1
qui unique mcc
local num_ind = `r(sum)' - 1
matrix All = J(`num_per',2, 0)
matrix State = J(`num_per'*`num_state',2, 0)
matrix Ind = J(`num_per'*`num_ind',2, 0)
matrix colnames All = "mat_month" "mat_fail"
local counter_state = 1
local counter_ind = 1

foreach x of num 1/`num_per' {
	disp "`x'"
    qui mmerge F`x'_state_length using "`base'/Data/Clean/YearOutByHistory.dta", type(n:1) umatch(cum_state_length) unmatched(master)


	qui sum year_out_1year_drought
	local fail_p = `r(mean)'
	matrix All[`x' ,1] = `x'
	matrix All[`x' ,2] = `fail_p'


	qui levelsof state, local(levels)
	foreach s of local levels {
		qui sum year_out_1year_drought if state == "`s'"
		if `r(N)' == 0 {
			local fail_p = -99
		}
		else {
			local fail_p = `r(mean)'
		}
		matrix State[`counter_state' ,1] = `x'
		matrix State[`counter_state' ,2] = `fail_p'
		matrcrename State row `counter_state' `s'
		local ++counter_state
	}

	qui levelsof mcc, local(levels)
	foreach i of local levels {
		qui sum year_out_1year_drought if mcc == `i'
		if `r(N)' == 0 {
			local fail_p = -99
		}
		else {
			local fail_p = `r(mean)'
		}
		matrix Ind[`counter_ind' ,1] = `x'
		matrix Ind[`counter_ind' ,2] = `fail_p'
		matrcrename Ind row `counter_ind' `i'
		local ++counter_ind
	}

	drop year_out_1year_drought two_year_out_2year_drought ///
		three_year_out_3year_drought
}

save temp_exit.dta, replace
*/
* svmat All
local base = "../../.."
scatter All2 All1, 	graphregion(color(white)) xtitle("Age") ///
	ytitle("Probability of No Sales in Following Year")  ///
	title("Probability of No Sales in the Following Year by Age")  msize(small)

graph export "`base'/Output/Prob_out_all.eps", replace

* svmat2 State, rnames(state_gr)
scatter State2 State1 if state_gr == "CA"

* svmat2 Ind, rnames(ind_gr)
*/
twoway (scatter Ind2 Ind1 if ind_gr == "5734", msize(small)) ///
	(scatter Ind2 Ind1 if ind_gr == "7372", msize(small)) ///
	(scatter Ind2 Ind1 if ind_gr == "7392", msize(small)) ///
	(scatter Ind2 Ind1 if ind_gr == "5691", msize(small)), ///
	graphregion(color(white)) xtitle("Age")   ///
	legend(label(1 "Computer Software Stores") label(2 "Computer Programming") ///
		label(3 "Consulting, Public Relations") label(4 "Clothing Stores")) ///
	ytitle("Probability of No Sales in Following Year")  ///
	title("Probability of No Sales in the Following Year by Age")

graph export "`base'/Output/Prob_out_ind.eps", replace
/*
egen state_tag = tag(state)
egen ind_tag = tag(mcc)
gen first_tag = 0
replace first_tag = 1 if _n == 1

bys state: gen state_size = _N
bys mcc: gen ind_size = _N
*/

	/*

	cumul year_out_1year_drought, gen(year_out_1year_drought_cum)
	sort year_out_1year_drought_cum
	line year_out_1year_drought_cum year_out_1year_drought, ylab(, grid) ytitle("") ///
		xlab(, grid) title("CDF for Length of Drought `x' months after activation") ///
		graphregion(color(white)) xtitle("Drought Length")
	graph export "`base'/Output/YearOut/YearOut_cdf_`x'.eps", replace



	drop year_out_1year_drought_cum
	*/




















/*
foreach x of num 1/40 {
	cumul F`x'_sale_length, gen(F`x'_sale_cum)
	sort F`x'_sale_cum
	line F`x'_sale_cum F`x'_sale_length, ylab(, grid) ytitle("") ///
		xlab(, grid) title("CDF for Lengths of Sales Streaks `x' Months After Activation") ///
		graphregion(color(white)) xtitle("Streak of Months with Positive Sales")
	graph export "`base'/Output/SaleStreak/SalesStreak_cdf_`x'.eps", replace

	cumul F`x'_drought_length, gen(F`x'_drought_cum)
	sort F`x'_drought_cum
	line F`x'_drought_cum F`x'_drought_length, ylab(, grid) ytitle("") ///
		xlab(, grid) title("CDF for Length of Drought `x' months after activation") ///
		graphregion(color(white)) xtitle("Drought Length")
	graph export "`base'/Output/DroughtStreak/Drought_cdf_`x'.eps", replace

	cumul F`x'_state_length, gen(F`x'_state_cum)
	sort F`x'_state_cum
	twoway (line F`x'_state_cum F`x'_state_length if F`x'_state_length >= -1, lcolor(blue)) ///
		(line F`x'_state_cum F`x'_state_length if F`x'_state_length < 0, lcolor(red)) ///
		, ylab(, grid) ytitle("") ///
		xlab(, grid) title("CDF for History `x' months after activation") ///
		graphregion(color(white)) xtitle("Drought Length") ///
		legend(label(1 "Drought") label(2 "Sale Streak"))
	graph export "`base'/Output/State/State_cdf_`x'.eps", replace

	/*
	qui mmerge F`x'_state_length using "`base'/Data/Clean/YearOutByHistory.dta", umatch(cum_state_length)

	cumul year_out_1year_drought, gen(year_out_1year_drought_cum)
	sort year_out_1year_drought_cum
	line year_out_1year_drought_cum year_out_1year_drought, ylab(, grid) ytitle("") ///
		xlab(, grid) title("CDF for Length of Drought `x' months after activation") ///
		graphregion(color(white)) xtitle("Drought Length")
	graph export "`base'/Output/YearOut/YearOut_cdf_`x'.eps", replace


	drop year_out_1year_drought two_year_out_2year_drought ///
		three_year_out_3year_drought
	drop year_out_1year_drought_cum
	*/
}
*/



/*
levelsof firm_id if fixed_drought_length > 20, local(levels)

foreach look in `levels' {
	levelsof irs_description  if firm_id == `look', local(merc)
	disp `merc'

	twoway (line customers  month if firm_id == `look' )  (line activated month if firm_id == `look' )

	// graph export "`base'/Output/Droughts/customers_`look'.eps", replace
}
*/
