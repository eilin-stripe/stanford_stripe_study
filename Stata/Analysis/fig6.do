********************************************************************************
						*** FIGURE 6 ***
********************************************************************************

** 

********************************************************************************
** SETUP
********************************************************************************

cd "~/Documents/SIE"
local raw_dir "01_raw_data/"
local clean_dir "sta_files/"
local tables "07_Output/"

use "`clean_dir'round1_dp.dta", clear

* first year of sale on Stripe
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"

* indicator for first user observation
bysort merchant_id (year month): gen n = _n

twoway (histogram FirstSaleYear, discrete percent fcolor(teal) fintensity(85) lcolor(white)) (histogram FirstHireYear, discrete percent fcolor(none) lcolor(black)) if FirstSaleYear > 1967 & n == 1 &FirstHireYear > 1967, xlabel(1968(10)2018) legend(order(1 "First year of sale" 2 "First Stripe transaction")) graphregion(fcolor(white) ifcolor(white))
