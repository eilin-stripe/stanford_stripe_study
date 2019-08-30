*******************************************************************************
** 
** Founder charactersitics by gender
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
keep if Finished

rename External merchant_id
gen female=1 if Female==1
replace female=0 if Female==0

// College
// replace education=. if less than high school
replace Education=. if Education==1
gen college=1 if Education >=5 & !missing(Education)
replace college=0 if college==. & !missing(Education)

// number founders
replace NumFounders=. if NumFounders<0
gen cofounder=1 if NumFounders>1 & !missing(NumFounders)
replace cofounder=0 if NumFounders==1

// previous founding
replace PreviousBusiness=. if PreviousBusiness<0
gen prevbiz=1 if PreviousBusiness>1 & !missing(PreviousBusiness)
replace prevbiz=0 if PreviousBusiness==0

// stem degree
replace DegreeSTEM =. if DegreeSTEM <0

local i = 1
foreach var of varlist college Coding DegreeSTEM prevbiz cofounder OtherJobFlag{
	rename `var' char`i'
	local i = `i'+ 1
}

drop if female==.		// folks who do not enter gender


////////// WEIGHTED //////////

gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2

keep merchant_id female strata_int strata_wt char*

reshape long char, i(merchant_id) j(level)
drop if char==.

local varname char
local group1 level
local group2 female
collapse (mean) y = `varname' [pw= strata_wt], by(`group1' `group2')

gen outcomegroup=female if level==1
replace outcomegroup=female+3 if level==2
replace outcomegroup=female+6 if level==3
replace outcomegroup=female+9 if level==4
replace outcomegroup=female+12 if level==5
replace outcomegroup=female+15 if level==6
sort outcome

* value labels
label define charl 0 "College-educated" 3 "Coding-proficient" 6 "STEM degree" 9 "Founding experience" 12 "Has co-founder(s)" 15 "Other job"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor(black) lcolor(white)) (bar y outcomegroup if !female, fcolor("176 44 26") lcolor(white)) ///
	, ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall)) ylabel (0 (0.2) 1) ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) ///
	title(" ", size(medsmall))

/************************************************
**** All strata
************************************************
keep merchant_id female char*

reshape long char, i(merchant_id) j(level)
drop if char==.

local varname char
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
label define charl 0 "College-educated" 3 "Coding-proficient" 6 "STEM degree" 9 "Founding experience" 12 "Has co-founder(s)" 15 "Other job"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor(black) lcolor(white)) (bar y outcomegroup if !female, fcolor("176 44 26") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall)) ylabel (0 (0.2) 1) ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) ///
	title(" ", size(medsmall))
	

************************************************
**** Funded
************************************************
keep if Strata==2
keep merchant_id female char*

reshape long char, i(merchant_id) j(level)
drop if char==.

local varname char
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
label define charl 0 "College-educated" 3 "Coding-proficient" 6 "STEM degree" 9 "Founding experience" 12 "Has co-founder(s)" 15 "Other job"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar y outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall)) ylabel (0 (0.2) 1) ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) ///
	title("Funded firms", size(medsmall))

************************************************
**** Large
************************************************
keep if Strata==1
keep merchant_id female char*

reshape long char, i(merchant_id) j(level)
drop if char==.

local varname char
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
label define charl 0 "College-educated" 3 "Coding-proficient" 6 "STEM degree" 9 "Founding experience" 12 "Has co-founder(s)" 15 "Other job"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar y outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall)) ylabel (0 (0.2) 1) ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) ///
	title("Large firms", size(medsmall)) 
	
	
************************************************
**** Small
************************************************
keep if Strata==0
keep merchant_id female char*

reshape long char, i(merchant_id) j(level)
drop if char==.

local varname char
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
label define charl 0 "College-educated" 3 "Coding-proficient" 6 "STEM degree" 9 "Founding experience" 12 "Has co-founder(s)" 15 "Other job"
label values outcome charl

graph twoway (bar y outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar y outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction", size(small)) xtitle(" ") xlabel(0 (3) 16, valuelabel labsize(vsmall)) ylabel (0 (0.2) 1) ///
	graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "95% CI") rows(1) size(small)) ///
	title("Small firms", size(medsmall))
	
	
	
