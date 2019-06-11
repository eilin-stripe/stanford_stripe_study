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


local use = "`raw_internal'/Demographic Data for Model.csv"
local save = "`clean_internal'/Demographics.dta"
*******************************************************************************
**
*******************************************************************************
import delimited "`use'"

rename rand RandID
rename usable_name Name
rename _id ExternalReference
rename primary_user__email Email
rename email AltEmail
rename support_phone Phone
rename first_name FirstName
rename last_name LastName
rename legal_entity__address_zip Zipcode
rename lifetime__total_volume LifetimeVolume
drop latest_application__application_ v22
rename date_sent SentDateTemp
rename first_charge_date FirstChargeDateTemp
rename last_charge_date LastChargeDateTemp
rename latest_application_submitted_dat ApplicationDateTemp
rename created CreatedDateTemp

foreach datevar of varlist *DateTemp {
    local basevar = regexr("`datevar'", "Temp", "")
    replace `basevar'Temp = substr(`basevar'Temp, 1, 10)
    gen `basevar' =  date(`basevar'Temp,"YMD",1999)
    format `basevar' %td
    drop `basevar'Temp
    compress `basevar'
}

replace Zipcode = regexr(Zipcode , "-.*", "")
replace Zipcode = regexr(Zipcode , "NY ", "")
replace Zipcode = "" if inlist(Zipcode, "Minnetonka", "N2E2M8")
destring Zipcode, replace

rename country CountryTemp
encode CountryTemp , gen(Country) label(Country)
drop CountryTemp

replace Phone = subinstr(Phone, "-", "", .)
replace Phone = subinstr(Phone, "(", "", .)
replace Phone = subinstr(Phone, ")", "", .)
gen CountryCodeMatch = regexm(Phone, "^\+([0-9]+) ")
gen CountryCode = regexs(1) if regexm(Phone, "^\+([0-9]+) ")
destring CountryCode, replace
drop CountryCodeMatch

replace Phone = regexr(Phone, "^\+([0-9]+) ", "")
replace Phone = subinstr(Phone, " ", "", .)
replace Phone = "" if inlist(Phone, "support_phone")
destring Phone, replace

rename wave WaveTemp
replace WaveTemp = "Wave 1" if WaveTemp == "WAVE 1"
replace WaveTemp = "Wave 2" if WaveTemp == "WAVE 2"
encode WaveTemp, gen(Wave) label(Wave)
drop WaveTemp
compress Wave

rename company_profile CompanyProfileTemp
replace CompanyProfileTemp = "Small Business" if CompanyProfileTemp == "1_small_business"
replace CompanyProfileTemp = "Medium Business" if CompanyProfileTemp == "2_medium_business"
replace CompanyProfileTemp = "Large Business" if CompanyProfileTemp == "3_large_business"
replace CompanyProfileTemp = "Enterprise" if CompanyProfileTemp == "4_enterprise"
replace CompanyProfileTemp = "Startup" if CompanyProfileTemp == "1p_startup"
replace CompanyProfileTemp = "Growth" if CompanyProfileTemp == "2p_growth"
replace CompanyProfileTemp = "Late Stage" if CompanyProfileTemp == "3p_late_stage"
encode CompanyProfileTemp, gen(CompanyProfile) label(CompanyProfile)
drop CompanyProfileTemp
compress CompanyProfile

rename label__industry__primary_vertica PrimaryIndustryTemp
replace PrimaryIndustryTemp = "Direct Services" if regexm(PrimaryIndustryTemp, "Direct Services: classes,memberships,appointments")
label define PrimaryIndustry 0 "Other Software & Content" 100 "Other"
encode PrimaryIndustryTemp, gen(PrimaryIndustry) label(PrimaryIndustry)
drop PrimaryIndustryTemp

rename legal_entity__type LegalTypeTemp
replace LegalTypeTemp = "Sole Prop" if LegalTypeTemp == "sole_prop"
replace LegalTypeTemp = "Non Profit" if LegalTypeTemp == "non_profit"
replace LegalTypeTemp = proper(LegalTypeTemp)
replace LegalTypeTemp = "LLC" if LegalTypeTemp == "Llc"
replace LegalTypeTemp = "Corporation" if LegalTypeTemp == "Company"
replace LegalTypeTemp = "Sole Prop" if LegalTypeTemp == "Individual"
encode LegalTypeTemp, gen(LegalType) label(LegalType)
drop LegalTypeTemp
compress LegalType

rename connect__connect_type ConnectTypeTemp
replace ConnectTypeTemp = "Direct" if ConnectTypeTemp == "unknown"
replace ConnectTypeTemp = proper(ConnectTypeTemp)
encode ConnectTypeTemp, gen(ConnectType) label(ConnectType)
drop ConnectTypeTemp
compress ConnectType

merge m:1 mcc using "`clean_industry'/mcc_codes.dta", keep(master matched) nogen

** Assign the irs mcc labels to the mcc variable, and then drop them
labmask mcc, values(mcc_label)
drop mcc_label

save "`save'" , replace
