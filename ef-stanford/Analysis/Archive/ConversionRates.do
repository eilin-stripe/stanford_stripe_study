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
local survey = "`clean_survey'/Survey.dta"
local main = "`clean_survey'/Main.dta"

local outdir = "`output'/Predictions"

local logbase = 1.4
*******************************************************************************
** Stats
*******************************************************************************
use "`main'", replace
