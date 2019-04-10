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

** Setup Paths
findbase "Stripe"
local base = r(base)
include `base'/Code/Stata/file_header.do

local use = "`raw_internal'/Wave 1 Rev as of April v2.csv"
local save = "`clean_internal'/Records.dta"
*******************************************************************************
** Pull in the internal records data extract
*******************************************************************************
import delimited "`use'" , encoding(ISO-8859-1)

rename responseid ResponseID
rename externalreference ExternalReference

*******************************************************************************
** Dates
*******************************************************************************

rename startdate StartDateTemp
replace StartDateTemp = substr(StartDateTemp, 1, 10)
gen StartDate =  date(StartDateTemp,"YMD",1999)
format StartDate %td
drop StartDateTemp

rename enddate EndDateTemp
replace EndDateTemp = substr(EndDateTemp, 1, 10)
gen EndDate =  date(EndDateTemp,"YMD",1999)
format EndDate %td
drop EndDateTemp

rename first_application_submitted_date ApplicationDateTemp
replace ApplicationDateTemp  = substr(ApplicationDateTemp , 1, 10)
gen ApplicationDate =  date(ApplicationDateTemp ,"YMD",1999)
format ApplicationDate %td
drop ApplicationDateTemp


*******************************************************************************
** Sales Volumes
*******************************************************************************
rename dec_rev DecRev
rename dec_transactions DecTrans
rename jan_rev JanRev
rename jan_transactions JanTrans
rename feb_rev FebRev
rename feb_transactions FebTrans
rename mar_rev MarRev
rename mar_transactions MarTrans
rename last_year_rev LastYearRev
rename last_year_transactions LastYearTrans
rename all_time_transactions AllTrans
rename all_time_rev AllTimeRev

*******************************************************************************
** Other
*******************************************************************************
rename connect__is_platform PlatformFlagTemp
replace PlatformFlagTemp = "True" if PlatformFlagTemp == "true"
replace PlatformFlagTemp = "False" if PlatformFlagTemp == "false"
encode PlatformFlagTemp, gen(PlatformFlag) label(TrueFalse)
drop PlatformFlagTemp

save "`save'" , replace
