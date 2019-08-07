program clean_window , rclass
	version 14
	

	***********
	** SETUP **
	***********

	** Setup Path
	local base = "../.."


	** Load in the Stripe Panel data
	use "`base'/Data/Clean/PanelActivated.dta", clear

	qui sum month
	local max_month = `r(max)' - 1

	drop if act_age > `0'
	drop if `max_month' - activation_month < `0'

	
	save "`base'/Data/Clean/Window_`0'.dta", replace
	
end
