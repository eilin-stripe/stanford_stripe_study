*******************************************************************************
** OVERVIEW
**
** Figure out if it matters how we calculate 10%
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
qui include `base'/Code/Stata/file_header.do

local prediction_check = "`sim_data'/PredictionCheck.dta"

*******************************************************************************
**
*******************************************************************************
local rev_max = 20000
local actual_step = 100
local actual_point_count = (`rev_max'/`actual_step') + 1

set obs `actual_point_count'

gen Actual3Months = (_n - 1) * `actual_step'

gen Actual3MonthsHigh = Actual3Months * 1.1
gen Actual3MonthsLow = Actual3Months / 1.1

gen RoundNearestLow = round(Actual3MonthsLow, 1000)
gen RoundNearestHigh = round(Actual3MonthsHigh, 1000)
