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

local in "/Users/eilin/Documents/SIE/02_clean_sample/BDS/bds_f_age_release.csv"
*******************************************************************************
**
*******************************************************************************

import delimited "`in'", encoding(ISO-8859-1)clear

replace fage4 = regexr(fage4, "^[a-z]\) ", "")
replace fage4 = "26 to 40" if fage4 == "26+"
replace fage4 = "41+" if fage == "Left Censored"

gen FirmAge2=1 if fage4=="0" | fage4=="1"
replace FirmAge2=2 if fage4=="2" | fage4=="3"| fage4=="4" | fage4=="5"
replace FirmAge2=3 if fage4=="6 to 10"
replace FirmAge2=4 if fage4=="11 to 15"
replace FirmAge2=5 if fage4=="16 to 20"
replace FirmAge2=6 if fage4=="21 to 25"
replace FirmAge2=7 if fage4=="26 to 40"
replace FirmAge2=8 if fage4=="41+"

label define BusAge 1 "0 to 1" 2 "2 to 5" 3 "6 to 10" ///
    4 "11 to 15" 5 "16 to 20" 6 "21 to 25" 7 "26 to 40" 8 "41+"
label values FirmAge2 BusAge
	
collapse firms, by (FirmAge2)


/*
twoway bar firms FirmAge2 , base(0) scheme(pretty1) xtitle("Firm Age") ///
    xlabel( 0(1)11, valuelabel angle(45)) ///
    name("BDSAge", replace)
graph export "`outdir'/BDSAge.eps", replace
*/

egen totalfirms = total(firms)
replace firms = firms / totalfirms

tempfile bds
save "`bds'"

// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/sta_files/Combined.dta", clear

gen FirmAge = 2018 - FirstSaleYear
replace FirmAge = -777 if FirstSaleYear == -777
drop if FirstSaleYear == -777
gen FirmAge2 = FirmAge
replace FirmAge2 = 1 if inlist(FirmAge, 0, 1)
replace FirmAge2 = 2 if inlist(FirmAge, 2, 3, 4, 5)
replace FirmAge2 = 3 if inlist(FirmAge, 6, 7, 8, 9, 10)
replace FirmAge2 = 4 if inlist(FirmAge, 11, 12, 13, 14, 15)
replace FirmAge2 = 5 if inlist(FirmAge, 16, 17, 18, 19, 20)
replace FirmAge2 = 6 if inlist(FirmAge, 21, 22, 23, 24, 25)
replace FirmAge2 = 7 if FirmAge >= 26 & FirmAge <= 40
replace FirmAge2 = 8 if FirmAge >= 41 & FirmAge != .
replace FirmAge2 = . if FirmAge == .

label values FirmAge2 BusAge

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.126 if strata_int==0
replace strata_wt=1.449 if strata_int==1
replace strata_wt=1.253 if strata_int==2

keep FirmAge2 strata_int strata_wt
bysort FirmAge2: gen stripe_firm_count_eq=sum(strata_wt)
bysort FirmAge2: replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (FirmAge2)
drop if FirmAge2==.

** ratio of firms by age
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio

*/ merge data
merge 1:1 FirmAge2 using `bds'
replace firms=-firms

graph hbar firms s_ratio, bar(1, fcolor("144 56 140")) bar(2, fcolor("68 65 130")) over(FirmAge, label(labsize(small))) bargap(-100) ///
	ylabel(-.4 (0.2) 0.4) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "All US firms") label(2 "Stripe firms")) ///
	title(Firm age, size(medsmall))


/*keep if Finished == 1
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
