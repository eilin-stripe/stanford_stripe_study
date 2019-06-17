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

*use "`prediction_check'"
use "/Users/eilin/Documents/SIE/sta_files/round1.dta"

*keep if Finished == 1
keep if Finished == 2
// online-focused businesses
*keep if PercRevOnline >= 50

* weights
gen weight = 0.124 if strata == "funded"
replace weight = 1.831 if strata == "big"
replace weight = 1.236 if strata == "small"

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

gen Firmssurvey = 1
drop if Age == .
collapse (sum) Firmssurvey[w = weight] , by(Age)
*collapse (sum) Firmssurvey, by(Age)

egen totalfirmssurvey = total(Firmssurvey)
replace Firmssurvey = Firmssurvey / totalfirms

merge 1:1  Age using "`ase'"
replace Firmssurvey = - Firmssurvey

twoway (bar Firmssurvey Age, fcolor(purple) lcolor(white) lwidth(medium) horizontal barwidth(1)) (bar Firms Age, fcolor(dknavy) lcolor(white) ////
	lwidth(medium) horizontal barwidth(1)), ylabel(, labels angle(horizontal) valuelabel) 
	
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
