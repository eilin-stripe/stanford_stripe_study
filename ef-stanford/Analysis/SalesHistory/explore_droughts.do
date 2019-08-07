set more off
clear
graph drop _all

local base = "../../.."
local output = "`base'/Output"
local data = "`base'/Data"
local clean = "`data'/Clean"

use "`clean'/PanelActivated.dta", clear

tab sale_dum


sort firm_id month

count if F12.sale_dum == 1 & first_month == 1
count if F12.sale_dum == 0 & first_month == 1


sum activation_month
local start_month = `r(min)'
local end_month = `r(max)'

local iters = `end_month' - `start_month' + 1

matrix frac_mat = J(`iters',8, .)

local dif_count = 1
foreach dif of numlist 6 12 18 24 {
	gen F`dif'_not_dead_for_sure = F`dif'.not_dead_for_sure
	local last_month = `end_month' - `dif'
	disp "`last_month' `start_month'"
	local count = 1
	foreach m of numlist `start_month'/`last_month' {

		qui count if F`dif'_not_dead_for_sure == 1  ///
			& first_month == 1 & activation_month <= `m'
		local for_sure = `r(N)'

		qui count if F`dif'_not_dead_for_sure == 0 ///
			& first_month == 1 & activation_month <= `m'
		local unsure = `r(N)'

		local num = `for_sure'
		local denom = `for_sure' + `unsure'
		local frac = `num' / `denom'

		local col1 = `dif_count'
		local col2 = `dif_count' + 1

		matrix frac_mat[`count' , `col1'] = `m'
		matrix frac_mat[`count' , `col2'] = `frac'
		local count = `count' + 1
	}
	local dif_count = `dif_count' + 2
}

svmat2 frac_mat
format frac_mat1 %tm
pretty_scatter frac_mat2 frac_mat1 , xtitle("Actiavation Month") ///
	ytitle("% of Firms") ///
	title("Percent Confirmed Surviving After 6 months") ///
	name("PercentSurviving6mths") ///
	save("`output'/PercentSurviving6mths.eps")

pretty_scatter frac_mat4 frac_mat3 , xtitle("Actiavation Month") ///
	ytitle("% of Firms") ///
	title("Percent Confirmed Surviving After 1 Year") ///
	name("PercentSurviving1year") ///
	save("`output'/PercentSurviving1year.eps")

pretty_scatter frac_mat6 frac_mat5 , xtitle("Actiavation Month") ///
	ytitle("% of Firms") ///
	title("Percent Confirmed Surviving After 18 months") ///
	name("PercentSurviving18mths") ///
	save("`output'/PercentSurviving18mths.eps")

pretty_scatter frac_mat8 frac_mat7 , xtitle("Actiavation Month") ///
	ytitle("% of Firms") ///
	title("Percent Confirmed Surviving After 2 Years") ///
	name("PercentSurviving2year") ///
	save("`output'/PercentSurviving2year.eps")
