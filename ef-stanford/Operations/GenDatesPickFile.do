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

local save = "`raw_survey'/DateOptions.csv"

*******************************************************************************
**
*******************************************************************************

set obs 119
gen Year = _n + 1900

expand 12
bys Year: gen MonthID = _n
gen Month = ""

forvalues m = 1/12 {
    local month : word `m' of `c(Months)'
    bys Year : replace Month = "`month'" if _n == `m'
}

drop if Year == 2019 & MonthID >= 6
gsort -Year -MonthID
drop MonthID

export delimited "`save'", replace
