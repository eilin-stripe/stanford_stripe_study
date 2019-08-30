*******************************************************************************
** 
** Hours worked by gender
*******************************************************************************



*******************************************************************************
** SETUP
*******************************************************************************

// ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"
local external "02_clean_sample"

// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/01_raw_data/Combined.dta", clear

* clean
keep if Progress==100			// keep completed surveys
rename Female female
drop if female>1

* hours variable
replace HoursPerWeek = 100 if HoursPerWeek>100 & !missing(HoursPerWeek)
gen hours=1 if HoursPerWeek<=19
replace hours=2 if HoursPerWeek>19 & HoursPerWeek<=39
replace hours=3 if HoursPerWeek>39 & HoursPerWeek<=49
replace hours=4 if HoursPerWeek>49 & HoursPerWeek<=69
replace hours=5 if HoursPerWeek>69 & !missing(HoursPerWeek)


////////// WEIGHTED //////////

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2


keep strata_int strata_wt female hours

* count firm equivalents by gender and numfounders
bysort female hours: egen count = total(strata_wt)

* collapse to retain one obs per firm-num
collapse (max)count, by (female hours)

egen _percent = pc(count), by(female)
separate _percent, by(female)

gen hours0 = hours- 0.2
gen hours1 = hours+ 0.2

* histogram
twoway bar _percent0 hours0, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 hours1, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(1 "<=19" 2 "20-39" 3 "40-49" 4 "50-69" 5 ">=70", valuelabel) xtitle(Hours per week) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))


/*/ histogram
contract female hours if !missing(female, hours)
egen _percent = pc(_freq), by(female)
separate _percent, by(female)

gen hours0 = hours- 0.2
gen hours1 = hours+ 0.2

* histogram
twoway bar _percent0 hours0, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 hours1, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(1 "<=19" 2 "20-39" 3 "40-49" 4 "50-69" 5 ">=70", valuelabel) xtitle(Hours per week) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))
