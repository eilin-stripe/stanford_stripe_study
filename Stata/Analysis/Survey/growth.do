** growth


*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data and generates dhs growth rates for q1 
** and mean mom growth in 2018
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

** strata indicator
gen strata_int = 0 if strata == "funded"
replace strata_int = 1 if strata == "big"
replace strata_int = 2 if strata =="small"
label define strata_l 0 "Funded" 1 "Large" 2 "Small"
label values strata_int strata_l

** multiplying qualtrics entry by 1000
foreach var of varlist Bad3Months Predict3Months Good3Months{
	replace `var' = `var' * 1000
}

**** firm age indicator
gen firm_age = 2019 - FirstCostYear if n == 1
label variable firm_age "Firm age"
gen firm_age2 = firm_age * firm_age

//// who is growing?
reg dhs_q i.strata_int if firm_age < 15, robust
outreg2 using /Users/eilin/Documents/SIE/07_Output/growth_strata, replace ctitle (OLS 1)

reg dhs_q i.strata_int i.strata_int##c.firm_age firm_age2 if firm_age < 15, robust
outreg2 using /Users/eilin/Documents/SIE/07_Output/growth_strata.tex, append ctitle (OLS 2)

reg dhs_q i.strata_int i.strata_int##c.firm_age firm_age2 female HoursPerWeek PercRevInternational StartingFunding NumEmployees if firm_age < 15, robust
outreg2 using /Users/eilin/Documents/SIE/07_Output/growth_strata.tex, append ctitle (OLS 3)

margins  i.strata_int, at(firm_age=(1(1)20))
marginsplot

gen ln_dhs = ln(dhs_q) 
localp ln_dhs firm_age, gen(mean_ln_dhs) 
gen gmean_dhs = exp(mean_ln_dhs) 
line gmean firm_age, sort

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

** april 2019 completion
local a1 = date("2019-04-01", "YMD")
local a2 = date("2019-05-01", "YMD")
local a3 = date("2019-05-01", "YMD")
local a4 = date("2018-04-01", "YMD")
local a5 = date("2018-05-01", "YMD")
local a6 = date("2018-06-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-03-30" & (ndate == `a1' | ndate == `a2' | ndate == `a3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-04-01" & EndDateTemp <= "2019-04-30")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18= sum(npv_monthly) if EndDateTemp <= "2019-04-30" & (ndate == `a4' | ndate == `a5' | ndate == `a6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_N]
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-04-01" & EndDateTemp <= "2019-04-30")
drop actual3m_18temp

** may 2019 completion
local my1 = date("2019-05-01", "YMD")
local my2 = date("2019-06-01", "YMD")
local my3 = date("2019-07-01", "YMD")
local my4 = date("2018-05-01", "YMD")
local my5 = date("2018-06-01", "YMD")
local my6 = date("2018-07-01", "YMD")

bysort merchant_id (year month): replace actual3months = sum(npv_monthly) if EndDateTemp <= "2019-05-31" & (ndate == `my1' | ndate == `my2' | ndate == `my3')
bysort merchant_id (year month): gen actual3m_temp = actual3months if !missing(actual3months)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3months) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (year month): replace actual3months = actual3m_temp if _n == 1 & (EndDateTemp >= "2019-05-31" & EndDateTemp <= "2019-05-31")
drop actual3m_temp

bysort merchant_id (year month): replace actual3months_18= sum(npv_monthly) if EndDateTemp <= "2019-05-31" & (ndate == `my4' | ndate == `my5' | ndate == `my6')
bysort merchant_id (year month): gen actual3m_18temp = actual3months_18 if !missing(actual3months_18)
bysort merchant_id (year month): replace actual3m_18temp = actual3m_18temp[_n - 1] if missing(actual3months_18) & _n > 1
bysort merchant_id (year month): replace actual3months_18 = actual3m_18temp if _n == 1 & (EndDateTemp >= "2019-05-31" & EndDateTemp <= "2019-05-31")


bysort merchant_id (year month): replace actual3months = . if _n != 1 
bysort merchant_id (year month): replace actual3months_18 = . if _n != 1 




*** percent revenue online
bysort merchant: gen n = _n

gen revonline50 = 1 if PercRevOnline >= 50 & n == 1
replace revonline50 = 0 if PercRevOnline < 50 & n == 1
