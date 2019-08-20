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


// do women start smaller firms?
// among funded firms, 45.8% of male founders start with > 100k, whereas 34.85 of female founders start with >100k


* change startup capital to missing if not founder and if starting funding reported == NA
replace StartingFunding =. if FounderFlag == 0
replace StartingFunding =. if StartingFunding < 0

gen start5=1 if StartingFunding == 1 | StartingFunding == 2
replace start5=0 if StartingFunding>2 & !missing(StartingFunding)
gen start25=1 if StartingFunding == 3 | StartingFunding == 4
replace start25=0 if StartingFunding>4 & !missing(StartingFunding)
gen start50=1 if StartingFunding == 5
replace start50=0 if StartingFunding>5 & !missing(StartingFunding)
gen start99=1 if StartingFunding == 6
replace start99=0 if StartingFunding>6 & !missing(StartingFunding)
gen start100=1 if StartingFunding >6 & !missing(StartingFunding)
replace start100=0 if missing(start100) & !missing(StartingFunding)

preserve
* collapse at finding category to create mean, sd and n
collapse (mean) mean5= start5 (sd) sd5= start5 (count) n5= start5 ///
	(mean) mean25= start25 (sd) sd25= start25 (count) n25= start25 ///
	(mean) mean50= start50 (sd) sd50= start50 (count) n50= start50 ///
	(mean) mean99= start99 (sd) sd99= start99 (count) n99= start99 ///
	(mean) mean100= start100 (sd) sd100= start100 (count) n100= start100, by(female)
	
* drop no gender
drop if missing(female)

* confidence interval
foreach num of numlist 5 25 50 99 100{
	generate hi`num' = mean`num' + invttail(n`num'-1,0.025)*(sd`num' / sqrt(n`num'))
	generate lo`num' = mean`num' - invttail(n`num'-1,0.025)*(sd`num' / sqrt(n`num'))
}

* drop sd and n
drop sd5 n5 sd25 n25 sd50 n50 sd99 n99 sd100 n100
reshape long mean hi lo, i(female) j(level)

gen outcomegroup=female if level==5
replace outcomegroup=female+3 if level==25
replace outcomegroup=female+6 if level==50
replace outcomegroup=female+9 if level==99
replace outcomegroup=female+12 if level==100
sort outcome

* label funding levels
label define start5l 0 "< 5k" 3 "5 - 25k" 6 "25 - 50k" 9 "50 - 100k" 12 "> 100k"
label values outcomegroup start5l

* histogram
graph twoway (bar mean outcomegroup if female, fcolor("133 155 241") lcolor(white)) (bar mean outcomegroup if !female, fcolor("2 115 104") lcolor(white)) ///
	(rcap hi lo outcomegroup), ytitle("Fraction") xtitle("Starting capital ($)") xlabel(0 (3) 12, valuelabel) graphregion(fcolor(white) /// 
	ifcolor(white)) legend(label(1 "Female") label (2 "Male") label(3 "CI") rows(1))

restore
	
* check histogram result with regression
foreach var of varlist start5 start25 start50 start99 start100{
	reg `var' i.Strata##i.female, robust
}

