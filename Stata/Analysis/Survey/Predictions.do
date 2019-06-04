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

** Load in the Stripe Panel data
local main = "`clean_main_survey'/Main.dta"
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local outdir = "`output'/Predictions"

local logbase = 1.4
*******************************************************************************
** Stats
*******************************************************************************
* use "`main'", replace
use "`prediction_check'", replace
keep if Finished == 1

gen Actual3MonthsHigh = (Actual3Months * 1.1)
gen Actual3MonthsLow = (Actual3Months / 1.1)
gen Actual3MonthsHighRound = round(Actual3MonthsHigh, 1000)
gen Actual3MonthsLowRound = round(Actual3MonthsLow, 1000)
gen Within10_1 = (Predict3Months >= Actual3MonthsLow & Predict3Months <= Actual3MonthsHigh)
gen Within10_round = (Predict3Months >= Actual3MonthsLowRound & Predict3Months <= Actual3MonthsHighRound)
gen Within10_2 = Within10_1 | Within10_round
gen Within10_1000 = (Actual3Months <= 1000) & (Predict3Months == 1000 | Predict3Months == 0)
gen Within10_3 = Within10_1 | Within10_round | Within10_1000

gen Winner = 0
replace Winner = 1 if Within10_2 == 1

sort EndDate
bys EndDate : egen AvgPredict3Months = mean(Predict3Months)
egen EndDateTag = tag(Predict3Months)

pretty (scatter Predict3Months EndDate , ylogbase(`logbase')),  ///
    xtitle("Survey Date") ///
    ytitle("Predicted 3 Month Revenue ") ///
    name("Pred3MonthVsSurveyDate") save("`outdir'/Pred3MonthVsSurveyDate.eps")

/*
pretty (scatter Actual3Months Predict3Months if Month == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3Months Predict3Months if Month == 2, xlogbase(`logbase') ylogbase(`logbase')), ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Estimated Actual 3 Month") ///
    legend(label(1 "January") label(2 "February")) ///
    name("ActualVsPred3Month") save("`outdir'/ActualVsPred3Month.eps")
*/

gen Actual3MonthAdj = Actual3Months
replace Actual3MonthAdj = Predict3Months if abs(Actual3MonthAdj - Predict3Months) < 1000
replace Actual3MonthAdj = round(Actual3MonthAdj, 1000)

/*
pretty (scatter Actual3MonthAdj Predict3Months if Month == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3MonthAdj Predict3Months if Month == 2, xlogbase(`logbase') ylogbase(`logbase')), ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Rounded Estimated Actual 3 Month") ///
    legend(label(1 "January") label(2 "February")) ///
    name("ActualAdjVsPred3Month") save("`outdir'/ActualAdjVsPred3Month.eps")
*/

gen Range = Good3Month - Bad3Months
gen StdRange = Range / Predict3Months
replace StdRange = -777 if Predict3Months == 0 & Range != 0
replace StdRange = 0 if Predict3Months == 0 & Range == 0

winsor2 StdRange , cuts(0 95)

pretty (hist StdRange, xlogbase(1.2) zeros(1) frac) , ///
    xtitle("Normalized Prediction Range")  ///
    name("NormalizedPredictionRange") save("`outdir'/PredRange.eps")

hist StdRange_w if StdRange_w != -777, scheme(pretty1) ///
    xtitle("Normalized Prediction Range")  ///
    name("WinsorPredictionRange", replace)
graph export "`outdir'/WinsorPredRange.eps", replace

* pretty (scatter StdRange Predict3Months if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w Predict3Months , xlogbase(2) ) , ///
    xtitle("Predicted 3 Month Revenue") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsPred3Month") save("`outdir'/RangeVsPred3Month.eps")

/*
* pretty (scatter StdRange AllTrans if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w AllTrans , xlogbase(2) ), ///
    xtitle("Total Transactions Ever") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsAllTrans") save("`outdir'/RangeVsAllTrans.eps")
*/

* pretty (scatter StdRange LastYearTrans if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w LastYearTrans , xlogbase(2) ) ,  ///
    xtitle("Transactions Last Year") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsTransLastYear") save("`outdir'/RangeVsTransLastYear.eps")

* pretty (scatter StdRange LastYearRev if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w LastYearRev , xlogbase(2) ), ///
    xtitle("Revenue Last Year") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsRevLastYear") save("`outdir'/RangeVsRevLastYear.eps")

* pretty (scatter StdRange ApplicationDate if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w ApplicationDate , xlogbase(2) ), ///
    xtitle("Application Date") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsApplicationDate") save("`outdir'/RangeVsApplicationDate.eps")

* pretty (scatter StdRange FirstSaleYear if StdRange < 1000, xlogbase(2) )
pretty (scatter StdRange_w FirstSaleYear, xlogbase(2) ), ///
    xtitle("First Sale Year") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsFirstSaleYear") save("`outdir'/RangeVsFirstSaleYear.eps")

pretty (scatter StdRange_w PreviousBusinesses  if !inlist(StdRange_w, -777) ///
    & PreviousBusinesses != -777) , xtitle("# Previous Businesses") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsNumPrevBus") save("`outdir'/NumPrevBus.eps")

pretty (scatter StdRange_w PreviousBusinesses  if !inlist(StdRange_w, -777) ///
    & PreviousBusinesses != -777) , xtitle("# Previous Businesses") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsNumPrevBus") save("`outdir'/NumPrevBus.eps")

*******************************************************************************
** Age vs. Confidence
*******************************************************************************

eststo clear
egen FirstSaleYearStd = std(FirstSaleYear)
eststo: reg StdRange_w FirstSaleYearStd if !inlist(StdRange, -777, 0)
estadd ysumm

egen ApplicationDateStd = std(ApplicationDate)
eststo: reg StdRange_w ApplicationDateStd if !inlist(StdRange, -777, 0)
estadd ysumm

gen LogLastYearRev = log(LastYearRev)
eststo: reg StdRange_w LogLastYearRev if !inlist(StdRange_w, -777, 0)
estadd ysumm

* reg StdRange_w FirstSaleYear LogLastYearRev if StdRange_w != -777
eststo: reg StdRange_w FirstSaleYearStd LogLastYearRev if !inlist(StdRange_w, -777, 0)
estadd ysumm

eststo: reg StdRange_w ApplicationDateStd LogLastYearRev if !inlist(StdRange_w, -777, 0)
estadd ysumm

esttab using "`outdir'/RangeVsAge.tex" , replace style(tex) ///
    cells(b(star fmt(3)) se(par fmt(2))) ///
    stats(ymean N, fmt(%8.2f %8.0g) ///
    label("Dep Mean" "Observations")) ///
    substitute(\_ _) mlabels(none) collabels(none) ///
    starlevels(* 0.1 ** 0.05 *** 0.01)  ///
    varlabels(FirstSaleYearStd "Std. First Sale Year" LogLastYearRevStd "Log Revenue Last Year" ///
        ApplicationDateStd "Std. Application Date" _cons "Constant")

*******************************************************************************
** Transaction Volume vs Confidence
*******************************************************************************

gen LogAllTrans = log(AllTrans)
gen LogLastYearTrans = log(LastYearTrans)

eststo clear
eststo: reg StdRange_w LogAllTrans if !inlist(StdRange_w, -777, 0)
estadd ysumm

eststo: reg StdRange_w LogLastYearRev LogAllTrans if !inlist(StdRange_w, -777, 0)
estadd ysumm

eststo: reg StdRange_w LogAllTrans LogLastYearTrans if !inlist(StdRange_w, -777, 0) & AllTrans != LastYearTrans
estadd ysumm

esttab using "`outdir'/RangeVsTransVolume.tex" , replace style(tex) ///
    cells(b(star fmt(3)) se(par fmt(2))) ///
    stats(ymean N, fmt(%8.2f %8.0g) ///
    label("Dep Mean" "Observations")) ///
    substitute(\_ _) mlabels(none) collabels(none) ///
    starlevels(* 0.1 ** 0.05 *** 0.01)  ///
    varlabels(LogAllTrans "Log Transactions Ever" LogLastYearTrans "Log Transactions Last Year" ///
        LogLastYearRev "Log Revenue Last Year" _cons "Constant")


*******************************************************************************
** PreviousBusinesses
*******************************************************************************

eststo clear
eststo: reg StdRange_w PreviousBusinesses if !inlist(StdRange_w, -777, 0)
estadd ysumm

eststo: reg StdRange_w LogLastYearRev PreviousBusinesses if !inlist(StdRange_w, -777, 0)
estadd ysumm

esttab using "`outdir'/RangeVsPrevBus.tex" , replace style(tex) ///
    cells(b(star fmt(3)) se(par fmt(2))) ///
    stats(ymean N, fmt(%8.2f %8.0g) ///
    label("Dep Mean" "Observations")) ///
    substitute(\_ _) mlabels(none) collabels(none) ///
    starlevels(* 0.1 ** 0.05 *** 0.01)  ///
    varlabels(PreviousBusinesses "\# Prev Business" ///
        LogLastYearRev "Log Revenue Last Year" _cons "Constant")

eststo clear
estpost tabulate Strata
esttab using "`outdir'/Strata.tex" , ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    varlabels(, blist(Total "\hline "))      ///
    nonumber nomtitle noobs replace





*******************************************************************************
