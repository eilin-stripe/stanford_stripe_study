*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/Stripe/Code/Stata/Clean/Survey/"
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

*/* Setup Paths
findbase "Stripe"
local base = r(base)
qui include `base'/Code/Stata/file_header.do

local in = "`raw_bds'/bds_f_age_release.csv"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"

local outdir = "`output'/NickLunch"*/

local in "/Users/eilin/Documents/SIE/02_clean_sample/bds_2014.dta"
*******************************************************************************
**
*******************************************************************************

import delimited "`in'", encoding(ISO-8859-1)clear

replace fage4 = regexr(fage4, "^[a-z]\) ", "")
replace fage4 = "26 to 40" if fage4 == "26+"
replace fage4 = "41+" if fage == "Left Censored"
label define BusAge 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6 to 10" ///
    7 "11 to 15" 8 "16 to 20" 9 "21 to 25" 10 "26 to 40" 11 "41+"

encode fage4, gen(FirmAge2) label(BusAge)

/*
twoway bar firms FirmAge2 , base(0) scheme(pretty1) xtitle("Firm Age") ///
    xlabel( 0(1)11, valuelabel angle(45)) ///
    name("BDSAge", replace)
graph export "`outdir'/BDSAge.eps", replace
*/

keep FirmAge2 firms
egen totalfirms = total(firms)
replace firms = firms / totalfirms

tempfile bds
save "`bds'"

*use "`prediction_check'"
use "/Users/eilin/Documents/SIE/sta_files/round1.dta"

*keep if Finished == 1
keep if Finished == 2

gen FirmAge = 2018 - FirstSaleYear
replace FirmAge = -777 if FirstSaleYear == -777
drop if FirstSaleYear == -777
gen FirmAge2 = FirmAge
replace FirmAge2 = 6 if inlist(FirmAge, 6, 7, 8, 9, 10)
replace FirmAge2 = 7 if inlist(FirmAge, 11, 12, 13, 14, 15)
replace FirmAge2 = 8 if inlist(FirmAge, 16, 17, 18, 19, 20)
replace FirmAge2 = 9 if inlist(FirmAge, 21, 22, 23, 24, 25)
replace FirmAge2 = 10 if FirmAge >= 26 & FirmAge <= 40
replace FirmAge2 = 11 if FirmAge >= 41 & FirmAge != .
replace FirmAge2 = . if FirmAge == .

label define BusAge 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6 to 10" ///
    7 "11 to 15" 8 "16 to 20" 9 "21 to 25" 10 "26 to 40" 11 "41+"

label values FirmAge2 BusAge

gen firmssurvey = 1

collapse (sum) firmssurvey, by(FirmAge2)

egen totalfirmssurvey = total(firmssurvey)
replace firmssurvey = firmssurvey / totalfirms

merge 1:1  FirmAge2 using "`bds'"
replace firmssurvey = - firmssurvey

generate zero = 0

twoway (bar firms FirmAge2 , horizontal) || ///
    (bar firmssurvey FirmAge2, horizontal) , ///
    scheme(pretty1) ylabel( 0(1)11, valuelabel) ///
    xlabel(-.2 ".2" -.1 ".1" 0 "0" .1 .2) ///
    legend(order(2 "Survey" 1 "BDS")  region(lwidth(none))) ///
    ytitle("Firm Age") 
graph rename FirmAgeComparison, replace
graph export "`outdir'/FirmAgeComparison.eps", replace

/*
replace firmssurvey = - firmssurvey
graph bar firms firmssurvey, over(FirmAge2, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/

* || (scatter FirmAge2 zero , mlabel(FirmAge2) mlabcolor(black) msymbol(i))
