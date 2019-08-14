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

*read Combined data
use "`clean_dir'/Combined.dta", clear

keep Actual3Months Predict3Months Bad3Months Good3Months ExternalReference Predict12Months Bad12Months Good12Months EndDate RevPast12Months ///
	Predict12Months PercRevOnline PercRevStripe Strata Progress
rename ExternalReference merchant_id
tempfile x
save `x'

// read npv data
import delimited "`raw_dir'/r1_npv.csv", encoding(ISO-8859-1)clear
merge m:1 merchant_id using `x'
drop _merge
bysort merchant_id (timestamp): gen n=_n

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
gen growth_12months_stripe=(Predict12Months-rev_past12_stripe)/(0.5*(Predict12Months+rev_past12_stripe))  if n==1

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.126 if strata_int==0
replace strata_wt=1.449 if strata_int==1
replace strata_wt=1.253 if strata_int==2

// Stripe founders expected growth rate=14.33%
mean growth_12months_stripe [pweight= strata_wt]

// creating fweights from pweights
gen double wt=round(strata_wt*100)

// histogram with pweights
twoway (histogram growth_12months_stripe [fw=wt], fraction fcolor(dkgreen) lcolor(white)), xtitle("") graphregion(fcolor(white) ifcolor(white))

** winsorize long tail
winsor2 growth_12months_stripe, suffix(_w) cuts(5 95)
label variable growth_12months_stripe "Annual growth forecast (winsorized)"
twoway (histogram growth_12months_stripe_w [fw=wt], fraction fcolor(dkgreen) lcolor(white)), xtitle("") graphregion(fcolor(white) ifcolor(white))

// winsorizing does not make the graph look much better, so dropping values of growth==-2
twoway (histogram growth_12months_stripe [fw=wt] if growth_12months_stripe>-2, fraction fcolor(dkgreen) lcolor(white)), xtitle("") ///
	graphregion(fcolor(white) ifcolor(white))


* save merge forcasted growth with previous growth
keep merchant_id Progress Predict12Months rev_past12_stripe growth_12months_stripe strata_int strata_wt wt
tempfile x
save `x'

******************************************************************************	
* Growth from 2017q2 to 2018q2
******************************************************************************

cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"

import delimited "`raw_dir'/r1_npv.csv", encoding(ISO-8859-1)clear

// change from cents 
replace npv_monthly = npv_monthly/100
label variable npv_monthly "NPV in month m ($)"

* date
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)")
destring year month day, replace
gen ndate =mdy(month, day, year)


* 2017 q2 rev
local apr17 = date("2017-04-01", "YMD")
local may17 = date("2017-05-01", "YMD")
local jun17 = date("2017-06-01", "YMD")
bysort merchant_id (timestamp): gen npv_17q2 = sum(npv_monthly) if ndate>=`apr17' & ndate <= `jun17'

* 2018 q2
local apr18 = date("2018-04-01", "YMD")
local may18 = date("2018-05-01", "YMD")
local jun18 = date("2018-06-01", "YMD")
bysort merchant_id (timestamp): gen npv_18q2 = sum(npv_monthly) if ndate>=`apr18' & ndate <= `jun18'

foreach var of varlist npv_17q2 npv_18q2{
	bysort merchant_id (timestamp): replace `var' = `var'[_n-1] if missing(`var')
	bysort merchant_id (timestamp): replace `var' = `var'[_N]
	bysort merchant_id (timestamp): replace `var' = . if _n != 1
	replace `var' = 0 if `var'<0
}

** growth q2 17-18
gen growth_12m_1718q2 = (npv_18q2-npv_17q2)/(0.5*(npv_18q2+npv_17q2))


* merge with forecast
merge m:1 merchant_id using `x'

// average growth q2 17-18 is 20.12%
mean growth_12m_1718q2 [pweight= strata_wt] if growth_12m_1718q2 != 2
