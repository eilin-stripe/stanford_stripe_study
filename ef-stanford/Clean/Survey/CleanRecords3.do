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

local AllTime = "`raw_internal'/All Time Data as of 6 5 19.csv"
local Monthly = "`raw_internal'/Monthly Data as of 6 5 19.csv"
local Yearly = "`raw_internal'/Yearly Data as of 6 5 19.csv"
local save = "`clean_internal'/Records.dta"
*******************************************************************************
** Pull in the internal records data extract
*******************************************************************************
import delimited "`AllTime'" , encoding(ISO-8859-1)
rename first_charge_date FirstChargeDateTemp
rename activation_date ActivationDateTemp
rename externalreference ExternalReference
rename first_application_submitted_date ApplicationDateTemp

local datelist = "ApplicationDate FirstChargeDate ActivationDate"

foreach datevar of local datelist {
    replace `datevar'Temp  = substr(`datevar'Temp , 1, 10)
    gen `datevar' =  date(`datevar'Temp ,"YMD",1999)
    format `datevar' %td
    drop `datevar'Temp
}

rename connect__is_platform PlatformFlagTemp
replace PlatformFlagTemp = "True" if PlatformFlagTemp == "true"
replace PlatformFlagTemp = "False" if PlatformFlagTemp == "false"
encode PlatformFlagTemp, gen(PlatformFlag) label(TrueFalse)
drop PlatformFlagTemp

rename revenue AllTimeRev
rename transaction AllTimeTrans
rename count_cards_seen AllTimeCustomers

tempfile AllTimeClean
save "`AllTimeClean'"


*******************************************************************************
** Yearly
*******************************************************************************

import delimited "`Yearly'" , encoding(ISO-8859-1) clear
keep externalreference payment_month revenue transaction_count count_cards_seen

rename externalreference ExternalReference

rename payment_month PaymentYear
replace PaymentYear = substr(PaymentYear , 1, 4)
destring PaymentYear, replace

rename revenue YearRev
rename transaction YearTrans
rename count_cards_seen YearCustomers

tempfile YearlyClean
save "`YearlyClean'"

*******************************************************************************
** Monthly
*******************************************************************************

import delimited "`Monthly'" , encoding(ISO-8859-1) clear
keep externalreference payment_month revenue transaction_count ///
    count_cards_seen activation_date

rename externalreference ExternalReference
rename activation_date ActivationDateTemp

rename payment_month PaymentMonthTemp
replace PaymentMonthTemp = substr(PaymentMonthTemp , 1, 10)
gen int Month = mofd(date(PaymentMonthTemp ,"YMD",1999))
format Month %tm
drop PaymentMonthTemp

replace ActivationDateTemp  = substr(ActivationDateTemp , 1, 10)
gen ActivationMonth =  mofd(date(ActivationDateTemp ,"YMD",1999))
format ActivationMonth %tm
drop ActivationDateTemp

rename revenue Revenue
rename transaction Trans
rename count_cards_seen Customers

** Create a more usable firm id from the token
egen int firm_id = group(ExternalReference)

** Set the data up as panel dat
xtset firm_id Month, monthly

** Fill in the data for months where there weren't any customers
* Add the observations
tsfill, full
* Refill in the token numbers for each firm
gsort firm_id -Month
by firm_id : replace ExternalReference = ExternalReference[_n+1] if missing(ExternalReference)
by firm_id : replace ExternalReference = ExternalReference[_n-1] if missing(ExternalReference)
by firm_id : replace ActivationMonth = ActivationMonth[_n+1] if missing(ActivationMonth)
by firm_id : replace ActivationMonth = ActivationMonth[_n-1] if missing(ActivationMonth)



gsort firm_id Month
by firm_id : replace ExternalReference = ExternalReference[_n+1] if missing(ExternalReference)
by firm_id : replace ExternalReference = ExternalReference[_n-1] if missing(ExternalReference)
by firm_id : replace ActivationMonth = ActivationMonth[_n+1] if missing(ActivationMonth)
by firm_id : replace ActivationMonth = ActivationMonth[_n-1] if missing(ActivationMonth)

* Set all sales variables to zero for months that were missing
local vars = "Revenue Trans Customers"
foreach v of varlist `vars' {
	replace `v' = 0 if `v' == .
    replace `v' = . if Month < ActivationMonth
}

** Tag one observation for each firm for easy reference to collapsed data
egen firm_tag = tag(firm_id)

tempfile MonthlyClean
save "`MonthlyClean'"

gen LagQuarter = Revenue + L.Revenue + L2.Revenue
replace LagQuarter = . if Revenue == . | L.Revenue ==. | L2.Revenue == .
gen Growth12Quarter = (S12.LagQuarter / (0.5 * (L12.LagQuarter + LagQuarter)))


gen Growth12 = (S12.Revenue / (0.5 * (L12.Revenue + Revenue)))
gen Growth1 = (S1.Revenue / (0.5 * (L1.Revenue + Revenue)))
keep if inlist(Month , tm(2018m12))

tempfile Growth
save "`Growth'"




*******************************************************************************
