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

//*rf
** Setup Paths
*//

//ef
** Setup Paths
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"


// read data
import delimited "`raw_dir'/r1_npv.csv", encoding(ISO-8859-1)clear

* change from cents to dollars
replace npv_monthly = npv_monthly/100
label variable npv_monthly "Monthly NPV ($)"
* replace negative npv=0
replace npv_monthly=0 if npv_monthly<0

////	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)

// 18h1 npv
local jan18 = 21185
local jun18 = 21336
bysort merchant (timestamp): gen npv_18h1 = sum(npv_monthly) if ndate >= `jan18' & ndate<=`jun18'
bysort merchant (timestamp): replace npv_18h1 = npv_18h1[_n-1] if missing(npv_18h1)
bysort merchant (timestamp): replace npv_18h1 = npv_18h1[_N] 
bysort merchant (timestamp): replace npv_18h1 = . if _n != 1

//19h1
local jan19 = 21550
local jun19 = 21701
bysort merchant (timestamp): gen npv_19h1 = sum(npv_monthly) if ndate >= `jan19' & ndate<=`jun19'
bysort merchant (timestamp): replace npv_19h1 = npv_19h1[_n-1] if missing(npv_19h1)
bysort merchant (timestamp): replace npv_19h1 = npv_19h1[_N] 
bysort merchant (timestamp): replace npv_19h1 = . if _n != 1

gen growth_h1 = ln(npv_19h1/npv_18h1)
gen dhs_h1 = (npv_19h1-npv_18h1)/(0.5*(npv_19h1+ npv_18h1))

// growth histogram
histogram growth_h1, fraction fcolor(dkgreen) fintensity(90) lcolor(white) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))

// average growth rates
gen raw_growth = npv_19h1/npv_18h1


// retain first obs and save dta file
bysort merchant: keep if _n==1
save "`clean_dir'/growth.dta", replace

