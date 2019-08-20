*******************************************************************************
** 
** Gender for blog post / public dissemination
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
rename KeyFlexible key2
rename KeyEarnMore key3
rename KeyLifeChangingMoney key4
rename KeyBestAvenue key5
rename KeyPositive key6
rename KeyLearning key7
rename KeyOther key8

* regressions
reg key2 i.Strata##i.Female
reg key6 i.Strata##i.Female
reg key4 i.Strata##i.Female

keep merchant_id female key*
reshape long key, i(merchant_id) j(level)

* histograms with ci
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
replace outcomegroup=female+18 if level==7
replace outcomegroup=female+21 if level==8
sort outcome

* value labels
label define keyl 0 "Own boss" 3 "Flexibility" 6 "Earn More" 9 "Life changing money" 12 "Best avenue" 15 "Positive impact" 18 "Learning" 21 "Other"
label values outcomegroup keyl

graph twoway (bar y outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar y outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 21, valuelabel labsize(vsmall)) graphregion(fcolor(white) /// 
	ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "CI") rows(1) size(small))
