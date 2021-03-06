*******************************************************************************
** 
** Gender from ASE and Stripe founders gender
** reads ASE 2016 data, combines summary stats for non-employer businesses and 
*** compares to re-weighted survey data
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


// read ase data
import delimited "`external'/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv", varnames(1) encoding(ISO-8859-1)clear

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if inlist(asecbodisplaylabel, "Male", "Female")
drop asecboid

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep asecbodisplaylabel ownpdemp

rename asecbodisplaylabel FemaleTemp
gen female=0 if FemaleTemp=="Male"
replace female=1 if FemaleTemp=="Female"
drop FemaleTemp

rename ownpdemp us_firms
destring us_firms, replace

collapse (sum) us_firms, by(female)


// total non-employer business in 2016=24,813,048 (https://www.census.gov/newsroom/press-releases/2019/nonemployer-businesses.html)
// share of women in non-employer business in 2015 =40% (https://www.sba.gov/sites/default/files/advocacy/Nonemployer-Fact-Sheet.pdf)
gen us_nes=0.4*24813048 if female==1
replace us_nes=0.6*24813048 if female==0

** ratio of firms by gender
//add up firms by gender
egen total_by_gender=rowtotal(us_firms us_nes)
//add firms across both genders
egen us_ratio=total(total_by_gender)
replace us_ratio=total_by_gender/us_ratio

tempfile ase
save `ase'



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

keep female strata_int strata_wt
bysort female (strata_int): gen stripe_firm_count_eq=sum(strata_wt)
bysort female (strata_int): replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (female)
drop if female>1

** ratio of firms by gender
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio


// merge data
merge 1:1 female using `ase'

graph hbar us_ratio s_ratio, bar(1, fcolor("94 85 81")) bar(2, fcolor("62 156 143")) over(female) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "All US firms") label(2 "Stripe firms")) title(Gender, size(medsmall)) 
 



////////////////////////////////////////////////////////////////////////////////

*** Extra: Comparing ASE to employer Stripe users

////////////////////////////////////////////////////////////////////////////////

/*
// read ase data
import delimited "`external'/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv", varnames(1) encoding(ISO-8859-1)clear

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if inlist(asecbodisplaylabel, "Male", "Female")
drop asecboid

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep asecbodisplaylabel ownpdemp

rename asecbodisplaylabel FemaleTemp
gen female=0 if FemaleTemp=="Male"
replace female=1 if FemaleTemp=="Female"
drop FemaleTemp

rename ownpdemp us_firms
destring us_firms, replace

collapse (sum) us_firms, by(female)

** ratio of firms by gender
egen us_ratio=total(us_firms)
replace us_ratio= us_firms/us_ratio

tempfile ase
save `ase'


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

keep female strata_int strata_wt
bysort female (strata_int): gen stripe_firm_count_eq=sum(strata_wt)
bysort female (strata_int): replace stripe_firm_count_eq= stripe_firm_count_eq[_N]
collapse stripe_firm_count_eq, by (female)
drop if female>1

** ratio of firms by gender
egen s_ratio=total(stripe_firm_count_eq)
replace s_ratio= stripe_firm_count_eq/s_ratio


// merge data
merge 1:1 female using `ase'

graph hbar us_ratio s_ratio, bar(1, fcolor("144 56 140")) bar(2, fcolor("68 65 130")) over(female) graphregion(fcolor(white) ifcolor(white)) ///
	legend(label(1 "All US firms") label(2 "Stripe firms")) title(Gender, size(medsmall)) 
 
