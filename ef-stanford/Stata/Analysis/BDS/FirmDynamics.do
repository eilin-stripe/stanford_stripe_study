set more off
clear

** Setup
local base = "../../../.."
local data = "`base'/Data"
local raw = "`data'/Raw"
local clean = "`data'/Clean"
local geo = "`clean'/Geo"
local tiger = "`geo'/TIGER"
local bds = "`raw'/BDS"

local bds_file = "`bds'/bds_f_st_release.dta"
use "`bds_file'", clear

tostring state, gen(STATEFP) format(%2.0f)
gen state_len = strlen(STATEFP)
replace STATEFP = "0" + STATEFP if state_len  == 1

mmerge STATEFP using "`tiger'/state.dta", type(n:1) ///
     unmatched(master) uname("state") ukeep(_ID NAME)
	 
	 
spmap estabs using "`tiger'/state_coor.dta"  ///
	if !inlist(state_ID, 41, 32, 50, 35, 37) & year == 2014,  ///
	id(state_ID) fcolor(Blues) ///
	title("Number of Businesses Per State") ///
	name("BusPerState", replace)
	
spmap estabs_entry using "`tiger'/state_coor.dta"  ///
	if !inlist(state_ID, 41, 32, 50, 35, 37) & year == 2014,  ///
	id(state_ID) fcolor(Blues) ///
	title("Number of New Businesses Per State") ///
	name("NewBusPerState", replace)

spmap estabs_entry_rate using "`tiger'/state_coor.dta"  ///
	if !inlist(state_ID, 41, 32, 50, 35, 37) & year == 2014,  ///
	id(state_ID) fcolor(Blues) ///
	title("Rate of Business Entry") ///
	name("EntryRate", replace)

