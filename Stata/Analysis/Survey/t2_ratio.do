********************************************************************************
						*** TABLE 1 ***
********************************************************************************

** Entry cleaning logic + sum stats

********************************************************************************
** SETUP
********************************************************************************

cd "~/Documents/SIE"
local raw_dir "01_raw_data/"
local clean_dir "sta_files/"
local tables "07_Output/"

use "`clean_dir'round1_dp.dta", clear

////	keep finished surveys & strata
drop if Finished == 1
gen strata_int = 0 if strata == "funded"
replace strata_int = 1 if strata == "big"
replace strata_int = 2 if strata =="small"


////	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)
** first observation of user
bysort merchant (year month): gen n = _n


////	female indicator
gen female = 1 if Female == 1
replace female = 0 if Female != 1 & Female != .
label variable female "Female"
label define fem_l 0 "Not female" 1 "Female" 
label values female fem_l

gen female_int = 2 if female == 0
replace female_int = 1 if female == 1
label variable female_int "Female=1 notfemale=2"
label define female_l2 1 "Female" 2 "Not female"
label values female_int female_l2


// changing negative npv; first pass
replace npv__monthly = 0 if npv__monthly < 0 
bysort merchant_id (year month): gen num = npv__monthly - npv__monthly[_n - 1]
bysort merchant_id (year month): gen den = 0.5 * (npv__monthly + npv__monthly[_n - 1])
gen dhs = num/den


// keep surveys completed by feb 28, 2019
gen enddate = date(EndDateTemp,"YMD")
local l = date("2019-02-28", "YMD")
gen round = 1 if enddate <= `l'


** for january 2019 survey completion
local j = date("2019-01-31", "YMD")
local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
loca j3 = date("2019-03-01", "YMD")

bysort merchant_id (year month): gen actual3months = sum(npv__monthly) if enddate <= `j' & (ndate == `j1' | ndate == `j2' | ndate == `j3')

bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & enddate <= `j'
drop actual3m_temp


** february 2019 completion
local f = date("2019-02-28", "YMD")
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv__monthly) if enddate <= `f' & (ndate == `f1' | ndate == `f2' | ndate == `f3')

bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & enddate <= `f'
drop actual3m_temp

// scale prediction & check
replace Predict3Months = Predict3Months*1000
gen ratio = Predict3Months/actual3months if n == 1

* cap ratio at 100x
replace ratio = 50 if ratio > 50 & !missing(ratio)


** keep round 1
keep if round == 1 

** t2-f1
gen prediction = 1 if ratio < 0.5
replace prediction = 2 if ratio >= 0.5 & ratio < 0.9
replace prediction = 3 if ratio >= 0.9 & ratio <= 1.1
replace prediction = 4 if ratio > 1.1 & ratio < 2
replace prediction = 5 if ratio >= 3
catplot prediction female_int if n == 1, percent(female_int)stack asyvars bar(1, bcolor(orange*0.35)) bar(2, bcolor(erose*0.7)) bar(3, bcolor(red*0.6)) bar(4, bcolor(teal*0.6)) bar(5, bcolor(lavender*0.35)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

