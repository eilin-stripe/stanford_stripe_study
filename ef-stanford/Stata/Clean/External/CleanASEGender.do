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

local outdir = "`output'/NickLunch"
*******************************************************************************
**
*******************************************************************************
import delimited "`in'" , varnames(1) rowrange(3) encoding(ISO-8859-1)

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if inlist(asecbodisplaylabel, "Male", "Female")
drop asecboid

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep asecbodisplaylabel ownpdemp

rename asecbodisplaylabel FemaleTemp
encode FemaleTemp, gen(Female) label(Female)
drop FemaleTemp

rename ownpdemp Firms
destring Firms, replace

collapse (sum) Firms, by(Female)

tempfile ase
save "`ase'"

use "`prediction_check'"

keep if Finished == 1
keep if inlist(Female, 0 , 1)

gen Firms = 1
drop if Female == .
collapse (sum) Firms, by(Female)

append using "`ase'", gen(ASE)
label define ASE 0 "Survey" 1 "ASE"
label values ASE ASE

graph hbar [fw=Firms], over(Female) asyvars stack over(ASE) percent ///
    scheme(pretty1) ///
    legend( region(lwidth(none)) col(5) order(1 "Male" 2 "Female")) ///
    bar(1, color(eltblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(ebblue)) ///
    ytitle("")
graph rename GenderComparison, replace
graph export "`outdir'/GenderComparison.eps", replace

/*
replace Firmssurvey = - Firmssurvey
graph bar Firms Firmssurvey, over(Age, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/
