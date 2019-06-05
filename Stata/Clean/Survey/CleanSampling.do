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

/*rf
** Setup Paths
findbase "Stripe"
local base = r(base)
include `base'/Code/Stata/file_header.do
*/

*ef
** Setup Paths
cd "/Users/eilin/Documents/SIE"
local raw_sampling "01_raw_data"
local clean_sampling "02_clean_sample"
*/


local use = "`raw_sampling'/sample_us_181106_1.xlsx"
local save = "`clean_sampling'/Sample.dta"


*******************************************************************************
** Import the Strata by excel sheet
*******************************************************************************
tempfile small big funded

import excel "`use'", sheet("big") firstrow
save "`big'", replace
drop *

import excel "`use'", sheet("funded") firstrow
save "`funded'", replace
drop *

import excel "`use'", sheet("small") firstrow
save "`small'" , replace

append using "`big'" "`funded'", gen(Strata)
label values Strata Strata

*******************************************************************************
** Cleaning
*******************************************************************************
rename rand Rand
rename usable_name Name
rename _id ExternalReference
rename country CountryTemp
rename primary_user__email Email
rename email SecondaryEmail
rename support_phone Phone
rename first_name FirstName
rename last_name LastName
rename wave WaveTemp
rename datesent DateSent

replace WaveTemp = "Wave 1" if WaveTemp == "WAVE 1"
replace WaveTemp = "Wave 2" if WaveTemp == "WAVE 2"
encode WaveTemp, gen(Wave) label(Wave)
drop WaveTemp
compress Wave

replace CountryTemp = "United States" if CountryTemp == "US"
encode CountryTemp , gen(Country) label(Country)
drop CountryTemp
compress Country

replace SecondaryEmail = "" if Email == SecondaryEmail
compress SecondaryEmail

replace Phone = regexr(Phone, "^\+1", "")
replace Phone = subinstr(Phone, "-", "", .)
replace Phone = subinstr(Phone, " ", "", .)
replace Phone = subinstr(Phone, "(", "", .)
replace Phone = subinstr(Phone, ")", "", .)
replace Phone = subinstr(Phone, ".", "", .)
replace Phone = subinstr(Phone, "support_phone", "", .)
replace Phone = regexr(Phone, "[,]?ext[0-9]+", "")
replace Phone = regexr(Phone, "[,]?x[0-9]+", "")
destring Phone, replace
format Phone %12.0g

save "`save'" , replace
