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

** Load in the Stripe Panel data
local survey_label = "`raw_survey'/Stripe+Enterprise+Survey_wave2_April+9,+2019_19.49.csv"

// The last version of respondents and their data
local lastsave = "`clean_payment'/PaymentListApr8th2019.dta"

// The place to save the latest version of respondents and their data
local save = "`clean_payment'/PaymentListApr9th2019.dta"

// The place to save an extra of only the recent set of finished surveys
// to be sent as a payment list
local export = "`clean_payment'/PaymentListApr9th2019.csv"
*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************
// Import the survey data
import delimited "`survey_label'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress

// Only keep finished surveys, and detials on who finished and
// when they finished
keep enddate finished recipientlastname recipientfirstname recipientemail externalreference
keep if finished == "True"
drop finished

*******************************************************************************
** Cleaning
*******************************************************************************
rename recipientlastname LastName
rename recipientfirstname FirstName
rename recipientemail Email
rename externalreference AccountID
drop if AccountID == ""

gen Name = FirstName + " " + LastName

rename enddate EndDateTemp
replace EndDateTemp = substr(EndDateTemp, 1, 10)
gen EndDate =  date(EndDateTemp,"YMD",1999)
format EndDate %td
drop EndDateTemp

order Name Email AccountID FirstName LastName

save "`save'", replace

*******************************************************************************
** Export List of new respondents to be sent as a new payments list
*******************************************************************************

// Merge in the previous list of respondents to identify who is new, and only
// keep the new set of people who need to be paid
merge 1:1 AccountID using "`lastsave'", keep(1)
drop _merge

export delimited using "`export'", replace




*******************************************************************************
