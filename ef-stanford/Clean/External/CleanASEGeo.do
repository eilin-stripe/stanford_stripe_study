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

local in = "`raw_ase'/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local demographics = "`clean_internal'/Demographics.dta"

local responsedatacsv = "`clean_conversion'/ResponseData.csv"
local responsedata = "`clean_conversion'/ResponseData.dta"

local ziptostate = "`clean_geo'/ZipToState.dta"

local outdir = "`output'/NickLunch"

*******************************************************************************
**
*******************************************************************************
import delimited "`in'" , varnames(1) rowrange(3) encoding(ISO-8859-1)

keep if asecbodisplaylabel == "All owners of respondent firms"
drop asecboid

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

drop if geoid == "0100000US"
keep if strlen(geoid2) < 3
drop geoid geoid2 geoannotationid

drop naics*

keep geodisplaylabel ownpdemp

rename geodisplaylabel State

mmerge State using "`tiger'/state.dta", ///
	type(n:1) umatch(NAME) ///
    unmatched(master) ukeep(_ID STATEFP REGION DIVISION STUSPS)
drop _merge
rename STATEFP StateFP
rename REGION Region
rename DIVISION Division
destring *, replace

label define Division 1 "New England" 2 "Middle Atlantic" ///
    3 "East North Central" 4 "West North Central" 5 "South Atlantic" ///
     6 "East South Central" 7 "West South Central" 8 "Mountain" ///
     9 "Pacific"

label values Division Division

rename ownpdemp Firms
destring Firms, replace

collapse (sum) Firms, by(Division)

egen totalfirms= total(Firms)
replace Firms = Firms / totalfirms

tempfile ase
save "`ase'"

use "`prediction_check'"

merge 1:1 ExternalReference  using "`demographics'"
drop _merge
keep if Finished == 1

merge n:1 Zipcode using "`ziptostate'"
keep if _merge == 3

mmerge State using "`tiger'/state.dta", ///
	type(n:1) umatch(STATEFP) ///
    unmatched(master) ukeep(_ID NAME REGION DIVISION STUSPS)

drop _merge
rename REGION Region
rename DIVISION Division
destring *, replace

label define Division 1 "New England" 2 "Middle Atlantic" ///
    3 "East North Central" 4 "West North Central" 5 "South Atlantic" ///
     6 "East South Central" 7 "West South Central" 8 "Mountain" ///
     9 "Pacific"

label values Division Division

gen Firmssurvey = 1
collapse (sum) Firmssurvey, by(Division)

egen totalfirmssurvey = total(Firmssurvey)
replace Firmssurvey = Firmssurvey / totalfirms

merge 1:1  Division using "`ase'"
replace Firmssurvey = - Firmssurvey

twoway (bar Firms Division , horizontal) || ///
    (bar Firmssurvey Division, horizontal) , ///
    scheme(pretty1) ylabel( 1(1)9, valuelabel) ///
    xlabel(-.25 ".25" -.2 ".2" -.15 ".15" -.1 ".1" -.05 ".05" 0 "0" ///
        .05 .1 .15 .2 .25) ///
    legend(order(2 "Survey" 1 "ASE")  region(lwidth(none))) ///
    ytitle("Geographic Region")
graph rename GeoComparison, replace
graph export "`outdir'/GeoComparison.eps", replace

/*
replace Firmssurvey = - Firmssurvey
graph bar Firms Firmssurvey, over(Age, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/
