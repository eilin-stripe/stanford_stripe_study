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

//*rf
** Setup Paths
*//

//ef
** Setup Paths
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"

*******************************************************************************
** Stats
*******************************************************************************

// read data
*use "`clean_dir'/round1.dta", clear
import delimited "/Users/eilin/Documents/SIE/01_raw_data/r1_firstcharge.csv", varnames(1) encoding(ISO-8859-1) clear
merge 1:1 merchant_id using "/Users/eilin/Documents/SIE/sta_files/round1.dta"
drop _merge 

// count of unique merchant
bysort merchant_id: gen n=_n
tab n							//4933 merchants

// tab finished					//3,983 finished

// tab Founder					// 4284 founders; 3681 finished founders


*******************************************************************************
** Generate vars
*******************************************************************************

// why did you start this business
*replace reason to missing if survey not completed by founder; looks like KeyLifeChanging was not an option in round 1
foreach key of varlist KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther KeyLifeChangingMoney{
replace `key' =. if Founder !=2
}
replace KeyLife=. if KeyLife==-777

// strata
gen strata_int=0 if strata=="funded"
replace strata_int=1 if strata=="big"
replace strata_int=2 if strata=="small"

// firm age
gen firm_age = (2019-FirstSale)
replace firm_age = 30 if firm_age>30 & !missing(firm_age)
label variable firm_age "Firm age (years)"
gen first_charge_year = regexs(0) if regexm(first_charge_date,"[0-9]+")
destring first_charge_year, replace
replace firm_age = (2019-first_charge_year) if missing(firm_age)
gen firm_age2 = firm_age*firm_age

////	Startup funding
gen startupfunds = 1 if StartingFunding >= 10
replace startupfunds = 2 if StartingFunding == 2
replace startupfunds = 3 if StartingFunding == 8
replace startupfunds = 4 if StartingFunding == 3
replace startupfunds = 5 if StartingFunding == 5
replace startupfunds = 6 if StartingFunding == 9
replace startupfunds = 7 if StartingFunding == 4
replace startupfunds = 8 if StartingFunding == 6
replace startupfunds = 9 if StartingFunding == 1
replace startupfunds = 10 if StartingFunding == 7
label define supfunds_l 1 "<1k" 2 "1k -5k" 3 "5k -10k" 4 "10k - 25k" 5 "25k - 50k" 6 "50k - 100k" 7 "100k - 250k" 8 "250k - 1mil" 9 "1mil - 3mil" 10 ">3mil"
label values startupfunds supfunds_l

gen startupfunds100k=1 if startupfunds>=7 & !missing(startupfunds)
replace startupfunds100k=0 if startupfunds<=6 & !missing(startupfunds)

// females
gen female_int=0 if Female==2
replace female_int=1 if Female==1

// merge with h1 growth
merge 1:1 merchant_id using "`clean_dir'/growth.dta"
drop _merge

// strata
reg growth i.strata_int, robust		// relative to funded firms, big and small firms have lower levels of growth

reg growth i.strata_int i.strata_int##c.firm_age female, robust

////	max hours per week is set to 16*7
replace HoursPerWeek = 112 if HoursPerWeek > 112 & HoursPerWeek != .

//previous biz
gen prev_biz_indicator=1 if PreviousBusinesses >1 & !missing(PreviousBusinesses)
replace prev_biz_indicator=0 if PreviousBusinesses==1

// education
gen edu_recode = 1 if Education == 2
replace edu_recode = 2 if Education == 4
replace edu_recode = 3 if Education == 1
replace edu_recode = 4 if Education == 6
replace edu_recode = 5 if Education == 3
replace edu_recode = 6 if Education == 5
label define edu_l 1 "< High School" 2 "High School" 3 "2-Year Degree" 4 "Some College" 5 "Bachelors" 6 "Masters+"
label values edu_recode edu_l
gen college=1 if edu_recode>=5 & !missing(edu_recode)
replace college=0 if edu_recode<5 & !missing(edu_recode)

// merge zip to rural data
cap drop _merge
merge m:1 ZipCode using "/Users/eilin/Documents/SIE/sta_files/ziptorural.dta"
keep if _merge==3
drop _merge

// Number of employees
gen employee=NumEmployees
replace employee = 500 if employee > 500

// CodingProficient
gen coding=0 if CodingProficient==1
replace coding=1 if CodingProficient==2

// NumFounders
gen single_founder=1 if NumFounders==1
replace single_founder=0 if NumFounders!=1

// STEM indicator
gen stem=1 if DegreeSTEM==1
replace stem=0 if DegreeSTEM==0

// histogram
winsor2 dhs_h1, suffix(_w) cuts(10 90) 
histogram dhs_h1_w, fraction fcolor(dkgreen) lcolor(white) xtitle(Growth rates (2019h1)) graphregion(fcolor(white) lcolor(white))

*******************************************************************************
** Regressions
*******************************************************************************

/*/ 1. funded firms have higher level of growth, but they also experience less growth for each additional year

reg growth_h1 i.strata_int, robust
outreg2 using "`output_dir'/a1.tex", replace

reg growth_h1 firm_age, robust
outreg2 using "`output_dir'/a1.tex", append

reg growth_h1 i.strata_int c.firm_age##i.strata_int, robust
outreg2 using "`output_dir'/a1.tex", append

reg growth_h1 i.strata_int c.firm_age##i.strata_int female startupfunds100k rural NumEmployees HoursPerWeek , robust
outreg2 using "`output_dir'/a1.tex", append

twoway (scatter growth firm_age, msym(oh) jitter(3)) (lfit growth firm_age if strata_int==0)(lfit growth firm_age if strata_int==1) (lfit growth firm_age if strata_int==2), legend(order(1 "Observed data" 2 "Funded" 3 "Large" 4 "Small")) graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white)) ytitle(Log growth)

// 2a. women are less likely to start big

reg startupfunds100k female, robust
outreg2 using "`output_dir'/a2.tex", replace

reg startupfunds100k c.female##i.strata_int, robust
outreg2 using "`output_dir'/a2.tex", append

reg startupfunds100k c.female##i.strata_int college prev_biz_indicator firm_age rural CodingProficient FriendsBusinessFounders, robust
outreg2 using "`output_dir'/a2.tex", append


// 2b. but women's firms are growing at the same rate
reg growth_h1 female, robust
outreg2 using "`output_dir'/a3.tex", replace

reg growth_h1 female_int i.female##i.startupfunds100k, robust
outreg2 using "`output_dir'/a3.tex", append

reg growth_h1 female i.female##i.strata_int, robust
outreg2 using "`output_dir'/a3.tex", append

reg growth_h1 female i.female##i.startupfunds100k i.female##i.strata_int college coding firm_age firm_age2 employee rural single_founder SourcesInvestor, robust
outreg2 using "`output_dir'/a3.tex", append
*/
