*******************************************************************************
** OVERVIEW
**
** this dofile uses cleaned round1 data to look at funded stats
** 
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




//// previous founding
*15-f1
catplot PreviousBusinesses strata_int, percent(strata_int)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(0 55 0)) bar(3, bcolor(33 66 0)) bar(4, bcolor(0 70 94)) bar(5, bcolor(0 93 125)) bar(6, bcolor(0 139 188))graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 

//// coding proficiency
gen coding_int = 1 if CodingProficient == 2
replace coding_int = 2 if CodingProficient == 1
label define coding_int_l  1 "Proficient" 2 "Not proficient"
label values coding_int coding_int_l

*15-f2
catplot coding_int strata_int, percent(strata_int)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(0 79 107)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 


// coding + female
keep if coding_int == 1
catplot strata_int female_int, percent(female_int)stack asyvars bar(1, bcolor(64 0 64)) bar(2, bcolor(0 0 148)) bar(3, bcolor(177 162 225)) graphregion(fcolor(white) ifcolor(white)) plotregion(fcolor(white) ifcolor(white)) title (, color(black)) 
