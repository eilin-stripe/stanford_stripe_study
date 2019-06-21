********************************************************************************
						*** TABLE 1 ***
********************************************************************************

** Entry cleaning logic + sum stats

********************************************************************************
** SETUP
********************************************************************************

cd "~/Documents/SIE"
local raw_dir "01_raw_data/"
local clean_dir "sta_files/"
local tables "07_Output/"

use "`clean_dir'round1.dta", clear

////	keep finished surveys & strata
drop if Finished == 1
gen strata_int = 0 if strata == "funded"
replace strata_int = 1 if strata == "big"
replace strata_int = 2 if strata =="small"


/*///	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)
** first observation of user
bysort merchant (year month): gen n = _n*/


////	female indicator
gen female = 1 if Female == 1
replace female = 0 if Female != 1 & Female != .
label variable female "Female"
label define fem_l 0 "Not female" 1 "Female" 
label values female fem_l

gen female_int = 2 if female == 0
replace female_int = 1 if female == 1
label variable female_int "Female=1 notfemale=2"
label define female_l2 1 "Female" 2 "Not female"
label values female_int female_l2


////	firm type by gender (t1_f1)
*catplot strata_int female if n == 1, percent(female)stack asyvars bar(1, bcolor(teal*0.8)) bar(2, bcolor(orange*0.7)) bar(3, bcolor(gs6)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) legend(label(1 "Funded") label(2 "Large") label(3 "Small"))
replace KeyLifeChangingMoney = 0 if KeyLifeChangingMoney == -777 & !missing(KeyLifeChangingMoney)
collapse (mean)KeyLifeChangingMoney KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther


////	reason by gender
replace KeyLifeChangingMoney = 0 if KeyLifeChangingMoney == -777 & !missing(KeyLifeChangingMoney)
replace KeyLifeChangingMoney = . if KeyLifeChangingMoney == -777 & missing(KeyLifeChangingMoney)
collapse (mean)KeyLifeChangingMoney KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther, by (female)
foreach var of varlist KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther{
replace `var' = `var'[2] - `var'[1] if female == .
}

preserve
label define yn 0 "No" 1 "Yes"
label values KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive yn
graph hbar KeyLifeChangingMoney KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive KeyLearning KeyOther, ////
	bar(1, bcolor(34 0 51)) bar(2, bcolor(128 0 42)) bar(3, bcolor(77 0 51))  bar(4, bcolor(0 51 8))  bar(5, bcolor(153 51 0)) ////
	bar(6, bcolor(0 25 153)) bar(7, bcolor(230 76 0)) bar(8, bcolor(89 0 179)) graphregion(fcolor(white) ifcolor(white)) ////
	plotregion(fcolor(white) ifcolor(white))

longshape KeyBeBossename KeyFlexible KeyEarnMore KeyBestAvenue KeyPositive, i(merchant_id) j(ques) y(ans) replace
*t1-f2a
catplot ans ques if female, stack asyvars percent(ques) graphregion(fcolor(white) ifcolor(white)) bar(1, bfcolor(orange*0.7) blcolor(black)) bar(2, bfcolor(teal*0.8) blcolor(black)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) title(Female)
*t1-fs2b
catplot ans ques if !female, stack asyvars percent(ques) graphregion(fcolor(white) ifcolor(white)) bar(1, bfcolor(orange*0.7) blcolor(black)) bar(2, bfcolor(teal*0.8) blcolor(black)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) title(Not female)
restore


////	funding by gender
preserve
keep if n == 1
replace SourcesPersonalSavings = 1 if SourcesPersonalSavings == 0 & SourcesNone == 1
*t1-f3
graph hbar SourcesPersonalSavings SourcesCredit SourcesBankLoan SourcesGovLoan SourcesInvestor SourcesOther, over(female) graphregion(fcolor(white) ifcolor(white))
restore


////	funding by education
gen edu_recode = 1 if Education == 2
replace edu_recode = 2 if Education == 4
replace edu_recode = 3 if Education == 1
replace edu_recode = 4 if Education == 6
replace edu_recode = 5 if Education == 3
replace edu_recode = 6 if Education == 5
label define edu_l 1 "< High School" 2 "High School" 3 "2-Year Degree" 4 "Some College" 5 "Bachelors" 6 "Masters+"
label values edu_recode edu_l
*t1-f4
graph hbar SourcesPersonalSavings SourcesCredit SourcesBankLoan SourcesGovLoan SourcesInvestor SourcesOther if n == 1, over(edu_recode) graphregion(fcolor(white) ifcolor(white))


//// hours worked
preserve
keep if n == 1 
////	max hours per week is set to 16*7
replace HoursPerWeek = 112 if HoursPerWeek > 112 & HoursPerWeek != .
bysort female: cumul HoursPerWeek, gen (cumulative) equal
twoway line cumul HoursPerWeek if female == 1 & HoursPerWeek < 120, sort || line cumul HoursPerWeek if female == 0 & HoursPerWeek < 120, sort legend(order(1 "Female" 2 "Not female")) graphregion(fcolor(white) ifcolor(white)) xtitle("Hours per week on business") ytitle("")


////	Previous business
** t1-f6
catplot PreviousBusinesses female_int if n == 1, percent(female_int)stack asyvars bar(1, bcolor(orange*1)) bar(2, bcolor(orange*0.8)) bar(3, bcolor(orange*0.6)) bar(4, bcolor(orange*0.4)) bar(5, bcolor(orange*0.2)) bar(6, bcolor(gs*0.3))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


////	Number of businesses owned
** t1-f7
catplot NumBusOwned female_int if n == 1, percent(female_int)stack asyvars bar(1, bcolor(orange*1)) bar(2, bcolor(orange*0.8)) bar(3, bcolor(orange*0.6)) bar(4, bcolor(orange*0.4)) bar(5, bcolor(orange*0.2)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 
** t1-f8 by strata
catplot NumBusOwned strata_int if n == 1, percent(strata_int)stack asyvars bar(1, bcolor(teal*1)) bar(2, bcolor(teal*0.8)) bar(3, bcolor(teal*0.6)) bar(4, bcolor(teal*0.4)) bar(5, bcolor(teal*0.2))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


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

*t1-f9
catplot startupfunds female_int if n == 1, percent(female_int)stack asyvars bar(1, bcolor(emidblue*1)) bar(2, bcolor(teal*0.8)) bar(3, bcolor(erose*0.6)) bar(4, bcolor(lavender*0.4)) bar(5, bcolor(red*0.2)) bar(6, bcolor(orange*0.2))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

* growth from 17q1 to 18q1
gen dhs_q1_l = 
	
