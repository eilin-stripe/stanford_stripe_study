******************************************************************************
				*** Recall ***
******************************************************************************	

* compares actual to recall 3-month npv

******************************************************************************	
* setup
******************************************************************************

//ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"


// read data
import delimited "/Users/eilin/Documents/SIE/01_raw_data/r1_npv.csv", varnames(1) encoding(ISO-8859-1)clear
merge m:1 merchant_id using "/Users/eilin/Documents/SIE/sta_files/round1.dta"

foreach var of varlist Predict3Months Bad3Months Good3Months{
	replace `var' = `var' * 1000
}

* change from cents to dollars
replace npv_monthly = npv_monthly/100
label variable npv_monthly "Monthly NPV ($)"
* replace negative npv=0
replace npv_monthly=0 if npv_monthly<0


////	time for redshift data
rename month timestamp
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)") //note: day is meaningless because aggregated to 1st when pulling from db
destring year month day, replace
gen ndate = mdy(month, day, year)

//enddate
gen enddate = date(EndDateTemp,"YMD")


// actual growth rate

** january 2019 survey completion
local j = date("2019-01-31", "YMD")
local f = date("2019-02-28", "YMD")
local mar=date("2019-03-31", "YMD")
local apr=date("2019-04-30", "YMD")

local j1 = date("2019-01-01", "YMD")
local j2 = date("2019-02-01", "YMD")
loca j3 = date("2019-03-01", "YMD")
local j4 = date("2018-01-01", "YMD")
local j5 = date("2018-02-01", "YMD")
loca j6 = date("2018-03-01", "YMD")
bysort merchant_id (year month): gen actual3m_2019 = sum(npv_monthly) if enddate <= `j' & (ndate == `j1' | ndate == `j2' | ndate == `j3')
bysort merchant_id (year month): gen actual3m_2018 = sum(npv_monthly) if enddate <= `j' & (ndate == `j4' | ndate == `j5' | ndate == `j6')

** february 2019 completion
local f1 = date("2019-02-01", "YMD")
local f2 = date("2019-03-01", "YMD")
loca f3 = date("2019-04-01", "YMD")
local f4 = date("2018-02-01", "YMD")
local f5 = date("2018-03-01", "YMD")
loca f6 = date("2018-04-01", "YMD")
bysort merchant_id (year month): replace actual3m_2019 = sum(npv_monthly) if enddate > `j' & enddate <= `f' & (ndate == `f1' | ndate == `f2' | ndate == `f3')
bysort merchant_id (year month): replace actual3m_2018 = sum(npv_monthly) if enddate > `j' & enddate <= `f' & (ndate == `f4' | ndate == `f5' | ndate == `f6')

** march 2019 completion
local mar1=date("2019-03-01", "YMD")
local mar2=date("2019-04-01", "YMD")
local mar3=date("2019-05-01", "YMD")
local mar4=date("2018-03-01", "YMD")
local mar5=date("2018-04-01", "YMD")
local mar6=date("2018-05-01", "YMD")
bysort merchant_id(year month): replace actual3m_2019= sum(npv_monthly) if enddate>`f' & enddate<=`mar' & (ndate==`mar1' | ndate==`mar2' | ndate==`mar3')
bysort merchant_id (year month): replace actual3m_2018 = sum(npv_monthly) if enddate>`f' & enddate<=`mar' & (ndate == `mar4' | ndate == `mar5' | ndate == `mar6')

*apr completion
local apr1=date("2019-04-01", "YMD")
local apr2=date("2019-05-01", "YMD")
local apr3=date("2019-06-01", "YMD")
local apr4=date("2018-04-01", "YMD")
local apr5=date("2018-05-01", "YMD")
local apr6=date("2018-06-01", "YMD")
bysort merchant_id(year month): replace actual3m_2019= sum(npv_monthly) if enddate>`mar' & enddate<=`apr' & (ndate==`apr1' | ndate==`apr2' | ndate==`apr3')
bysort merchant_id (year month): replace actual3m_2018 = sum(npv_monthly) if enddate>`mar' & enddate<=`apr'  & (ndate == `apr4' | ndate == `apr5' | ndate == `apr6')
