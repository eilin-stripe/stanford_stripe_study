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
local rev_max = 10000
local actual_step = 100
local actual_point_count = (`rev_max'/`actual_step') + 1

local pred_step = 1000
local pred_point_count = (`rev_max'/`pred_step') + 1

local num_obs = `actual_point_count' * `pred_point_count'
set obs `actual_point_count'

gen Actual3Months = (_n - 1) * `actual_step'

expand `pred_point_count'
bys Actual3Months : gen Predict3Months = (_n - 1) * `pred_step'

save "`prediction_check'", replace
