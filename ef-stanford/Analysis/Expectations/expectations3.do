******************************************************************************
				*** Growth rate forecasts ***
******************************************************************************	

* calculates YoY forecasted growth rates

******************************************************************************	
* setup
******************************************************************************	

// ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"

*read data
use "`clean_dir'/round1.dta", clear

// revenue on Stripe in past 12 month
foreach var of varlist RevPast12Months Predict12Months{
replace `var' = `var'*1000
}

* clean percent rev stripe
replace PercRevStripe=PercRevStripe*100 if (PercRevStripe>0 & PercRevStripe<1)
replace PercRevStripe=100 if PercRevStripe>100

* replace online rev=stripe rev if stripe > online
replace PercRevOnline=PercRevStripe if PercRevStripe>PercRevOnline

gen rev_past12_stripe=RevPast12Months*(PercRevStripe/100)
label variable rev_past12 "Stripe revenue (past 12 months)"

// growth rate forecasts
gen growth_12months_stripe=(Predict12Months-rev_past12_stripe)/(0.5*(Predict12Months+rev_past12_stripe))
winsor2 growth_12months_stripe, suffix(_w) cuts(5 95)
label variable growth_12months_stripe "Annual growth forecast (winsorized)"

twoway (histogram growth_12months_stripe_w, fraction fcolor(dkgreen) lcolor(white)), xtitle("") graphregion(fcolor(white) ifcolor(white))
