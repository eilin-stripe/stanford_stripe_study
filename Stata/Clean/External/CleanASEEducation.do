*******************************************************************************
** OVERVIEW
**
** cd "~/Documents/Stripe/Code/Stata/Clean/Survey/"
**
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

*/* Setup Paths
findbase "Stripe"
local base = r(base)
qui include `base'/Code/Stata/file_header.do

local in = "`raw_ase'/ASE_2016_Education/ASE_2016_00CSCBO07.csv"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"

local outdir = "`output'/NickLunch"*/

* ef
cd "/Users/eilin/Documents/SIE"
local in "02_clean_sample/ASE_2016_Education/ASE_2016_00CSCBO07.csv"

*******************************************************************************
**
*******************************************************************************
import delimited "`in'" , varnames(1) rowrange(3) encoding(ISO-8859-1)

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if asecbodisplaylabel == "All owners of respondent firms"
drop ase*

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep educdisplaylabel ownpdemp

rename educdisplaylabel EducationTemp1
replace EducationTemp1 = regexr(EducationTemp, "Less than high school graduate", "< High School")
replace EducationTemp1 = regexr(EducationTemp, "High school graduate - diploma or GED", "High School")
replace EducationTemp1 = regexr(EducationTemp, "Technical, trade, or vocational school", "2-Year Degree")
replace EducationTemp1 = regexr(EducationTemp, "Some college, but no degree", "Some College")
replace EducationTemp1 = regexr(EducationTemp, "Associate degree", "2-Year Degree")
replace EducationTemp1 = regexr(EducationTemp, "Bachelor's degree", "Bachelors")
replace EducationTemp1 = regexr(EducationTemp, "Master's, doctorate, or professional degree", "Masters+")
drop if EducationTemp1 == "Total reporting"
drop if EducationTemp1 == "Item not reported"

encode EducationTemp1, gen(EducationTemp) label(Education)
gen Education=1 if EducationTemp==2 | EducationTemp==4
replace Education=2 if EducationTemp==1 | EducationTemp==6
replace Education=3 if EducationTemp==3
replace Education=4 if EducationTemp==5
drop EducationTemp

rename ownpdemp Firms
destring Firms, replace

collapse (sum) Firms, by(Education)

egen totalfirms = total(Firms)
replace Firms = Firms / totalfirms

tempfile ase
save "`ase'"

/*use "`prediction_check'"

*keep if Finished == 1
keep if Finished == 2
// online-focused firms
keep if PercRevOnline >= 50

* weights
gen weight = 0.124 if strata == "funded"
replace weight = 1.831 if strata == "big"
replace weight = 1.236 if strata == "small"

gen Firmssurvey = 1
*collapse (sum) Firmssurvey, by(Education)
collapse (sum) Firmssurvey[w = weight] , by(Education)

egen totalfirmssurvey = total(Firmssurvey)
replace Firmssurvey = Firmssurvey / totalfirms

merge 1:1  Education using "`ase'"
replace Firmssurvey = - Firmssurvey

gen edu = 0 if Education == 2
replace edu = 1 if Education == 4
replace edu = 2 if Education == 6
replace edu = 3 if Education == 1
replace edu = 4 if Education == 3
replace edu = 5 if Education == 5
label define edu_l 0 "<High School" 1 "High School" 2 "2-Year Degree" 3 "Some College" 4 "Bachelors" 5 "Masters+"
label values edu edu_l

twoway (bar Firmssurvey edu, fcolor(purple) lcolor(white) lwidth(medium) horizontal barwidth(1)) (bar Firms edu, fcolor(dknavy) ////
	lcolor(white) lwidth(medium) horizontal barwidth(1)), ylabel(, labels angle(horizontal) valuelabel) graphregion(fcolor(white) ////
	ifcolor(white)) plotregion(fcolor(white) ifcolor(white))
	
twoway (bar Firms Education , horizontal) || ///
    (bar Firmssurvey Education, horizontal) , ///
    scheme(pretty1) ylabel( 1(1)6, valuelabel) ///
    xlabel(-.5 ".5" -.25 ".25" 0 "0" .25 .5) ///
    legend(order(2 "Survey" 1 "ASE")  region(lwidth(none))) ///
    ytitle("Education")
graph rename EducationComparison, replace
graph export "`outdir'/EducationComparison.eps", replace

/*
replace Firmssurvey = - Firmssurvey
graph bar Firms Firmssurvey, over(Age, label(angle(45))) ///
    scheme(pretty1) legend(order(2 "Survey" 1 "BDS")  region(lwidth(none)))
*/
*/

// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/01_raw_data/Combined.dta", clear

* clean
keep if Progress==100			// keep completed surveys
rename Female female

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2

gen edu_temp=1 if Education==1 | Education==2
replace edu_temp=2 if Education==3 | Education==4
replace edu_temp=3 if Education==5
replace edu_temp=4 if Education==6

keep edu_temp strata_int strata_wt
rename edu_temp Education


bysort Education (strata_int): gen stripe_firm_count_eq=sum(strata_wt)
bysort Education (strata_int): replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (Education)
drop if Education==.
label define edul 1 "High School" 2 "Some College" 3 "Bachelors" 4 "Masters+"
label values Education edul

** ratio of firms by edu
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio

// merge data
merge 1:1 Education using `ase'
replace Firms=-Firms

graph hbar Firms s_ratio, bar(1, fcolor("94 85 81")) bar(2, fcolor("62 156 143"))over(Education, label(labsize(small))) bargap(-100) ///
	ylabel(-.4 (0.2) 0.4) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "All US firms") label(2 "Stripe firms")) ///
	title(Education, size(medsmall))
	
	
/*///////////////////////////////////////////////////////////////////////////////

*** Extra: Comparing ASE to employer Stripe users

////////////////////////////////////////////////////////////////////////////////

// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/01_raw_data/Combined.dta", clear

* clean
keep if Progress==100			// keep completed surveys
rename Female female
keep if NumEmployees > 1		// keep employer firms

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.135 if strata_int==0
replace strata_wt=1.48 if strata_int==1
replace strata_wt=1.165 if strata_int==2

gen edu_temp=1 if Education==1 | Education==2
replace edu_temp=2 if Education==3 | Education==4
replace edu_temp=3 if Education==5
replace edu_temp=4 if Education==6

keep edu_temp strata_int strata_wt
rename edu_temp Education


bysort Education (strata_int): gen stripe_firm_count_eq=sum(strata_wt)
bysort Education (strata_int): replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (Education)
drop if Education==.
label define edul 1 "High School" 2 "Some College" 3 "Bachelors" 4 "Masters+"
label values Education edul

** ratio of firms by edu
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio

// merge data
merge 1:1 Education using `ase'
replace Firms=-Firms

graph hbar Firms s_ratio, bar(1, fcolor("94 85 81")) bar(2, fcolor("62 156 143")) over(Education, label(labsize(small))) bargap(-100) ///
	ylabel(-.4 (0.2) 0.4) graphregion(fcolor(white) ifcolor(white)) legend(label(1 "All US firms") label(2 "Stripe firms")) ///
	title(Education, size(medsmall))
