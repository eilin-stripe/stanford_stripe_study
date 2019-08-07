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
qui include `base'/Code/Stata/file_header.do

local use = "`raw_internal'/May Revenue Update.csv"
local otheruse = "`raw_internal'/Sample Revenue Data as of May v2.csv"
local save = "`clean_internal'/Records.dta"
*******************************************************************************
** Pull in the internal records data extract
*******************************************************************************
import delimited "`otheruse'" , encoding(ISO-8859-1)
keep activation_date first_charge_date last_year_rev last_year_transactions ///
    externalreference
rename first_charge_date FirstChargeDateTemp
rename activation_date ActivationDateTemp
rename externalreference ExternalReference

tempfile LeftOut
save "`LeftOut'"

import delimited "`use'" , encoding(ISO-8859-1) clear

rename externalreference ExternalReference
merge 1:1 ExternalReference using "`LeftOut'"
keep if _merge == 3
drop _merge
*******************************************************************************
** Dates
*******************************************************************************
rename first_application_submitted_date ApplicationDateTemp
* rename first_charge_date FirstChargeDateTemp
* rename activation_date ActivationDateTemp

local datelist = "ApplicationDate FirstChargeDate ActivationDate"

foreach datevar of local datelist {
    replace `datevar'Temp  = substr(`datevar'Temp , 1, 10)
    gen `datevar' =  date(`datevar'Temp ,"YMD",1999)
    format `datevar' %td
    drop `datevar'Temp
}


*******************************************************************************
** Sales Volumes
*******************************************************************************
rename v9 may_rev
local monthlist = "dec jan feb mar apr may"
foreach month of local monthlist {
    local capmonth = proper("`month'")
    rename `month'_rev `capmonth'Rev
    rename `month'_transactions `capmonth'Trans
}

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
