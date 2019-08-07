*******************************************************************************
** OVERVIEW
** Takes the raw mcc codes data and keeps only the labels we want
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

use "`raw_industry'/mcc_codes.dta"

** Only keep the label we want
drop edited_description
drop combined_description
drop usda_description

** Rename the irs variables we're using
rename irs_description mcc_label
rename irs_reportable tax_status

label variable tax_status "Tax Status for MCC grouping"

replace mcc_label = subinstr(mcc_label, ",", "", .)
replace mcc_label = subinstr(mcc_label, "’", "", .)
replace mcc_label = subinstr(mcc_label, ///
	"Miscellaneous Food Stores - Convenience Stores and Specialty Markets", ///
	"Misc Food Stores", .)
replace mcc_label = subinstr(mcc_label, ///
	"Mens Womens Clothing Stores", ///
    "Clothing Stores", .)
replace mcc_label = subinstr(mcc_label, ///
	"Commercial Photography Art and Graphic", ///
	"Photography, Art, and Graphic", .)
replace mcc_label = subinstr(mcc_label, ///
	"Charitable and Social Service Organizations - Fundraising", ///
	"Charitable, Service, Fundraising", .)

tostring mcc, gen(mcc_str)
replace mcc_label = mcc_str if mcc_label == ""
drop mcc_str

** Create Encoded tax_status variable
encode tax_status, gen(encoded_tax_status)
drop tax_status
rename encoded_tax_status tax_status

save "`clean_industry'/mcc_codes.dta", replace
