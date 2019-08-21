*******************************************************************************
** 
** Motivation to start business by gender
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

cd "~/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local tables "07_Output"

use "`raw_dir'/Combined.dta", clear


gen female=1 if Female==1
replace female=0 if Female==0

rename ExternalReference merchant_id

// where do women work -- women are 8pp more likely to work from home, but not significant difference after controlling for firm type
gen home=1 if WorkLocation ==1
replace home=0 if WorkLocation != 1 & !missing(WorkLocation)
reg home i.female##i.Strata 

// motivation to start business

*replace missing values as 0
foreach var of varlist KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther KeyLifeChangingMoney{
	replace `var'=0 if `var'<0
}

* fraction by gender
*collapse (mean)KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther KeyLifeChangingMoney, by(female)

keep if !missing(female)

* reshape long
rename KeyBeBoss key1
rename KeyBestAvenue key2
rename KeyFlexible key3
rename KeyPositive key4
rename KeyEarnMore key5
rename KeyLifeChangingMoney key6

keep merchant_id female key*

reshape long key, i(merchant_id) j(level)
drop if key==.

local varname key
local group1 level
local group2 female
collapse (mean) y = `varname' (semean) se_y = `varname', by(`group1' `group2')

gen hiy=y+1.96*se
gen lowy=y-1.96*se

gen outcomegroup=female if level==1
replace outcomegroup=female+3 if level==2
replace outcomegroup=female+6 if level==3
replace outcomegroup=female+9 if level==4
replace outcomegroup=female+12 if level==5
replace outcomegroup=female+15 if level==6
sort outcome

* value labels
label define charl 0 "Own boss" 3 "Best avenue" 6 "Flexibility" 9 "Positive impact" 12 "Earn more" 15 "Life-changing money"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar y outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall))  ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) 
