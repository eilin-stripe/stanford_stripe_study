*******************************************************************************
** 
** Gender from ASE and Stripe founders gender
**
*******************************************************************************



*******************************************************************************
** SETUP
*******************************************************************************

// ef
cd "/Users/eilin/Documents/SIE"
local raw_dir "01_raw_data"
local clean_dir "sta_files"
local output_dir "07_Output"
local external "02_clean_sample"


// read ase data
import delimited "`external'/ASE_2016_OwnerAge/ASE_2016_00CSCBO08.csv", varnames(1) encoding(ISO-8859-1)clear

keep if geoid == "0100000US"
drop geoid geoid2 geodisplaylabel geoannotationid
keep if naicsdisplaylabel == "Total for all sectors"
drop naics*

keep if inlist(asecbodisplaylabel, "Male", "Female")
drop asecboid

keep if yibszfidisplaylabel == "All firms"
drop yibszfi*

keep asecbodisplaylabel ownpdemp

rename asecbodisplaylabel FemaleTemp
gen female=0 if FemaleTemp=="Male"
replace female=1 if FemaleTemp=="Female"
drop FemaleTemp

rename ownpdemp us_firms
destring us_firms, replace

collapse (sum) us_firms, by(female)

** ratio of firms by gender
egen us_ratio=total(us_firms)
replace us_ratio=us_firms/us_ratio

tempfile ase
save `ase'



// read in combined r1 and r2 data
use "/Users/eilin/Documents/SIE/sta_files/Combined.dta", clear

collapse (count) Progress, by (Female)
drop if Female>1
rename Progress s_firms



// merge data
merge 1:1 Female using `ase'
