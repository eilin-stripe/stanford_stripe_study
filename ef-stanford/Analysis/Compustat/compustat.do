set more off
clear


***********
** SETUP **
***********

** Setup Path
local base = "../.."

** Load in the Stripe Panel data
use "`base'/Data/Raw/Compustat/compustat.dta"


gen qtr=yq(fyearq,fqtr)

egen firm_id = group(gvkey)

duplicates drop firm_id qtr, force

xtset firm_id qtr

gen revtq_growth = (D.revtq / (0.5 * (L.revtq + revtq)))


egen rank = rank(revtq), field
egen rev_cut = cut(rank), group(20)
egen rev_cut_tag = tag(rev_cut)
sort rev_cut
by rev_cut : egen SD_customer_growth_by_rev_cut = sd(revtq_growth)
by rev_cut : egen mean_rev_by_rev_cut = mean(revtq)
replace mean_rev_by_rev_cut = log(mean_rev_by_rev_cut + 1)
scatter SD_customer_growth_by_rev mean_rev_by_rev_cut if rev_cut_tag == 1
