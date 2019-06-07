*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data and cleans up for analysis
** and mean mom growth in 2018
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
/*rf

*/

*ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
*/

// read data
use "`clean_dir'/round1.dta", clear


////	keep finished surveys & strata
drop if Finished == 1
gen strata_int = 0 if strata == "funded"
replace strata_int = 1 if strata == "big"
replace strata_int = 2 if strata =="small"
label define strata_l 0 "Funded" 1 "Large" 2 "Small"
label values strata_int strata_l

////	female indicator
gen female = 1 if Female == 1
replace female = 0 if Female == 2
label variable female "Female"
label define fem_l 0 "Male" 1 "Female" 
label values female fem_l

gen female_int = 2 if female == 0
replace female_int = 1 if female == 1
label define female_l2 1 "Female" 2 "Male"
label values female_int female_l2


*******************************************************************************
** Women are less likely to own funded firms
*******************************************************************************
*t3-f1
catplot strata_int female, percent(female)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(0 0 148)) bar(3, bcolor(177 162 225)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) legend(label(1 "Funded") label(2 "Large") label(3 "Small"))

// funding sources
*t3-f2
replace SourcesPersonalSavings = 1 if SourcesPersonalSavings == 0 & SourcesNone == 1
*t3-f3
graph hbar SourcesPersonalSavings SourcesCredit SourcesBankLoan SourcesGovLoan SourcesInvestor SourcesOther, over(female) graphregion(fcolor(white) ifcolor(white))
restore

// startup capital
gen startupfunds = 1 if StartingFunding >= 10
replace startupfunds = 2 if StartingFunding == 2
replace startupfunds = 3 if StartingFunding == 8
replace startupfunds = 4 if StartingFunding == 3
replace startupfunds = 5 if StartingFunding == 5
replace startupfunds = 6 if StartingFunding == 9
replace startupfunds = 7 if StartingFunding == 4
replace startupfunds = 8 if StartingFunding == 6
replace startupfunds = 9 if StartingFunding == 1
replace startupfunds = 10 if StartingFunding == 7
label define supfunds_l 1 "<1k" 2 "1k -5k" 3 "5k -10k" 4 "10k - 25k" 5 "25k - 50k" 6 "50k - 100k" 7 "100k - 250k" 8 "250k - 1mil" 9 "1mil - 3mil" 10 ">3mil"
label values startupfunds supfunds_l

* funded
*t3 -f4
catplot startupfunds female_int if strata == "funded", percent(female_int)stack asyvars bar(1, bcolor(0 93 125)) bar(2, bcolor(0 79 107)) bar(3, bcolor(0 70 94)) bar(4, bcolor(128 128 255)) bar(5, bcolor(64 64 255)) bar(6, bcolor(0 0 255)) bar(7, bcolor(0 0 204)) bar(8, bcolor(0 0 170)) bar(9, bcolor(0 0 146)) bar(10, bcolor(0 0 128))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

*large
*t3-f5
catplot startupfunds female_int if strata == "big", percent(female_int)stack asyvars bar(1, bcolor(0 93 125)) bar(2, bcolor(0 79 107)) bar(3, bcolor(0 70 94)) bar(4, bcolor(128 128 255)) bar(5, bcolor(64 64 255)) bar(6, bcolor(0 0 255)) bar(7, bcolor(0 0 204)) bar(8, bcolor(0 0 170)) bar(9, bcolor(0 0 146)) bar(10, bcolor(0 0 128))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


*small
*t3-f6
catplot startupfunds female_int if strata == "small", percent(female_int)stack asyvars bar(1, bcolor(0 93 125)) bar(2, bcolor(0 79 107)) bar(3, bcolor(0 70 94)) bar(4, bcolor(128 128 255)) bar(5, bcolor(64 64 255)) bar(6, bcolor(0 0 255)) bar(7, bcolor(0 0 204)) bar(8, bcolor(0 0 170)) bar(9, bcolor(0 0 146)) bar(10, bcolor(0 0 128))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 
