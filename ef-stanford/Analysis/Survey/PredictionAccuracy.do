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
local prediction_check = "`clean_main_survey'/PredictionCheck.dta"
local prediction_check_sim = "`sim_data'/PredictionCheck.dta"

local outdir = "`output'/Predictions"

local logbase = 1.4

*******************************************************************************
** Set up Measures of How close they were
*******************************************************************************
* use "`prediction_check'"
use "`prediction_check'"

// Calculate ratios of Predict To Actual
gen PredictOverActual3Months = Predict3Months/Actual3Months
replace PredictOverActual3Months = 1 if Predict3Months == 0 & Actual3Months == 0
replace PredictOverActual3Months = 999 if Predict3Months != 0 & Actual3Months == 0
gen ActualOverPredict3Months = Actual3Month/Predict3Months
replace ActualOverPredict3Months = 1 if Predict3Months == 0 & Actual3Months == 0
replace ActualOverPredict3Months = 999 if Predict3Months == 0 & Actual3Months != 0

gen PredictVsActual3MonthsDHS = (2*(Predict3Months - Actual3Months))/(Predict3Months + Actual3Months)
replace PredictVsActual3MonthsDHS = 1 if Predict3Months == 0 & Actual3Months == 0

// Calculate adjusted measure by giving them the benefit of the doubt if they
// Are within 1000 of the actual, and also round to the nearest 1000
gen Actual3MonthsAdj = Actual3Months
replace Actual3MonthsAdj = Predict3Months if abs(Actual3MonthsAdj - Predict3Months) < 1000
replace Actual3MonthsAdj = round(Actual3MonthsAdj, 1000)

// Recalculate ratios with adjusted numbers
gen PredictOverActual3MonthsAdj = Predict3Months/Actual3MonthsAdj
replace PredictOverActual3MonthsAdj = 1 if Predict3Months == 0 & Actual3MonthsAdj == 0
replace PredictOverActual3MonthsAdj = 999 if Predict3Months != 0 & Actual3MonthsAdj == 0
gen ActualOverPredict3MonthsAdj = Actual3MonthsAdj/Predict3Months
replace ActualOverPredict3MonthsAdj = 1 if Predict3Months == 0 & Actual3MonthsAdj == 0
replace ActualOverPredict3MonthsAdj = 999 if Predict3Months == 0 & Actual3MonthsAdj != 0


gen PredictVsActual3MonthsAdjDHS = (2*(Predict3Months - Actual3MonthsAdj))/(Predict3Months + Actual3MonthsAdj)
replace PredictVsActual3MonthsAdjDHS = 1 if Predict3Months == 0 & Actual3MonthsAdj == 0

*******************************************************************************
** Calculate the within 10%
*******************************************************************************
gen Actual3MonthsHigh = ceil((Actual3Months * 1.1)/1000)*1000
gen Actual3MonthsLow = floor((Actual3Months / 1.1)/1000)*1000
gen Within10 = (Predict3Months >= Actual3MonthsLow & Predict3Months <= Actual3MonthsHigh)

*******************************************************************************
** GRAPHING
*******************************************************************************
pretty (scatter Actual3Months Predict3Months if Within10 == 1 & Predict3Months!= 0, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3Months Predict3Months if Within10 == 0, xlogbase(`logbase') ylogbase(`logbase')) , ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Actual 3 Month Revenue") ///
    legend(label(1 "Within 10%") label(2 "Not Within 10%")) ///
    name("ActualVsPred3Month") save("`outdir'/ActualVsPred3Month.eps")

pretty (scatter Actual3MonthsAdj Predict3Months if Within10 == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3MonthsAdj Predict3Months if Within10 == 0, xlogbase(`logbase') ylogbase(`logbase')) , ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Actual 3 Month Revenue") ///
    legend(label(1 "Within 10%") label(2 "Not Within 10%")) ///
    name("ActualAdjVsPred3Month") save("`outdir'/ActualAdjVsPred3Month.eps")

local w = .25
local start = -2 - (`w'/2)
hist PredictVsActual3MonthsDHS, width(`w') start(`start') scheme(pretty1) frac ///
    name("PredictVsActual3MonthsDHS", replace)
graph export "`outdir'/PredictVsActual3MonthsDHS.eps", replace

hist PredictVsActual3MonthsAdjDHS, width(`w') start(`start') scheme(pretty1) frac ///
    name("PredictVsActual3MonthsAdjDHS", replace)
graph export "`outdir'/PredictVsActual3MonthsAdjDHS.eps", replace

*******************************************************************************
** Counts comparison
*******************************************************************************

gen Bigger = .
replace Bigger = 0 if Actual3MonthsAdj == Predict3Months
replace Bigger = 1 if Actual3MonthsAdj > Predict3Months
replace Bigger = -1 if Actual3MonthsAdj < Predict3Months

label define Bigger 0 "Within 1000" 1 "Actual > Predict + 1000" ///
    -1 "Actual < Predict - 1000"
label value Bigger Bigger
tab Bigger

estpost tabulate Bigger
esttab using "`outdir'/Bigger.tex" , ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    varlabels(, blist(Total "\hline "))      ///
    nonumber nomtitle noobs replace

*******************************************************************************
** Hists of ratio
*******************************************************************************
sum PredictOverActual3Months , detail

pretty (hist PredictOverActual3Months , xlogbase(1.2) frac) , ///
    name("PredictVsActual3Months") ///
    save("`outdir'/PredictVsActual3Months.eps") ///
    xtitle("Predicted Over Actual")

sum PredictOverActual3MonthsAdj , detail

pretty (hist PredictOverActual3MonthsAdj , xlogbase(1.2) frac) , ///
    name("PredictVsActual3MonthsAdj") ///
    save("`outdir'/PredictVsActual3MonthsAdj.eps") ///
    xtitle("Predicted Over Actual")

*******************************************************************************
** Logs?
*******************************************************************************
count if Bad3Months <= Actual3Months & Actual3Months <= Good3Months

count if Bad3Months <= ceil(Actual3Months/1000)*1000 ///
    & floor(Actual3Months/1000)*1000 <= Good3Months

count if ceil(Actual3Months/1000)*1000 < Bad3Months
count if floor(Actual3Months/1000)*1000 > Good3Months
count if Actual3Months > Good3Months

sort Actual3Months Bad3Months
gen plot_n = _n
pretty (scatter Actual3Months plot_n , ylogbase(1.2))
pretty (scatter Predict3Months plot_n , ylogbase(1.2))
pretty (scatter Bad3Months plot_n , ylogbase(1.2))
pretty (scatter Good3Months plot_n , ylogbase(1.2))

twoway (scatter Actual3Months plot_n if Actual3Months > 0) ///
     (scatter Bad3Months plot_n if Bad3Months > 0) ///
     (scatter Good3Months plot_n if Good3Months > 0) , yscale(log)




/*
pretty (scatter Actual3Month Predict3Months if Month == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3Month Predict3Months if Month == 2, xlogbase(`logbase') ylogbase(`logbase')), ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Estimated Actual 3 Month") ///
    legend(label(1 "January") label(2 "February")) ///
    name("ActualVsPred3Month") save("`outdir'/ActualVsPred3Month.eps")





pretty (scatter Actual3MonthAdj Predict3Months if Month == 1, xlogbase(`logbase') ylogbase(`logbase')) ///
    (scatter Actual3MonthAdj Predict3Months if Month == 2, xlogbase(`logbase') ylogbase(`logbase')), ///
    xtitle("Predicted 3 Month Revenue ") ytitle("Rounded Estimated Actual 3 Month") ///
    legend(label(1 "January") label(2 "February")) ///
    name("ActualAdjVsPred3Month") save("`outdir'/ActualAdjVsPred3Month.eps")

gen Range = Good3Month - Bad3Months
gen StdRange = Range / Predict3Months
replace StdRange = -777 if Predict3Months == 0 & Range != 0
replace StdRange = 0 if Predict3Months == 0 & Range == 0

winsor2 StdRange , cuts(0 95)
*/

*******************************************************************************
