*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data and generates prediction categories  
** 
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************

set more off
clear

** Setup Paths
/*rf

*/

*ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
*/

// read data
use "`clean_dir'/round1_dp.dta", clear

** merge survey data
merge m:1 merchant_id using "`clean_dir'/round1.dta"
keep if _merge == 3			//_merge == 2 for non-completed surveys
drop _merge 

//// indicator for first obs
bysort merchant_id: gen n = 1 if _n == 1

** multiplying qualtrics entry by 1000
foreach var of varlist Predict3Months Bad3Months Good3Months{
	replace `var' = `var' * 1000
}

// enter strata for round 1.1 and 1.2
egen npv_18 = rowtotal(npv_18q1 npv_18q2 npv_18q3 npv_18q4)
replace strata = "big" if strata == "" & npv_18 >= 10000
replace strata = "small" if strata == "" & npv_18 < 10000
drop npv_18
merge m:1 merchant_id using "`clean_dir'/earlyr1_strata.dta"
replace strata = "funded" if label__is_funded == "true"
drop label__is_funded label__is_funded_by_tier1_vc


** for january 2019 survey completion
local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
local j3 = date("2019-03-01", "YMD")
local j4 = date("2018-01-01", "YMD")
local j5 = date("2018-02-01", "YMD")
local j6 = date("2018-03-01", "YMD")

bysort merchant_id (year month): gen actual3months = sum(npv_monthly) if EndDateTemp <= "2019-01-31" & (ndate == `j1' | ndate == `j2' | ndate == `j3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >="2019-01-01" & EndDateTemp <= "2019-01-31")
drop actual3m_temp

bysort merchant_id (year month): gen actual3months_18 = sum(npv_monthly) if EndDateTemp <= "2019-01-31" & (ndate == `j4' | ndate == `j5' | ndate == `j6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >="2019-01-01" & EndDateTemp <= "2019-01-31")
drop actual3m_18temp


** february 2019 completion
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")
local f4 = date("2018-02-01", "YMD")
local f5 = date("2018-03-01", "YMD")
loca f6 = date("2018-04-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-02-28" & (ndate == `f1' | ndate == `f2' | ndate == `f3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-02-01" & EndDateTemp <= "2019-02-28")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18 = sum(npv_monthly) if EndDateTemp <= "2019-02-28" & (ndate == `f4' | ndate == `f5' | ndate == `f6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-02-01" & EndDateTemp <= "2019-02-28")
drop actual3m_18temp


** march 2019 completion
local m1 = date("2019-03-01", "YMD")
local m2 = date("2019-04-01", "YMD")
local m3 = date("2019-05-01", "YMD")
local m4 = date("2018-03-01", "YMD")
local m5 = date("2018-04-01", "YMD")
local m6 = date("2018-05-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-03-31" & (ndate == `m1' | ndate == `m2' | ndate == `m3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-03-01" & EndDateTemp <= "2019-03-31")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18= sum(npv_monthly) if EndDateTemp <= "2019-03-31" & (ndate == `m4' | ndate == `m5' | ndate == `m6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-03-01" & EndDateTemp <= "2019-03-31")
drop actual3m_18temp

bysort merchant_id (year month): replace actual3months = . if _n != 1 

gen predict_cat = 5 if actual3months <= Bad3Months & actual3months != .
replace predict_cat = 4 if actual3months > Bad3Months & actual3months <= 0.9*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 3 if actual3months >= 0.9*Predict3Months & actual3months <= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 2 if actual3months >= 1.1*Predict3Months & n == 1 & actual3months != .
replace predict_cat = 1 if actual3months >= Good3Months & n == 1 & actual3months != .
// replace predict_cat to missing for those who did not make a prediction
replace predict_cat = . if Predict3Months == .
//replace predict_cat to 3 for those who had a revenue of 0 and predicted both expected and worst case to be 0
replace predict_cat = 3 if actual3months == 0 & Predict3Months == 0 & Good3Months == 0

* prediction histogram
*histogram predict_cat, discrete fraction fcolor(lavender) lcolor(white) ymtick(, labels valuelabel) xmtick(, labels valuelabel) graphregion(fcolor(white) ifcolor(white)


// WHAT EXPLAINS PREDICTION
* 8. variance in trans count?
merge m:1 merchant_id using "`clean_dir'/trans_count.dta"
replace trans_count = . if n != 1
replace trans_annual = . if n != 1
replace trans_count = 0 if _merge == 1  & n==1
replace trans_annual = 0 if _merge == 1  & n==1
gen trans_mean = 1 if trans_annual > 75 & n==1
replace trans_mean = 0 if trans_annual <= 75 & n==1


* 1. firm type? smaller firms seem to over-predict
gen strata_int = 0 if strata == "funded"
replace strata_int = 1 if strata == "big"
replace strata_int = 2 if strata =="small"
label define strata_l 0 "Funded" 1 "Large" 2 "Small"
label values strata_int strata_l
catplot predict_cat strata_int, percent(strata_int)stack asyvars  bar(1, bcolor(64 168 205)) bar(2, bcolor(0 139 188)) bar(3, bcolor(0 111 150)) bar(4, bcolor(07 100 200 )) bar(5, bcolor(02 0 102)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

* 2. previous. business ownership? no
catplot predict_cat PreviousBusinesses, percent(PreviousBusinesses) stack asyvars
//yes-no indicator
gen founding_exp = 1 if PreviousBusinesses >= 2 & n == 1 // PreviousBusinesses starts set at 1
replace founding_exp = 0 if PreviousBusinesses == 1 & n == 1

* 3. percent revenue online? no
catplot predict_cat CatPercRevOnline, percent(CatPercRevOnline)stack asyvars  bar(1, bcolor(64 168 205)) bar(2, bcolor(0 139 188)) bar(3, bcolor(0 111 150)) bar(4, bcolor(07 100 200 )) bar(5, bcolor(02 0 102)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

* 4. One founder? no
gen founder_one = 1 if NumFounders == 1 & n == 1
replace founder_one = 0 if NumFounders > 1 & n == 1
catplot predict_cat founder_one, percent(founder_one) stack asyvars

* 5. international revenue share? no
gen intll_rev_share = 1 if PercRevInternational > 8.7 & n == 1
replace intll_rev_share = 0 if PercRevInternational <= 8.7 & n == 1
catplot predict_cat intll_rev_share, percent(intll_rev_share)stack asyvars  bar(1, bcolor(64 168 205)) bar(2, bcolor(0 139 188)) bar(3, bcolor(0 111 150)) bar(4, bcolor(07 100 200 )) bar(5, bcolor(02 0 102)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

* 6. growth from 18q4 to 19q1?
gen dhs_l1 = (npv_19q1 - npv_18q4)/(0.5* (npv_19q1 + npv_18q4))
gen dhs_l1_cat = 0 if dhs_l1 < 0 & n == 1
replace dhs_l1_cat = 1 if dhs_l1 >= 0 & n == 1

* 7. growth from 18q1 to 19q1
gen dhs_q_cat = 0 if dhs_q < 0 & n == 1
replace dhs_q_cat = 1 if dhs_q > 0 & n == 1

* 8. firm age
gen firm_age = 2019 - FirstCostYear if n == 1
label variable firm_age "Firm age"
gen firm_age2 = firm_age * firm_age

* 9. growth from 18q3 to 18q4?
gen dhs_q1_1718_cat = 0 if dhs_q1_1718 =< 0 & !missing(dhs_q1_1718)
replace dhs_q1_1718_cat = 1 if dhs_q1_1718 > 0 & !missing(dhs_q1_1718)
catplot predict_cat dhs_q1_1718_cat, percent(dhs_q1_1718_cat)stack asyvars  bar(1, bcolor(64 168 205)) bar(2, bcolor(0 139 188)) bar(3, bcolor(0 111 150)) bar(4, bcolor(07 100 200 )) bar(5, bcolor(02 0 102)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

