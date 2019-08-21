*******************************************************************************
** 
** Gender and starting capital
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

// source of startup capital

*replace msising capital to 0
foreach var of varlist SourcesPersonalSavings SourcesInvestor SourcesBankLoan SourcesCredit SourcesGovLoan SourcesOther SourcesNone {
	replace `var'=0 if `var'<0
}

* regression by strata and gender
foreach var of varlist SourcesPersonalSavings SourcesInvestor SourcesBankLoan SourcesCredit SourcesGovLoan SourcesOther SourcesNone {
	reg `var' i.Female##i.Strata, robust
}

// do women start smaller firms?
// among funded firms, 45.8% of male founders start with > 100k, whereas 34.85 of female founders start with >100k


* change startup capital to missing if not founder and if starting funding reported == NA
replace StartingFunding =. if FounderFlag == 0
replace StartingFunding =. if StartingFunding < 0

gen start5=1 if StartingFunding == 1 | StartingFunding == 2
replace start5=2 if StartingFunding == 3 | StartingFunding == 4
replace start5=3 if StartingFunding == 5 | StartingFunding == 6
replace start5=4 if StartingFunding >6 & !missing(StartingFunding)

* Regression check

gen start5k=1 if StartingFunding == 1 | StartingFunding == 2
replace start5k=0 if  StartingFunding > 2 & !missing(StartingFunding)

gen start25k=1 if StartingFunding == 3 | StartingFunding == 4
replace start25k=0 if  StartingFunding > 4 & !missing(StartingFunding)

gen start99k=1 if StartingFunding == 5 | StartingFunding == 6
replace start99k=0 if  StartingFunding > 6 & !missing(StartingFunding)

gen start100k=1 if StartingFunding >6 & !missing(StartingFunding)
replace start100k=0 if Starting	<=6

foreach var of varlist start5k start25k start99k start100k{
reg `var' i.female##i.Strata, robust
}


* contract by gender and capital level
contract female start5 if !missing(female, start5)
egen _percent = pc(_freq), by(female)
separate _percent, by(female)

gen start50 = start5- 0.2
gen start51 = start5+ 0.2

* histogram
twoway bar _percent0 start50, base(0) barw(0.4) fcolor("133 155 241") lcolor(white) ///
	|| bar _percent1 start51, barw(0.4) fcolor("2 115 104") lcolor(white) ytitle(Percent) ///
	xlabel(1 "< 5k" 2 "5 - 25k" 3 "25 - 100k" 4 "> 100k", valuelabel) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Male") ///
	label (2 "Female") rows(1))



