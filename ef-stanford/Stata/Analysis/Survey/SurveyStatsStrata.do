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
qui include `base'/Code/Stata/file_header.do

** Setup output folder for survey stats
local output_stats = "`output'/SurveyStats"

** Load in the Stripe Panel data
local survey = "`clean_main_survey'/Survey.dta"
local sample = "`clean_sampling'/Sample.dta"
local sample2 = "`clean_sampling'/Sample2.dta"
local records = "`clean_internal'/Records.dta"
*******************************************************************************
** Stats
*******************************************************************************
use "`survey'", clear
drop if ExternalReference == ""
keep if inlist(SurveyRound, 1, 2)
keep if Finished == 1

merge 1:1 ExternalReference using "`sample'"
keep if _merge == 3
keep if inlist(Wave, 1, 2)
drop _merge
tempfile round1
save "`round1'"

use "`survey'", clear
keep if SurveyRound == 2
drop if ExternalReference == ""
keep if Finished == 1
merge 1:1 ExternalReference using "`sample2'"
keep if _merge == 3
drop _merge
tempfile round2
save "`round2'"

append using "`round1'"
keep if Finished == 1

local gender = "compare"
*******************************************************************************
**
*******************************************************************************

gen CountryTemp = Country
bys CountryTemp : gen NumFromCountry = _N
replace CountryTemp = -888 if NumFromCountry <= 4
label value CountryTemp Country

local tab_vars = "FounderFlag CodingProficient Female OtherJobFlag " ///
    + "CountryTemp PrevJobFlag "
foreach var of local tab_vars {
    eststo clear
    estpost tabulate `var' Strata
    esttab using "`output_stats'/`var'`gender'.tex" , ///
        cells("b(label(freq))")  ///
        nonumber nomtitle noobs replace unstack ///
        varlabels(, blist(Total "\hline "))
}

local horiz_vars = "Education StartingFunding CatPercRevOnline " ///
    + " CatPercRevStripe WorkLocation HowLeftPrevJob PrevJobQuitReason " ///
    + " NumBusOwned PreviousBusinesses "
foreach var of local horiz_vars {
    split_local `var' , varname length(50)
    local t = r(relabel)

    pretty_hist_horiz `var', save("`output_stats'/`var'`gender'.eps") ///
        name("`var'`gender'")  xtitle("") by(Strata, rows(3) title(`t'))
}

local hist_vars = "NumFounders DifSaleCostYear Age "
foreach var of local hist_vars {
    split_local `var' , varname length(50)
    local t = r(relabel)

    pretty (hist `var', discrete frac by(Strata, rows(3))), ///
        save("`output_stats'/`var'`gender'.eps") ///
        name("`var'`gender'") xtitle("") title(`t')
}

local percent_vars = "PercRevOnline PercRevStripe PercRevInternational " ///
    + "PredictRevInternational"
foreach var of local percent_vars {
    replace `var' = `var' * 100 if `var' > 0 & `var' < 1
    replace `var' = round(`var') if `var' > 0 & `var' < 1
    evenbin `var' , dif(10) maxcutoff(100) zero
    replace `var'_bin = 10 if `var'_bin == 11

    split_local `var' , varname length(50)
    local t = r(relabel)

    twoway (hist `var'_bin, discrete frac by(Strata, rows(3) title(`t')) xlabel( 0/10 ,valuelabel angle(45)))  ///
        , scheme(pretty1) name("`var'`gender'", replace) xtitle("")
    graph export "`output_stats'/`var'`gender'.eps", replace
}

local years_vars = "FirstSaleYear FirstCostYear FirstHireYear"
foreach var of local years_vars {
    evenbin `var' , dif(1) mincutoff(1982)
    sum `var'_bin
    local minbin = r(min)
    local maxbin = r(max)

    split_local `var' , varname length(50)
    local t = r(relabel)

    twoway (hist `var'_bin, by(Strata, rows(3) title(`t')) discrete frac xlabel( `minbin'(5)`maxbin', valuelabel angle(45))) ///
        , scheme(pretty1) name("`var'`gender'_bin", replace) xtitle("")
    graph export "`output_stats'/`var'`gender'.eps", replace
}



local hours_vars = "HoursPerWeek HoursPerWeekOtherJob"
foreach var of local hours_vars {
    evenbin `var' , dif(5) maxcutoff(100) zero
    replace `var'_bin = round(`var'_bin)

    sum `var'_bin
    local minbin = r(min)
    local maxbin = r(max)

    split_local `var' , varname length(50)
    local t = r(relabel)

    twoway (hist `var'_bin, by(Strata, rows(3) title(`t')) discrete frac xlabel( `minbin'/`maxbin' , valuelabel angle(45)))  ///
        , scheme(pretty1) name("`var'`gender'", replace) xtitle("")
    graph export "`output_stats'/`var'`gender'.eps", replace
}



gen RevPerEmp = RevPastMonth / NumFullTime
local log_hist_vars = "EarningsPast12Months Good3Months " ///
    + "Bad3Months Good12Months Bad12Months RevPast12Months RevPastMonth " ///
        + "Predict3Months Predict12Months RevPerEmp  NumFullTime " ///
        + "NumPartTime PredictFullTime PredictPartTime " ///
        + " NumSoftwareFullTime NumSoftwarePartTime "
foreach var of local log_hist_vars {
    split_local `var' , varname length(50)
    local t = r(relabel)

    pretty (hist `var', by(Strata, rows(3)) xlogbase(1.4) frac zeros(1)), save("`output_stats'/`var'`gender'.eps") ///
        name("`var'`gender'") xtitle("") title(`t')
}

local log_hist_vars = "PrevJobIncome OtherJobIncome " ///
        + "MinIncomeStayFullTime MinIncomeLeaveOtherJob "
foreach var of local log_hist_vars {
    split_local `var' , varname length(50)
    local t = r(relabel)

    pretty (hist `var' if `var' >= 0 , by(Strata, rows(3) ) xlogbase(1.4) frac zeros(1)), save("`output_stats'/`var'`gender'.eps") ///
        name("`var'`gender'") xtitle("") title(`t')
}

pretty (scatter Education EarningsPast12Months, xlogbase(1.2) by(Strata, rows(3)) ///
    ylabel(1/6, valuelabel angle(horizontal))), ///
    xtitle(Earnings) ytitle("") name("EarningsVsEducation`gender'") ///
    save("`output_stats'/EarningsVsEducation`gender'.eps")

bys Education : egen MeanEarningsByEduc = mean(EarningsPast12Months) if EarningsPast12Months >= 0
egen EducationTag = tag(Education)

pretty (scatter Education MeanEarningsByEduc if EducationTag == 1, xlogbase(1.2) by(Strata, rows(3)) ///
    ylabel(1/6, valuelabel angle(horizontal))), ///
    xtitle(Earnings) ytitle("") name("MeanEarningsVsEducation`gender'") ///
    save("`output_stats'/MeanEarningsVsEducation`gender'.eps")

gen Test = EarningsPast12Months + 1
graph hbox Test , over(Education, descending) over(Strata) nooutside scheme(pretty1) ///
    ytitle("Earnings") name("BoxEarningsVsEducation`gender'", replace)
graph export "`output_stats'/BoxEducationVsEarnings`gender'.eps", replace



gen LogPredict12Months = log(Predict12Months + 1)
gen LogPredictFullTime = log(PredictFullTime + 1)

lpoly LogPredictFullTime LogPredict12Months if Predict12Months < 20000, ///
    scheme(pretty1) xtitle("Predicted Revenue, 1 yr") ///
    ytitle("Predicted # Full Employees, 3yrs") ///
    name("PredEarningsVsPredEmp`gender'", replace)
graph export "`output_stats'/PredEarningsVsPredEmp`gender'.eps", replace

gen Predict12Over3 = Predict12Months /Predict3Months
replace Predict12Over3 = -777 if Predict3Months == 0

gen Predict12Over3Ratio = (Predict12Months /Predict3Months) * (.25)
replace Predict12Over3Ratio = -777 if Predict3Months == 0

gen GoodOverBad3Months = (Good3Months / Bad3Months) - 1
replace GoodOverBad3Months = -777 if Bad3Months == 0

gen GoodOverPredict3Months = (Good3Months / Predict3Months) - 1
replace GoodOverPredict3Months = -777 if Predict3Months == 0

gen PredictOverBad3Months = (Predict3Months / Bad3Months) - 1
replace PredictOverBad3Months = -777 if Bad3Months == 0

gen GoodOverBad12Months = (Good12Months / Bad12Months) - 1
replace GoodOverBad12Months = -777 if Bad12Months == 0

gen GoodOverPredict12Months = (Good12Months / Predict12Months) - 1
replace GoodOverPredict12Months = -777 if Predict12Months == 0

gen PredictOverBad12Months = (Predict12Months / Bad12Months) - 1
replace PredictOverBad12Months = -777 if Bad12Months == 0

local ratio_vars = "Predict12Over3 GoodOverBad3Months " ///
    + "GoodOverPredict3Months PredictOverBad3Months " ///
    + "GoodOverBad12Months GoodOverPredict12Months " ///
    + "PredictOverBad12Months Predict12Over3Ratio"
foreach var of local ratio_vars {
    pretty (hist `var', xlogbase(1.2) frac by(Strata, rows(3)) ) ,  name("`var'") xtitle("") ///
        save("`output_stats'/`var'.eps")
}

dr ^Sources*
local test = r(varlist)
graph hbar `test' if FounderFlag == 1, scheme(pretty1) legend(off) ///
    over(Strata) nolabel showyvars name("Sources", replace) ///
    title("What sources of funding were used to start" "this business in the first year?")
graph export "`output_stats'/FundingSources`gender'.eps", replace


dr ^Key*
local test = r(varlist)
local test = regexr("`test'", "KeyLearning", "")
graph hbar `test' if FounderFlag == 1 & SurveyRound == 2, scheme(pretty1) legend(off) ///
    over(Strata) nolabel showyvars name("KeyFactors", replace) ///
    title("What were the key factors in deciding" "to start this business?")
graph export "`output_stats'/KeyFactors`gender'.eps", replace

dr ^WhyOtherJob*
local test = r(varlist)
graph hbar `test' if OtherJobFlag == 1, scheme(pretty1) legend(off) ///
    over(Strata) nolabel showyvars name("WhyOtherJob", replace) ///
    title("Why are you still working in another" "job, rather than focusing on this" "business full-time?")
graph export "`output_stats'/WhyOtherJob`gender'.eps", replace


gen NewRatio = Predict12Months / (Predict3Months * 4)

gen NineMonth = Predict12Months - Predict3Months
replace NineMonth = . if NineMonth < 0
gen NewRatio2 = NineMonth / (Predict3Months * 3)


replace PercRevStripe = PercRevStripe * 100 if PercRevStripe > 0 & PercRevStripe < 1
gen RevPast12MonthAdj = RevPast12Months * (PercRevStripe / 100)
gen Ratio12 = ((Predict12Months/12)) / ((RevPast12MonthAdj/12))
replace PercRevStripe = PercRevStripe * 100 if PercRevStripe == 1 & Ratio12 >= 100
replace RevPast12MonthAdj = RevPast12Months * (PercRevStripe / 100)

replace Ratio12 = ((Predict12Months/12)) / ((RevPast12MonthAdj/12))
gen Ratio3 = ((Predict3Months/3)) / (RevPast12MonthAdj/12)

replace Ratio3 = -777 if RevPast12MonthAdj == 0
replace Ratio12 = -777 if RevPast12MonthAdj == 0

gen Ratio3_1 = ((Predict3Months/3)) / (RevPastMonth)
gen Ratio12_1 = ((Predict12Months/12)) / (RevPastMonth)
replace Ratio3_1 = -777 if RevPastMonth == 0
replace Ratio12_1 = -777 if RevPastMonth == 0

pretty (hist NewRatio, xlogbase(1.2) frac ) ,  name("Ratio12OverThreeTimesFour") xtitle("") save("`output_stats'/Ratio12to3.eps")
pretty (hist NewRatio2, xlogbase(1.2) frac ) ,  name("Ratio9OverThreeTimesThree") xtitle("") save("`output_stats'/Ratio9to3.eps")
pretty (hist Ratio12, xlogbase(1.4) frac ) ,  name("Ratio12") xtitle("") save("`output_stats'/Ratio12.eps")
pretty (hist Ratio3, xlogbase(1.4) frac ) ,  name("Ratio3") xtitle("") save("`output_stats'/Ratio3.eps")

pretty (hist Ratio12_1, xlogbase(1.2) frac) ,  name("Ratio12_1") xtitle("") save("`output_stats'/Ratio12_1.eps")
pretty (hist Ratio3_1, xlogbase(1.2) frac) ,  name("Ratio3_1") xtitle("") save("`output_stats'/Ratio3_1.eps")


*******************************************************************************
