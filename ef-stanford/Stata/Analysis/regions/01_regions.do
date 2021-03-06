******************************************************************************
				*** Geographical distribution ***
******************************************************************************	

* identifies respondent locations

******************************************************************************	
* setup
******************************************************************************	

// ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"

// read zip code data
import delimited "`raw_dir'/06_zip_to_zcta_2018/ziptozcta2017-Table 1.csv", encoding(ISO-8859-1)clear

* format to zip5
gen zip  = string(zip_code,"%05.0f") if zip_code <=9999
replace zip  = string(zip_code) if missing(zip)


* map state to 5 regions
gen region = 4 if state=="AK" | state=="CA" | state=="CO" | state=="HI" | state=="ID" | state=="MT" | state=="NV" | state=="AZ" ///
	| state=="NM" | state=="UT" | state=="WY" | state=="OR" | state=="WA"
replace region = 3 if state =="AL" | state=="AR" | state=="DC" | state=="DE" | state=="FL" | state=="GA" | state=="KY" ///
	| state=="LA" | state=="MD" | state=="MS" | state=="NC" | state=="OK" | state=="SC" | state=="VA" | state=="WV" ///
	| state=="TN" | state=="TX"
replace region=1 if state=="CT" | state=="MA" | state=="ME" | state=="NH" | state=="NJ" | state=="NY" | state=="RI" ///
	| state=="VT" | state=="PA" | state=="ND" | state=="SD"
replace region=2 if state=="IA" | state=="IL" | state=="IN" | state=="KS" | state=="MN" | state=="MO" | state=="ND" | state=="NE" ///
	| state=="OH" | state=="MI" | state=="WI" | state=="KS"
	
label define regionl 1 "Northeast" 2 "Midwest" 3 "South" 4 "West"

// drop territories
drop if region==.
		
tempfile z
save `z'


// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/sta_files/Combined.dta", clear
rename ZipCode zip
merge m:1 zip using `z'

keep if _merge==3			//_merge==2 for zip codes that are not in the survey; merge==1 for non-participating sample
drop _merge

// re-weight to represent Stripe
gen strata_int=0 if Strata==2 & !missing(Progress)
replace strata_int=1 if Strata==1 & !missing(Progress)
replace strata_int=2 if Strata==0 & !missing(Progress)

gen strata_wt=0.126 if strata_int==0
replace strata_wt=1.449 if strata_int==1
replace strata_wt=1.253 if strata_int==2

// stripe-equivalent firms by region
bysort region: gen stripe_firm_count_eq=sum(strata_wt)
bysort region: replace stripe_firm_count_eq= stripe_firm_count_eq[_N]

// keep region and fraction of stripe-equivalent by region
collapse stripe_firm_count_eq, by(region)
gen s_ratio=sum(stripe_firm_count_eq)
replace s_ratio = s_ratio[_N]
replace s_ratio= stripe_firm_count_eq /s_ratio

tempfile y
save `y'



*** BDS Data	***

use "02_clean_sample/BDS/bds_2014.dta", clear
keep year2 state firms

gen region=1 if state==09 | state==23 | state==25 | state==3 | state==44 | state==50 | state==34 | state==36 | state==42 | state==33
replace region=2 if state==18 | state==17 | state==26 | state==39 | state==5 | state==19 | state==20 | state==27 | state==29 ///
	| state==31 | state==38 | state==46 | state==55
replace region=3 if state==10 | state==11 | state==12 | state==13 | state==24 | state==37 | state==45 | state==51 | state==54 | state==01 ///
	| state==21 | state==28 | state==47 | state==05 | state==22 | state==40 | state==48
replace region=4 if state==04 | state==08 | state==16 | state==35 | state==30 | state==49 | state==32 | state==56 | state==02 | state==06 ///
	| state==15 | state==41 | state==53

// total firms in each region
bysort region: gen firms_region=sum(firms)
bysort region: replace firms_region=firms_region[_N]
collapse firms_region, by(region)

gen ratio=sum(firms_region)
replace ratio=ratio[_N]
replace ratio= firms_region/ratio

// merge with stripe regional distribution
merge 1:1 region using `y'
replace ratio = -ratio

graph hbar ratio s_ratio, bar(1, fcolor("99 48 179")) bar(2, fcolor("145 64 137")) over(region) bargap(-100)  graphregion(fcolor(white) ///
	ifcolor(white)) legend(label(1 "US firms") label(2 "Stripe firms"))
