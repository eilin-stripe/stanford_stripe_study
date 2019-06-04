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

** Setup Paths
findbase "Stripe"
local base = r(base)
qui include `base'/Code/Stata/file_header.do

local in = "`raw_ase'/ASE_2016_PriorBus/ASE_2016_00CSCBO06.csv"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"

local outdir = "`output'/NickLunch"
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

keep numpriorbusdisplaylabel ownpdemp

rename numpriorbusdisplaylabel PriorBusTemp
replace PriorBusTemp = regexr(PriorBusTemp, " businesse?s? prior .*", "")
replace PriorBusTemp = regexr(PriorBusTemp, "Owner\(s\) previously owned ", "")
replace PriorBusTemp = regexr(PriorBusTemp, "Owner\(s\) did not previously own another", "0")
replace PriorBusTemp = regexr(PriorBusTemp, " or more", "+")
drop if PriorBusTemp == "Total reporting"
drop if PriorBusTemp == "Item not reported"

encode PriorBusTemp, gen(PreviousBusinesses) label(PreviousBusinesses)
drop PriorBusTemp

rename ownpdemp Firms
destring Firms, replace

egen totalfirms = total(Firms)
replace Firms = Firms / totalfirms

tempfile ase
save "`ase'"

use "`prediction_check'"

keep if Finished == 1
drop if PreviousBusinesses == -777

gen Firmssurvey = 1
drop if PreviousBusinesses == .
collapse (sum) Firmssurvey, by(PreviousBusinesses)

egen totalfirmssurvey = total(Firmssurvey)
replace Firmssurvey = Firmssurvey / totalfirms

merge 1:1  PreviousBusinesses using "`ase'"
replace Firmssurvey = - Firmssurvey

twoway (bar Firms PreviousBusinesses , horizontal) || ///
    (bar Firmssurvey PreviousBusinesses, horizontal) , ///
    scheme(pretty1) ylabel( 0(1)5, valuelabel) ///
    xlabel(-.75 ".75" -.5 ".5" -.25 ".25" 0 "0" .25 .5 .75) ///
    legend(order(2 "Survey" 1 "ASE")  region(lwidth(none))) ///
    ytitle("Previous Businesses")
graph rename PreviousBusinessesComparison, replace
graph export "`outdir'/PreviousBusinessesComparison.eps", replace

/*
replace Firmssurvey = - Firmssurvey
graph bar Firms Firmssurvey, over(Age, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/
