******************************************************************************
				*** Growth rate forecasts ***
******************************************************************************	

* calculates YoY forecasted growth rates
* reads NPV data 
* compares to Predicted growth for next 12 months to derive expected growth
* rate

******************************************************************************	
* setup
******************************************************************************	

// ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"

* read Combined data
use "`clean_dir'/Combined.dta", clear
rename ExternalReference merchant_id
tempfile x
save `x'

* read raw NPV data
import delimited "`raw_dir'/r1_npv.csv", encoding(ISO-8859-1)clear
merge m:1 merchant_id using `x'
	// _merge==2 for respondents who have not had a transaction since 2017, so replace actual_npv=0 for _merge==2 & Progress==100

* keep shorter list of variables
keep merchant_id timestamp npv_monthly Actual3Months Predict3Months Bad3Months Good3Months Progress EndDate _merge

*** change from cents 
replace npv_monthly = npv_monthly/100
label variable npv_monthly "NPV in month m ($)"

*** date
gen year = regexs(0) if regexm(timestamp,"[0-9]+")
label variable year "Year of observation"
gen month = regexs(2) if regexm(timestamp, "([0-9]*)[-]([0-9]*)")
label variable month "Month of observation"
gen day=regexs(5) if regexm(timestamp, "([0-9]+)(\-)([0-9]+)(\-)([0-9]+)")
destring year month day, replace
gen ndate =mdy(month, day, year)

*** gen actual NPV for 12 months preceeding round 1 completion

* jan 2019 completion
local jan18 = date("2018-01-01", "YMD")
local dec18 = date("2018-12-01", "YMD")
local jan19 = date("2019-01-31", "YMD")
bysort merchant_id (timestamp): gen npv_past12m=sum(npv_monthly) if EndDate<=`jan19' & (ndate>= `jan18' & ndate <= `dec18')

* feb 2019 completion
local feb18 = date("2018-02-01", "YMD")
local feb19=date("2019-02-28", "YMD")
bysort merchant_id (timestamp): replace npv_past12m=sum(npv_monthly) if EndDate<= `feb19' & (ndate>= `feb18' & ndate <= `jan19')

* mar 2019 completion
local mar18 = date("2018-03-01", "YMD")
local mar19 = date("2019-03-31", "YMD")
bysort merchant_id (timestamp): replace npv_past12m=sum(npv_monthly) if EndDate<= `mar19' & (ndate>= `mar18' & ndate <= `feb19')

* apr 2019 completion
