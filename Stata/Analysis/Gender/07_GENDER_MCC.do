*******************************************************************************
** 
** industry
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


// using weights to pool across groups
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.133 if strata_int==0
replace strata_wt=1.447 if strata_int==1
replace strata_wt=1.160 if strata_int==2

svyset, clear
svyset merchant_id [pweight=strata_wt], strata(strata_int)


tempfile x
save `x'

* merge with Stripe industry classification
import delimited "`raw_dir'/11_mcc.csv", encoding(ISO-8859-1) clear

merge 1:1 merchant_id using `x'
keep if _merge==3
drop _merge

* encode industry
sort label__industry__primary_vertica
encode label__industry__primary_vertica, gen (industry)

* aggregate industry
*replace indus_agg=11 if industry==13
*replace indus_agg=4 if industry==4
gen indus_agg=1 if industry==9 | industry == 10
replace indus_agg=2 if industry==11 | industry == 18
replace indus_agg=3 if industry==14
replace indus_agg=4 if industry==6 | industry==17
replace indus_agg=5 if industry==8
replace indus_agg=6 if industry==12 | industry==21
replace indus_agg=7 if industry==5
replace indus_agg=8 if industry==3
replace indus_agg=9 if industry==2
replace indus_agg=10 if industry==1
replace indus_agg=11 if industry==15

drop if female>1


keep strata_int strata_wt female indus_agg


* count firm equivalents by gender and numfounders
bysort female indus_agg: egen count = total(strata_wt)

* collapse to retain one obs per firm-num
collapse (max)count, by (female indus_agg)

egen _percent = pc(count), by(female)
separate _percent, by(female)

gen indusagg0 = indus_agg - 0.2
gen indusagg1 = indus_agg + 0.2

twoway bar _percent0 indusagg0, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 indusagg1, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(0.8 "Retail & Services" 1.8 "Software" 2.8 "Fashion" ///
	3.8 "Healthcare" 4.8 "Non-profit" 5.8 "Professional services" 6.8 "Food & beverage" 7.8 "Education" 8.8 "Direct services" 9.8 "Content" ///
	10.8 "Tickets (events)", valuelabel labsize(vsmall) angle(forty_five)) xtitle( ) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))


/*/ INDUSTRY & STARTING CAPITAL
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
svy: reg `var' i.female
}

// are women more likely to start in certain sectors
tabulate indus_agg, generate(i)

foreach var of varlist i1 i2 i3 i4 i5 i6 i7 i8 i9 i10 i11{
	svy: reg `var' i.female
}

foreach var of varlist i1 i2 i3 i4 i5 i6 i7 i8 i9 i10 i11{
	svy: reg start100k `var' i.female
}

foreach var of varlist i1 i2 i3 i4 i5 i6 i7 i8 i9 i10 i11{
	svy: reg start100k `var'
}


// industry histogram by gender

contract female indus_agg if !missing(female, indus_agg)
egen _percent = pc(_freq), by(female)
separate _percent, by(female)
gen indus_agg0=indus_agg-0.2
gen indus_agg1=indus_agg+0.2

	
twoway bar _percent0 indus_agg0 if  _percent0 > 1, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) || bar _percent1 indus_agg1 if  _percent0 > 1, ///
	barw(0.4) fcolor(black) lcolor(white) ytitle(Percent, size(small)) ylabel(, labsize(small)) xlabel(0.8 "Retail & Services" 1.8 "Software" 2.8 "Fashion" ///
	3.8 "Healthcare" 4.8 "Non-profit" 5.8 "Professional services" 6.8 "Food & beverage" 7.8 "Education" 8.8 "Direct services" 9.8 "Content" ///
	10.8 "Tickets (events)", valuelabel labsize(vsmall) angle(forty_five)) ylabel(, labsize(vsmall)) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))

	
