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

local in = "`raw_ase'/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"

local outdir = "`output'/NickLunch"*/

* ef
cd "/Users/eilin/Documents/SIE"
local in "02_clean_sample/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv"
*******************************************************************************
**
*******************************************************************************
import delimited "`in'" , varnames(1) rowrange(3) encoding(ISO-8859-1)

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if asecbodisplaylabel == "All owners of respondent firms"
drop ase*

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep ownragedisplaylabel ownpdemp

rename ownragedisplaylabel AgeTemp
replace AgeTemp = regexr(AgeTemp, "Under", "<")
replace AgeTemp = regexr(AgeTemp, "or over", "+")
drop if AgeTemp == "Total reporting"
drop if AgeTemp == "Item not reported"

label define Age 0 "< 25" 1 "25 to 34" 2 "35 to 44" 3 "45 to 54" ///
    4 "55 to 64" 5 "65 +"
encode AgeTemp, gen(Age) label(Age)
drop AgeTemp

rename ownpdemp Firms
destring Firms, replace

egen totalfirms = total(Firms)
replace Firms = Firms / totalfirms

tempfile ase
save "`ase'"

/*use "`prediction_check'"
use "/Users/eilin/Documents/SIE/sta_files/round1.dta"

*keep if Finished == 1
keep if Finished == 2
// online-focused businesses
*keep if PercRevOnline >= 50

gen Firmssurvey = 1
drop if Age == .
collapse (sum) Firmssurvey[w = weight] , by(Age)
*collapse (sum) Firmssurvey, by(Age)

egen totalfirmssurvey = total(Firmssurvey)
replace Firmssurvey = Firmssurvey / totalfirms

merge 1:1  Age using "`ase'"
replace Firmssurvey = - Firmssurvey

twoway (bar Firms Age , horizontal) || ///
    (bar Firmssurvey Age, horizontal) , ///
    scheme(pretty1) ylabel( 0(1)5, valuelabel) ///
    xlabel(-.4 ".4" -.2 ".2" 0 "0" .2 .4) ///
    legend(order(2 "Survey" 1 "ASE")  region(lwidth(none))) ///
    ytitle("Age")
graph rename OwnerAgeComparison, replace
graph export "`outdir'/OwnerAgeComparison.eps", replace

/*
replace Firmssurvey = - Firmssurvey
graph bar Firms Firmssurvey, over(Age, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/
*/



// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/sta_files/Combined.dta", clear

rename Age AgeTemp
gen Age = .
replace Age = 0 if AgeTemp < 25
replace Age = 1 if AgeTemp >= 25 & AgeTemp <= 34
replace Age = 2 if AgeTemp >= 35 & AgeTemp <= 44
replace Age = 3 if AgeTemp >= 45 & AgeTemp <= 54
replace Age = 4 if AgeTemp >= 55 & AgeTemp <= 64
replace Age = 5 if AgeTemp >= 65 & AgeTemp != .

label define Age 0 "< 25" 1 "25 to 34" 2 "35 to 44" 3 "45 to 54" ///
    4 "55 to 64" 5 "65 +"

label values Age Age

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.126 if strata_int==0
replace strata_wt=1.449 if strata_int==1
replace strata_wt=1.253 if strata_int==2

keep Age strata_int strata_wt
bysort Age: gen stripe_firm_count_eq=sum(strata_wt)
bysort Age: replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (Age)
drop if Age==.

** ratio of firms by age
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio

// merge data
merge 1:1 Age using `ase'
replace Firms=-Firms

graph hbar Firms s_ratio, bar(1, fcolor("144 56 140")) bar(2, fcolor("68 65 130")) over(Age, label(labsize(small))) bargap(-100) ///
	ylabel(-.4 (0.2) 0.4) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "All US firms") label(2 "Stripe firms")) title(Founder age, size(medsmall))

