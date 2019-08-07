*******************************************************************************
** OVERVIEW
** Analyze probability of no sales in the
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../.."
include `base'/Code/Stata/file_header.do

** Setup Output folder for results
local yearsout_output = "`output'/YearsOut"
capture erasedir "`yearsout_output'"
mkdir "`yearsout_output'"

** Load in the Stripe Panel data
use "`main_panel'", clear

***********************************
** CREATE YEAR-OUT OUTCOMES DATA **
***********************************

sort firm_id month

gen year_out_drought = F12.cum_drought_length
gen two_year_out_drought = F24.cum_drought_length
gen three_year_out_drought = F36.cum_drought_length

gen year_out_1year_drought = 0
replace year_out_1year_drought =  1 if (year_out_drought >= 12)
replace year_out_1year_drought =  . if (year_out_drought == .)
gen two_year_out_2year_drought = 0
replace two_year_out_2year_drought =  1 if (two_year_out_drought >= 24)
replace two_year_out_2year_drought =  . if (two_year_out_drought == .)
gen three_year_out_3year_drought = 0
replace three_year_out_3year_drought =  1 if (three_year_out_drought >= 36)
replace three_year_out_3year_drought =  . if (three_year_out_drought == .)


******************************************
** PROBABILITIES BASED ON STATE HISTORY **
******************************************
preserve
sort cum_state_length

collapse (mean) year_out_1year_drought two_year_out_2year_drought ///
	three_year_out_3year_drought, by(cum_state_length)

scatter year_out_1year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Year") ///
	title("Probability of No Sales in the Next Year by History State") ///
	graphregion(color(white)) name("OneYearOut")


graph export "`yearsout_output'/NoSales_1year.eps", replace

scatter two_year_out_2year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Two Years") ///
	title("Probability of No Sales in the Next Two Years by History State") ///
	graphregion(color(white)) name("TwoYearsOut")

graph export "`yearsout_output'/NoSales_2year.eps", replace

scatter three_year_out_3year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Three Years") ///
	title("Probability of No Sales in the Next Three Years by History State") ///
	graphregion(color(white)) name("ThreeYearsOut") 

graph export "`yearsout_output'/NoSales_3year.eps", replace

save "`clean_stripe'/YearOutByHistory.dta", replace

restore

/*
**************************************************
** PROBABILITIES BASED ON STATE HISTORY AND AGE **
**************************************************
** preserve
sort cum_state_length act_age

collapse (mean) year_out_1year_drought two_year_out_2year_drought ///
	three_year_out_3year_drought, by(cum_state_length act_age)
graph3d act_age cum_state_length year_out_1year_drought, ///
	colorscheme(cr) xang(0) yang(0) zang(0) markeroptions(msize(.5)) ///
	xlab("age") ylab("state") zlab("Probability")

scatter year_out_1year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Year") ///
	title("Probability of No Sales in the Next Year by History State") ///
	graphregion(color(white))

graph export "`base'/Output/NoSales_1year.eps", replace

scatter two_year_out_2year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Two Years") ///
	title("Probability of No Sales in the Next Two Years by History State") ///
	graphregion(color(white))

graph export "`base'/Output/NoSales_2year.eps", replace

scatter three_year_out_3year_drought cum_state_length, msize(small) ///
	xlab(, grid) xtitle("History State") ///
	ylab(, grid) ytitle("Probability of No Sales in the Next Three Years") ///
	title("Probability of No Sales in the Next Three Years by History State") ///
	graphregion(color(white))

graph export "`base'/Output/NoSales_3year.eps", replace

save "`base'/Data/Clean/YearOutByHistory.dta", replace

** restore

	*/
