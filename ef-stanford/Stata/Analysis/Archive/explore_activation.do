set more off
clear

** Setup
local base = "../../.."
local data = "`base'/Data"
local raw = "`data'/Raw"
local clean = "`data'/Clean"
local geo = "`clean'/Geo"
local tiger = "`geo'/TIGER"


use "`clean'/PanelActivated.dta", replace

