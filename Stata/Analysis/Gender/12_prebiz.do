*******************************************************************************
** 
** Cofounders by gender
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

replace PreviousBusiness=. if PreviousBusiness<0
drop if PreviousBusiness==.

gen prevbiz=1 if PreviousBusiness==0
replace prevbiz=2 if PreviousBusiness==1 | PreviousBusiness==2
replace prevbiz=3 if PreviousBusiness==3 | PreviousBusiness==4
replace prevbiz=4 if PreviousBusiness==5

/*/ histogram
contract female PreviousBusiness if !missing(female, PreviousBusiness)
egen _percent = pc(_freq), by(female)
separate _percent, by(female)

gen prevbiz0 = PreviousBusiness- 0.2
gen prevbiz1 = PreviousBusiness+ 0.2

* histogram
twoway bar _percent0 prevbiz0, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 prevbiz1, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(0.8 "1" 1.8 "2" 2.8 "3" 3.8 "4" 4.8 "5+", valuelabel) xtitle(Previous businesses founded) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))

*/
////////// WEIGHTED //////////

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2

keep strata_int strata_wt female PreviousBusiness

* count firm equivalents by gender and numfounders
bysort female PreviousBusiness: egen count = total(strata_wt)

* collapse to retain one obs per firm-num
collapse (max)count, by (female PreviousBusiness)

egen _percent = pc(count), by(female)
separate _percent, by(female)

gen prevbiz0 = PreviousBusiness - 0.2
gen prevbiz1 = PreviousBusiness + 0.2

twoway bar _percent0 prevbiz0, base(0) barw(0.4) fcolor("176 44 26") lcolor(white) ///
	|| bar _percent1 prevbiz1, barw(0.4) fcolor(black) lcolor(white) ytitle(Percent) ///
	xlabel(1 "0" 2 "1 - 2" 3 "3 - 4" 4 "5+", valuelabel) xtitle(Previous businesses founded) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "Male") label (2 "Female") rows(1))
