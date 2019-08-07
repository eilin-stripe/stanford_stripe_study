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

// read data
import delimited "`raw_dir'/r1_npv.csv", encoding(ISO-8859-1)clear

merge m:1 merchant_id using "/Users/eilin/Documents/SIE/sta_files/round1.dta"

* change from cents to dollars
replace npv_monthly = npv_monthly/100
label variable npv_monthly "Monthly NPV ($)"
* replace negative npv=0
replace npv_monthly=0 if npv_monthly<0

*******************************************************************************
** Generate vars
*******************************************************************************


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

////	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)

// end date
gen enddate = date(EndDateTemp,"YMD")

//Jan completion -- predicting for jan, feb, mar 2019
local j=date("2019-01-31", "YMD")
local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
loca j3 = date("2019-03-01", "YMD")

bysort merchant (ndate): gen actual3m = sum(npv_monthly) if enddate == `j' & (ndate == `j1' | ndate == `j2' | ndate == `j3')

// feb completion -- predicting for feb, mar, apr 2019
local f=date("2019-02-28", "YMD")
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")
bysort merchant_id (year month): replace actual3m = sum(npv_monthly) if enddate > `j' & enddate <= `f' & (ndate == `f1' | ndate == `f2' | ndate == `f3')

// march completion -- predicting for mar, apr, may 2019
local m = date("2019-03-31", "YMD")
local m1 = date("2019-03-01", "YMD")
local m2 = date("2019-04-01", "YMD")
loca m3 = date("2019-05-01", "YMD")
bysort merchant_id (year month): replace actual3m = sum(npv_monthly) if enddate > `f' & enddate <= `m' & (ndate == `m1' | ndate == `m2' | ndate == `m3')

// apr completion -- predicting for apr, may, june 2019
local a = date("2019-04-30", "YMD")
local a1 = date("2019-04-01", "YMD")
local a2 = date("2019-05-01", "YMD")
loca a3 = date("2019-06-01", "YMD")
bysort merchant_id (year month): replace actual3m = sum(npv_monthly) if enddate > `m' & enddate <= `a' & (ndate == `a1' | ndate == `a2' | ndate == `a3')


bysort merchant_id (year month): gen actual3m_temp = actual3m if !missing(actual3m)
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_n - 1] if missing(actual3m) & _n > 1
bysort merchant_id (year month): replace actual3m_temp = actual3m_temp[_N]
bysort merchant_id (ndate): replace actual3m = actual3m_temp
drop actual3m_temp

bysort merchant_id (year month): replace actual3m= . if _n != 1		//keep one observation for actual3m per merchant


////	Prediction categories
foreach var of varlist Predict3Months Bad3Months Good3Months{
	replace `var' = `var' * 1000
}

gen predict_cat = 1 if actual3m <= Bad3Months & (actual3m != . & Bad3Months!=. & Predict3Months!=.)
replace predict_cat = 2 if actual3m > Bad3Months & actual3m <= 0.9*Predict3Months & (actual3m != . & Bad3Months!=. & Predict3Months!=.)
replace predict_cat = 3 if actual3m >= 0.9*Predict3Months & actual3m <= 1.1*Predict3Months & (actual3m != . & Predict3Months!=.)
replace predict_cat = 4 if actual3m >= 1.1*Predict3Months & (actual3m != . & Predict3Months!=.)
replace predict_cat = 5 if actual3m >= Good3Months & (actual3m != . & Predict3Months!=. & Good3Months !=.)

gen predict_accurate=1 if predict_cat==3
replace predict_accurate=0 if predict_cat!=3 & !missing(predict_cat)

// dashboard views
bysort merchant (ndate): gen dash_total=sum(dash_views_monthly) if ndate>=date("2017-12-31", "YMD")& ndate<=date("2018-12-31", "YMD")
bysort merchant (ndate): replace dash_total= dash_total[_n-1] if dash_total==.
bysort merchant (ndate): replace dash_total= dash_total[_N] 
bysort merchant (ndate): replace dash_total=. if _n!=1

gen dash_mean=1 if dash_total>=113 & !missing(dash_total) 
replace dash_mean=0 if dash_total<113 & !missing(dash_total)


// strata
gen strata_int=0 if strata=="funded"
replace strata_int=1 if strata=="big"
replace strata_int=2 if strata=="small"

// over-optimism
su predict_cat, de

gen diff = Predict3Months/actual3m
replace diff=1 if actual3m==0 & Predict3Months==0
su diff, de
local m= r(p99)
replace diff = `m' if actual3m==0 & Predict3Months>0 & missing(diff)

// 40% are over-optimistic
twoway (histogram predict_cat, discrete fraction fcolor(dkgreen) fintensity(90) lcolor(white) barwidth(1)), graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) xtitle("")
twoway (histogram predict_cat if strata_int==0, barwidth(0.8) discrete fc("102 0 51"*.5) lcolor(black) fraction) (histogram predict_cat if strata_int==1,  barwidth(0.7) discrete lcolor(white) fc("0 76 153"*.4) fraction) (histogram predict_cat if strata_int==2, barwidth(0.55) discrete fc("255 128 0"*.25) lcolor(white) fraction), graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) xtitle("") legend(label(1 "Funded") label(2 "Large") label(3 "Small"))

/*/ dashboard viewing is associated with more accurate predictions


reg predict_accurate dash_mean, robust
outreg2 using "`output_dir'/y1.tex", replace

reg predict_accurate i.dash_mean##i.strata_int, robust
outreg2 using "`output_dir'/y1.tex", append

reg predict_accurate i.dash_mean##i.strata_int single_founder startupfunds100k PercRevInternational PercRevOnline employee coding college , robust
outreg2 using "`output_dir'/y1.tex", append*/


// growth from 17q4 to 18q4
local m = date("2019-03-31", "YMD")
local oct18 = date("2018-10-01", "YMD")
local nov18 = date("2018-11-01", "YMD")
loca dec18 = date("2018-12-01", "YMD")
bysort merchant (ndate): gen npv_18q4 = sum(npv_monthly) if (enddate <= `m') & (ndate == `oct18' | ndate == `nov18' | ndate == `dec18')

bysort merchant_id (year month): gen npv_18q4_temp = npv_18q4 if !missing(npv_18q4)
bysort merchant_id (year month): replace npv_18q4_temp = npv_18q4_temp[_n - 1] if missing(npv_18q4) & _n > 1
bysort merchant_id (year month): replace npv_18q4_temp = npv_18q4_temp[_N]
bysort merchant_id (ndate): replace npv_18q4 = npv_18q4_temp
drop npv_18q4_temp

bysort merchant_id (year month): replace npv_18q4= . if _n != 1		//keep one observation for npv_18q4 per merchant


// growth from 17q4 to 18q4
local m = date("2019-03-31", "YMD")
local oct17 = date("2017-10-01", "YMD")
local nov17 = date("2017-11-01", "YMD")
loca dec17 = date("2017-12-01", "YMD")
bysort merchant (ndate): gen npv_17q4 = sum(npv_monthly) if (enddate <= `m') & (ndate == `oct17' | ndate == `nov17' | ndate == `dec17')

bysort merchant_id (year month): gen npv_17q4_temp = npv_17q4 if !missing(npv_17q4)
bysort merchant_id (year month): replace npv_17q4_temp = npv_17q4_temp[_n - 1] if missing(npv_17q4) & _n > 1
bysort merchant_id (year month): replace npv_17q4_temp = npv_17q4_temp[_N]
bysort merchant_id (ndate): replace npv_17q4 = npv_17q4_temp
drop npv_17q4_temp

bysort merchant_id (year month): replace npv_17q4= . if _n != 1		//keep one observation for npv_17q4 per merchant


// growth from 18q1 to 19q1
local jun = date("2019-06-30", "YMD")
local m = date("2019-03-31", "YMD")
local jan18 = date("2018-01-01", "YMD")
local feb18 = date("2018-02-01", "YMD")
loca mar18 = date("2018-03-01", "YMD")
bysort merchant (ndate): gen npv_18q1 = sum(npv_monthly) if (enddate > `m' & enddate <= `jun') & (ndate == `jan18' | ndate == `feb18' | ndate == `mar18')

bysort merchant_id (year month): gen npv_18q1_temp = npv_18q1 if !missing(npv_18q1)
bysort merchant_id (year month): replace npv_18q1_temp = npv_18q1_temp[_n - 1] if missing(npv_18q1) & _n > 1
bysort merchant_id (year month): replace npv_18q1_temp = npv_18q1_temp[_N]
bysort merchant_id (ndate): replace npv_18q1 = npv_18q1_temp
drop npv_18q1_temp
bysort merchant_id (year month): replace npv_18q1= . if _n != 1	

* 2019
local jun = date("2019-06-30", "YMD")
local m = date("2019-03-31", "YMD")
local jan19 = date("2019-01-01", "YMD")
local feb19 = date("2019-02-01", "YMD")
loca mar19 = date("2019-03-01", "YMD")
bysort merchant (ndate): gen npv_19q1 = sum(npv_monthly) if (enddate > `m' & enddate <= `jun') & (ndate == `jan19' | ndate == `feb19' | ndate == `mar19')

bysort merchant_id (year month): gen npv_19q1_temp = npv_19q1 if !missing(npv_19q1)
bysort merchant_id (year month): replace npv_19q1_temp = npv_19q1_temp[_n - 1] if missing(npv_19q1) & _n > 1
bysort merchant_id (year month): replace npv_19q1_temp = npv_19q1_temp[_N]
bysort merchant_id (ndate): replace npv_19q1 = npv_19q1_temp
drop npv_19q1_temp
bysort merchant_id (year month): replace npv_19q1= . if _n != 1	


local jun = date("2019-06-30", "YMD")
local m = date("2019-03-31", "YMD")


* variable indicating previous quarter growth
gen prev_q_growth=ln(npv_19q1/npv_18q1) if (enddate > `m' & enddate <= `jun')
replace prev_q_growth=ln(npv_18q4/npv_17q4) if enddate < `m' 


// positive growth indicator
gen growth_negative=1 if prev_q_growth<=0 & !missing(prev_q_growth)
replace growth_negative=0 if prev_q_growth>0 & !missing(prev_q_growth)



// overestimation indicator
gen predict_over=1 if predict_cat==1 | predict_cat==2
replace predict_over=0 if predict_cat==3 | predict_cat==4 | predict_cat==5

/*
reg predict_over i.growth_negative##i.strata_int, robust
outreg2 using "`output_dir'/y2.tex", replace

reg predict_over i.growth_negative##i.strata_int i.growth_negative##i.dash_mean, robust
outreg2 using "`output_dir'/y2.tex", append

reg predict_over i.growth_negative##i.strata_int i.growth_negative##i.dash_mean single_founder startupfunds100k PercRevInternational PercRevOnline employee coding college , robust
outreg2 using "`output_dir'/y2.tex", append

// strata
catplot predict_cat strata_int, percent(strata_int)stack asyvars bar(1, bcolor(31 10 115*1)) bar(2, bcolor(67 36 191)) bar(3, bcolor(10 100 115)) bar(4, bcolor(36 169 191)) bar(5, bcolor(176 235 245))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

// female
bysort merchant_id (timestamp): gen n=_n
gen female=1 if Female==1 & n==1
replace female=0 if Female==2 & n==1
catplot predict_cat female, percent(female)stack asyvars bar(1, bcolor(31 10 115*1)) bar(2, bcolor(67 36 191)) bar(3, bcolor(10 100 115)) bar(4, bcolor(36 169 191)) bar(5, bcolor(176 235 245))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

// college
catplot predict_cat college, percent(college)stack asyvars bar(1, bcolor(31 10 115*1)) bar(2, bcolor(67 36 191)) bar(3, bcolor(10 100 115)) bar(4, bcolor(36 169 191)) bar(5, bcolor(176 235 245))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

// single-founders
catplot predict_cat single_founder if n==1, percent(single_founder)stack asyvars bar(1, bcolor(31 10 115*1)) bar(2, bcolor(67 36 191)) bar(3, bcolor(10 100 115)) bar(4, bcolor(36 169 191)) bar(5, bcolor(176 235 245))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

// employee -- larger firms less likely to be over-optimistic
gen employee_category=1 if employee<=5
replace employee_category=2 if employee>5 & employee<=10
replace employee_category=3 if employee>10 & employee<=50
replace employee_category=4 if employee>50 & !missing(employee)


// previous founding -- first time less likely to be over optimistic
catplot predict_cat prev_biz_indicator if n==1, percent(prev_biz_indicator)stack asyvars bar(1, bcolor(31 10 115*1)) bar(2, bcolor(67 36 191)) bar(3, bcolor(10 100 115)) bar(4, bcolor(36 169 191)) bar(5, bcolor(176 235 245))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


// firm age
gen firm_age=2019-FirstCostYear


// dhs growth histogram




