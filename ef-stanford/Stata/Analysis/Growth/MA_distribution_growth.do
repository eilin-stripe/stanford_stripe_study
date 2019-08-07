*******************************************************************************
** OVERVIEW
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
set more off
clear

** Setup Paths
local base = "../../../.."
include `base'/Code/Stata/file_header.do


** Setup Output folder for results
local growth_output = "`output'/Growth"
capture erasedir "`growth_output'"
mkdir "`growth_output'"

local data_vars = "firm_id month first_month customers gpv transactions " + ///
    "total_customer mcc act_age"

** Load in the Stripe Panel data
use `data_vars' using "`main_panel'", clear

** Only keep activated firms
drop if total_customers < 3

* Only keep the Computer Software Stores industry (Apps)
keep if mcc == 5734

*******************************************************************************
** Exploratory analysis Sandbox
*******************************************************************************
** For a second, only focus in on the most recent month to understand the cross
** sectional distribution.

** temp comment out
/*
preserve
sum month
local max_month = r(max)

keep if month == `max_month'

* temp comment out
*pretty hist customers, logbase(1.2)

*pretty hist customers, logbase(1.2) zeros(1)
restore
*/

*******************************************************************************
** Exploratory analysis of individual firms over time
*******************************************************************************
** For a second, only focus in on the most recent month to understand the cross
** sectional distribution.
/*
sort firm_id
by firm_id : gen num_per = _N

keep if num_per >= 24

egen fake = group(firm_id)
*/

*******************************************************************************
** Time Series
*******************************************************************************














*
