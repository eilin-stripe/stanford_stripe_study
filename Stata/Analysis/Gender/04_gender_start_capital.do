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
drop if female > 1

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2

// svyset
svyset, clear
svyset ExternalReference [pweight=strata_wt], strata(strata_int)


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


* change startup capital to missing if not founder
* change starting funding = <1000 if founder and startingfunding==na 
replace StartingFunding=. if StartingFunding < 0 & FounderFlag == 0
replace StartingFunding=1 if StartingFunding < 0 & FounderFlag == 1

gen start5=1 if StartingFunding == 1 | StartingFunding == 2
replace start5=2 if StartingFunding == 3 
replace start5=3 if StartingFunding == 4 | StartingFunding == 5
replace start5=4 if StartingFunding >= 6 & !missing(StartingFunding)

////////// WEIGHTED //////////

keep strata_int strata_wt female start5

* count firm equivalents by gender and numfounders
bysort female start5: egen count = total(strata_wt)

* collapse to retain one obs per firm-num
collapse (max)count, by (female start5)

egen _percent = pc(count), by(female)
separate _percent, by(female)

gen start50 = start5 - 0.2
gen start51 = start5 + 0.2

twoway bar _percent0 start50, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 start51, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(1 "< 5k" 2 "5 - 10k" 3 "10 - 50k" 4 "> 50k", valuelabel) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Male") ///
	label (2 "Female") rows(1))



/* Regression check

gen start5k=1 if StartingFunding == 1 | StartingFunding == 2
replace start5k=0 if  StartingFunding > 2 & !missing(StartingFunding)

gen start25k=1 if StartingFunding == 3 | StartingFunding == 4
replace start25k=0 if  StartingFunding > 4 & !missing(StartingFunding)

gen start99k=1 if StartingFunding == 5 | StartingFunding == 6
replace start99k=0 if  StartingFunding > 6 & !missing(StartingFunding)

gen start100k=1 if StartingFunding >6 & !missing(StartingFunding)
replace start100k=0 if Starting	<=6

foreach var of varlist start5k start25k start99k start100k{
svy: reg `var' i.female
}


//contract by gender and capital level
contract female start5 if !missing(female, start5)
egen _percent = pc(_freq), by(female)
separate _percent, by(female)

gen start50 = start5- 0.2
gen start51 = start5+ 0.2

* histogram
twoway bar _percent0 start50, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 start51, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(1 "< 5k" 2 "5 - 25k" 3 "25 - 100k" 4 "> 100k", valuelabel) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "Male") ///
	label (2 "Female") rows(1))

	
// do observable characteristics explain difference in funding

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

foreach var of varlist start5k start25k start99k start100k{
svy: reg `var' i.female college Coding DegreeSTEM prevbiz cofounder OtherJobFlag
}

///////////// motivation

*replace missing values as 0
foreach var of varlist KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther KeyLifeChangingMoney{
	replace `var'=0 if `var'<0
}

* fraction by gender
*collapse (mean)KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther KeyLifeChangingMoney, by(female)

keep if !missing(female)


foreach var of varlist start5k start25k start99k start100k{
svy: reg `var' KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyLifeChangingMoney
}

foreach var of varlist start5k start25k start99k start100k{
svy: reg `var' i.female KeyBeBoss KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyLifeChangingMoney
}
