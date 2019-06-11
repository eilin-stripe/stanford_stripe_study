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
local demographics = "`clean_internal'/Demographics.dta"

local outdir = "`output'/NickLunch"
local PredictionList = "`outdir'/PredictionResults.dta"
local logbase = 1.4

*******************************************************************************
** Set up Measures of How close they were
*******************************************************************************
* use "`prediction_check'"
use "`prediction_check'"

merge 1:1 ExternalReference  using "`demographics'"
keep if _merge == 3
drop _merge

merge 1:1 ExternalReference using "`Growth'"
keep if _merge == 3
drop _merge

replace Finished = 0 if Finished == .

gen LogLifetimeVolume = log(LifetimeVolume)
logit Finished i.Strata i.LegalType LogLifetimeVolume

tab LegalType , gen(LegalType_)
label variable LegalType_1 "Sole Proprietorship"
label variable LegalType_2 "Partnership"
label variable LegalType_3 "LLC"
label variable LegalType_4 "Corporation"
label variable LegalType_5 "Non-Profit"
label variable LogLifetimeVolume "log(Lifetime Volume)"

gen PrimaryIndustry2 = .
replace PrimaryIndustry2 = 1 if inlist(PrimaryIndustry, 0, 101)
replace PrimaryIndustry2 = 2 if inlist(PrimaryIndustry, 102, 109)
replace PrimaryIndustry2 = 3 if inlist(PrimaryIndustry, 112, 108)
replace PrimaryIndustry2 = 4 if inlist(PrimaryIndustry, 103)
replace PrimaryIndustry2 = 5 if inlist(PrimaryIndustry, 107)
replace PrimaryIndustry2 = 6 if inlist(PrimaryIndustry, 105, 110)
replace PrimaryIndustry2 = 7 if inlist(PrimaryIndustry, 104, 114)
replace PrimaryIndustry2 = 8 if inlist(PrimaryIndustry, 106, 111, 113, 115, 116, 117, 118)

gen Software = inlist(PrimaryIndustry, 0, 101)
gen Services = inlist(PrimaryIndustry, 102, 109, 103, 105, 110)
gen Retail = inlist(PrimaryIndustry, 108, 112)
gen OtherIndustry = inlist(PrimaryIndustry, 104, 106, 107, 111, 113, 114, 115, 116, 117, 118)

eststo clear
eststo Small : logit Finished LogLifetimeVolume LegalType_2-LegalType_5  ///
    Software Services Retail if Strata == 0
estadd ysumm

eststo Big : logit Finished LogLifetimeVolume LegalType_2-LegalType_5 ///
    Software Services Retail if Strata == 1
estadd ysumm

eststo Funded : logit Finished LogLifetimeVolume LegalType_2-LegalType_5 ///
    Software Services Retail if Strata == 2
estadd ysumm

eststo All: logit Finished LogLifetimeVolume LegalType_2-LegalType_5 ///
    Software Services Retail
estadd ysumm

esttab using "`outdir'/CompletionPredictors.tex", label replace ///
    nodepvar collabels(none) nonumbers noconstant b(%6.3f) se(%6.3f) ///
    stats(ymean N, fmt(%8.2f %8.0g) label("Response Rate" "Observations")) ///
    star(* 0.1 ** 0.05 *** 0.01)

replace PrimaryIndustry = -888 if inlist(PrimaryIndustry, 106, 111, 115, 116, 117, 118)
label define PrimaryIndustry -888 "Other", add
label define PrimaryIndustry 113 "Event Tickets", modify
replace PrimaryIndustry = 0 if PrimaryIndustry == 101
label define PrimaryIndustry 0 "Software & Content", modify
label define PrimaryIndustry 110 "Non-Med Prof. Services", modify

pretty_hist_horiz PrimaryIndustry , sort save("`outdir'/PrimaryIndustry.eps") ///
    name("PrimaryIndustry")  xtitle("")
* alignment(center)




*******************************************************************************
** Completion
*******************************************************************************


keep if Finished == 1

gen Actual3MonthsHigh = (Actual3Months * 1.1)
gen Actual3MonthsLow = (Actual3Months / 1.1)

gen Actual3MonthsHighRound = round(Actual3MonthsHigh, 1000)
gen Actual3MonthsLowRound = round(Actual3MonthsLow, 1000)
gen Within10_1 = (Predict3Months >= Actual3MonthsLow & Predict3Months <= Actual3MonthsHigh) if Finished == 1
gen Within10_round = (Predict3Months >= Actual3MonthsLowRound & Predict3Months <= Actual3MonthsHighRound) if Finished == 1
gen Within10_2 = Within10_1 | Within10_round if Finished == 1
gen Within10_1000 = (Actual3Months <= 1000) & (Predict3Months == 1000 | Predict3Months == 0) if Finished == 1
gen Within10_3 = Within10_1 | Within10_round | Within10_1000 if Finished == 1

gen Winner = 0
replace Winner = 1 if Within10_2 == 1

gen Actual3MonthsAdj = round(Actual3Months, 1000)

*******************************************************************************
** Counts comparison
*******************************************************************************
gen Bigger = .
replace Bigger = 0 if Actual3MonthsAdj == Predict3Months
replace Bigger = 1 if Actual3MonthsAdj > Predict3Months
replace Bigger = -1 if Actual3MonthsAdj < Predict3Months
replace Bigger = -2 if Actual3MonthsAdj < Bad3Months
replace Bigger = 2 if Actual3MonthsAdj > Good3Months

label define Bigger -2 "< Worst" -1 "< Predict"  ///
    0 "= Predict" 1 "> Predict" ///
    2 "> Best"
label value Bigger Bigger
tab Bigger

estpost tabulate Bigger
esttab using "`outdir'/Bigger.tex" , ///
    cells("b(label(freq)) pct(fmt(2)) cumpct(fmt(2))") ///
    varlabels(, blist(Total "\hline "))      ///
    nonumber nomtitle noobs replace

*******************************************************************************
**
*******************************************************************************
gen PullDate = date("5/9/2019", "MDY")
gen DateDif = PullDate - ActivationDate
gen Denom = .
replace Denom = 365 if DateDif > 365
replace Denom = DateDif if DateDif <= 365

gen PrevMonthlyRev = (LastYearRevenue / Denom) * (30/100)
gen PrevAnnualRev = 12 * PrevMonthlyRev
gen PrevMonthlyTrans = (LastYearTrans / Denom) * (30/100)

local numbox = 5
*xtile DateTile = ActivationDate , nquantiles(`numbox')
xtile DateTile = FirstSaleYear , nquantiles(`numbox')
xtile RevTile = PrevMonthlyRev , nquantiles(`numbox')
xtile TransTile = PrevMonthlyTrans , nquantiles(`numbox')
xtile Growth1Tile = Growth1 , nquantiles(`numbox')
xtile Growth12Tile = Growth12 , nquantiles(`numbox')
xtile Growth12QuarterTile = Growth12Quarter , nquantiles(`numbox')

xtile AgeTile = Age , nquantiles(`numbox')
sum Age
local min = r(min)
local max = r(max)
_pctile Age , nquantiles(`numbox')
local Age1 = r(r1)
local Age2 = r(r2)
local Age3 = r(r3)
local Age4 = r(r4)
label define AgeTile 1 "< `Age1'" 2 "`Age1' to `Age2'" 3 "`Age2' to `Age3'" ///
    4 "`Age3' to `Age4'" 5 "`Age4'+"
label values AgeTile AgeTile

gen DaysToComplete = EndDate - DateSent
gen DaysToComplete2 = .
replace DaysToComplete2 = 0 if DaysToComplete == 0
replace DaysToComplete2 = 1 if inlist(DaysToComplete, 1, 2)
replace DaysToComplete2 = 2 if inlist(DaysToComplete, 3, 4)
replace DaysToComplete2 = 3 if inlist(DaysToComplete, 5, 6)
replace DaysToComplete2 = 4 if DaysToComplete >= 7
label define DaysToComplete 0 "0 Days" 1 "1 to 2 Days" 2 "3 to 4 Days" ///
    3 "5 to 6 Days" 4 "7+ Days"
label values DaysToComplete2 DaysToComplete


gen Out = abs(Bigger)

gen Over = 0
replace Over = 1 if Actual3MonthsAdj > Good3Months

gen Below = 0
replace Below = 1 if Actual3MonthsAdj < Bad3Months

gen OutOfRange = 0
replace OutOfRange = 1 if Over | Below

sort RevTile
by RevTile: egen MeanOverRev = mean(Over)
by RevTile: egen MeanBelowRev = mean(Below)
by RevTile: egen MeanOutOfRangeRev = mean(OutOfRange)
egen RevTileTag = tag(RevTile)

sort TransTile
by TransTile: egen MeanOverTrans = mean(Over)
by TransTile: egen MeanBelowTrans = mean(Below)
by TransTile: egen MeanOutOfRangeTrans = mean(OutOfRange)
egen TransTileTag = tag(TransTile)

sort DateTile
by DateTile: egen MeanOverDate = mean(Over)
by DateTile: egen MeanBelowDate = mean(Below)
by DateTile: egen MeanOutOfRangeDate = mean(OutOfRange)
egen DateTileTag = tag(DateTile)

sort AgeTile
by AgeTile: egen MeanOverAge = mean(Over)
by AgeTile: egen MeanBelowAge = mean(Below)
by AgeTile: egen MeanOutOfRangeAge = mean(OutOfRange)
egen AgeTileTag = tag(AgeTile)

sort PreviousBusinesses
by PreviousBusinesses: egen MeanOverDatePrevBus = mean(Over)
by PreviousBusinesses: egen MeanBelowDatePrevBus = mean(Below)
by PreviousBusinesses: egen MeanOutOfRangeDatePrevBus = mean(OutOfRange)
egen PreviousBusinessesTag = tag(PreviousBusinesses)


*******************************************************************************
** Prediction Accuracy Vs. Experience
*******************************************************************************
local N = _N
expand 2
gen byte new = _n > `N'
replace Strata = -1 if new
label def Strata -1 "All", add

graph drop _all
graph hbar , over(Founder, descending) asyvars stack over(Strata) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(2) order(2 "Yes" 1 "No")) ///
    bar(1, color(ebblue)) bar(2, color(eltblue)) ///
    ytitle("")
graph rename StrataFounder, replace
graph export "`outdir'/StrataFounder.eps", replace

graph hbar , over(Bigger) asyvars stack over(Strata) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("")
graph rename StrataAccuracy, replace
graph export "`outdir'/StrataAccuracy.eps", replace

drop if Strata == -1


graph hbar , over(Bigger) asyvars stack over(Education, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("")
graph rename EducationAccuracy, replace
graph export "`outdir'/EducationAccuracy.eps", replace

graph hbar if inlist(Female, 0, 1), over(Bigger) asyvars stack over(Female) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("")
graph rename FemaleAccuracy, replace
graph export "`outdir'/FemaleAccuracy.eps", replace


graph hbar , over(Bigger) asyvars stack over(PreviousBusinesses, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle(Prior Businesses) b1title("")
graph rename PreviousBusinessAccuracy, replace
graph export "`outdir'/PreviousBusinessAccuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(AgeTile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Owner Age Quintiles")
graph rename AgeAccuracy, replace
graph export "`outdir'/AgeAccuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(DateTile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Firm Age Quintiles")
graph rename DateAccuracy, replace
graph export "`outdir'/DateAccuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(RevTile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Revenue Quintiles")
graph rename RevenueAccuracy, replace
graph export "`outdir'/RevenueAccuracy.eps", replace


graph hbar, over(Bigger) asyvars stack over(DaysToComplete2, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Days to Complete")
graph rename DaysToCompleteAccuracy, replace
graph export "`outdir'/DaysToCompleteAccuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(DateSent, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("DateSent")
graph rename DateSentAccuracy, replace
graph export "`outdir'/DateSentAccuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(Growth12Tile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Year-On-Year Growth")
graph rename Growth12Accuracy, replace
graph export "`outdir'/Growth12Accuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(Growth1Tile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Prior Month Growth")
graph rename Growth1Accuracy, replace
graph export "`outdir'/Growth1Accuracy.eps", replace

graph hbar , over(Bigger) asyvars stack over(Growth12QuarterTile, descending) percent ///
    scheme(pretty1) legend( region(lwidth(none)) col(5) stack) ///
    bar(1, color(edkblue)) bar(2, color(ebblue)) ///
    bar(3, color(eltblue)) bar(4, color(lavender)) ///
    bar(5, color(purple)) ytitle("") title("Year-On-Year Growth")
graph rename Growth12QuarterAccuracy, replace
graph export "`outdir'/Growth12QuarterAccuracy.eps", replace

*******************************************************************************
**
*******************************************************************************

matrix define Means = J(`numbox',`numbox',.)

forvalues ii = 1/`numbox' {
    forvalues jj = 1/`numbox' {
        sum Out if AgeTile == `ii' & RevTile == `jj'
        matrix Means[6-`jj', `ii'] = r(mean)
    }
}

plotmatrix, mat(Means) split(0(.1)1.7) color(eltblue) aspect(1) ///
    xtitle("Founder Age Quintile") ytitle("Revenue Quintile") ///
    title("Estimation Accuracy by " "Age and Revenue on Stripe")  ///
    name("AgeRevenueHeatmap", replace) ///
    legend( region(lcolor(white)) position(3) col(1)) ///
    ylabel(0 "5" -1 "4" -2 "3" -3 "2" -4 "1",angle(0)) xlabel(1(1)`numbox', angle(0))
graph export "`outdir'/AgeRevenueHeatmap.eps", replace

forvalues ii = 1/`numbox' {
    forvalues jj = 1/`numbox' {
        sum Out if DateTile == `ii' & RevTile == `jj'
        matrix Means[6-`jj', `ii'] = r(mean)
    }
}

plotmatrix, mat(Means) split(0(.1)2) color(eltblue) aspect(1) ///
    xtitle("Firm Age Quintile") ytitle("Revenue Quintile") ///
    title("Estimation Accuracy by " "Firm Age and Revenue on Stripe") ///
    name("DateRevenueHeatmap", replace) ///
    legend( region(lcolor(white)) position(3) col(1)) ///
    ylabel(0 "5" -1 "4" -2 "3" -3 "2" -4 "1",angle(0)) xlabel(1(1)`numbox', angle(0))
graph export "`outdir'/DateRevenueHeatmap.eps", replace

matrix define Means = J(`numbox',6, .)
forvalues ii = 0/5 {
    forvalues jj = 1/`numbox' {
        sum Out if PreviousBusinesses == `ii' & RevTile == `jj'
        matrix Means[6-`jj', `ii'+1] = r(mean)
    }
}

plotmatrix, mat(Means) split(0(.1)2) color(eltblue) aspect(1) ///
    xtitle("# Prior Businesses") ytitle("Revenue Quintile") ///
    title("Estimation Accuracy by Prior" "Businesses and Rev. on Stripe") ///
    name("PrevBusRevenueHeatmap", replace) ///
    legend( region(lcolor(white)) position(3) col(1)) ///
    ylabel(0 "5" -1 "4" -2 "3" -3 "2" -4 "1",angle(0)) xlabel(1 "0" 2 "1" 3 "2" 4 "3" 5 "4" 6 "5+", angle(0))
graph export "`outdir'/PrevBusRevenueHeatmap.eps", replace



forvalues ii = 1/`numbox' {
    forvalues jj = 1/`numbox' {
        sum Out if Growth12QuarterTile == `ii' & RevTile == `jj'
        matrix Means[6-`jj', `ii'] = r(mean)
    }
}

plotmatrix, mat(Means) split(0(.1)1.7) color(eltblue) aspect(1) ///
    xtitle("Growth Quintile") ytitle("Revenue Quintile") ///
    title("Estimation Accuracy by " "Growth and Revenue on Stripe")  ///
    name("Growth12QuarterRevenueHeatmap", replace) ///
    legend( region(lcolor(white)) position(3) col(1)) ///
    ylabel(0 "5" -1 "4" -2 "3" -3 "2" -4 "1",angle(0)) xlabel(1(1)`numbox', angle(0))
graph export "`outdir'/Growth12QuarterRevenueHeatmap.eps", replace

forvalues ii = 1/`numbox' {
    forvalues jj = 1/`numbox' {
        sum Bigger if Growth12QuarterTile == `ii' & RevTile == `jj'
        matrix Means[6-`jj', `ii'] = r(mean)
    }
}

plotmatrix, mat(Means) split(-2(.2)2) color(eltblue) aspect(1) ///
    xtitle("Growth Quintile") ytitle("Revenue Quintile") ///
    title("Estimation Accuracy by " "Growth and Revenue on Stripe")  ///
    name("Growth12QuarterRevenueHeatmap", replace) ///
    legend( region(lcolor(white)) position(3) col(1)) ///
    ylabel(0 "5" -1 "4" -2 "3" -3 "2" -4 "1",angle(0)) xlabel(1(1)`numbox', angle(0))
graph export "`outdir'/Growth12QuarterRevenueHeatmap.eps", replace


/*


gen Range = Good3Month - Bad3Months
gen StdRange = Range / Predict3Months
replace StdRange = -777 if Predict3Months == 0 & Range != 0
replace StdRange = 0 if Predict3Months == 0 & Range == 0

winsor2 StdRange , cuts(0 95)

pretty (scatter StdRange_w Predict3Months , xlogbase(2) ) , ///
    xtitle("Predicted 3 Month Revenue") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsPred3Month") save("`outdir'/RangeVsPred3Month.eps")

pretty (scatter StdRange_w PrevMonthlyRev , xlogbase(2) ) , ///
    xtitle("Predicted 3 Month Revenue") ///
    ytitle("Normalized Prediction Range") ///
    name("RangeVsPred3Month") save("`outdir'/RangeVsPred3Month.eps")







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


gen FirmAge = 2018 - FirstSaleYear
replace FirmAge = -777 if FirstSaleYear == -777

gen FirmAge2 = FirmAge
replace FirmAge2 = 6 if inlist(FirmAge, 6, 7, 8, 9, 10)
replace FirmAge2 = 7 if inlist(FirmAge, 11, 12, 13, 14, 15)
replace FirmAge2 = 8 if inlist(FirmAge, 16, 17, 18, 19, 20)
replace FirmAge2 = 9 if inlist(FirmAge, 21, 22, 23, 24, 25)
replace FirmAge2 = 10 if FirmAge >= 26 & FirmAge <= 40
replace FirmAge2 = 11 if FirmAge >= 41 & FirmAge != .
replace FirmAge2 = . if FirmAge == .

label define BusAge 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6 to 10" ///
    7 "11 to 15" 8 "16 to 20" 9 "21 to 25" 10 "26 to 40" 11 "41+"

label values FirmAge2 BusAge

twoway (hist FirmAge2 if FirmAge2 >= 0, discrete) , name("Age2", replace) ///
    xlabel( 0(1)10, valuelabel angle(45)) scheme(pretty1) xtitle("Firm Age")
graph export "`outdir'/FirmAgeCompareBDS.eps", replace
*/









*******************************************************************************
** Old TwoWay plots
*******************************************************************************
/*
twoway (scatter MeanOverRev RevTile if RevTileTag == 1 ) ///
    (scatter MeanBelowRev RevTile if RevTileTag == 1 ) ///
    (scatter MeanOutOfRangeRev RevTile if RevTileTag == 1 ) , ///
    xtitle("Monthly Revenue Deciles") ///
    ytitle("% Prediction Outside of Range") ///
    scheme(pretty1) name("PercOutVsRev", replace)
graph export "`outdir'/OutOfRangeVsRev.eps", replace


twoway (scatter MeanOverTrans TransTile if TransTileTag == 1 ) ///
    (scatter MeanBelowTrans TransTile if TransTileTag == 1 ) ///
    (scatter MeanOutOfRangeTrans TransTile if TransTileTag == 1 ) , ///
    xtitle("Monthly Transaction Deciles") ///
    ytitle("% Prediction Outside of Range") ///
    scheme(pretty1) name("PercOutVsTrans", replace)
graph export "`outdir'/OutOfRangeVsTrans.eps", replace

twoway (scatter MeanOverDate DateTile if DateTileTag == 1 ) ///
    (scatter MeanBelowDate DateTile if DateTileTag == 1 ) ///
    (scatter MeanOutOfRangeDate DateTile if DateTileTag == 1 ) , ///
    xtitle("Activation Date Deciles") ///
    ytitle("% Prediction Outside of Range") ///
    scheme(pretty1) name("PercOutVsDate", replace)
graph export "`outdir'/OutOfRangeVsDate.eps", replace

twoway (scatter MeanOverAge AgeTile if AgeTileTag == 1 ) ///
    (scatter MeanBelowAge AgeTile if AgeTileTag == 1 ) ///
    (scatter MeanOutOfRangeAge AgeTile if AgeTileTag == 1 ) , ///
    xtitle("Age Deciles") ///
    ytitle("% Prediction Outside of Range") ///
    scheme(pretty1) name("PercOutVsAge", replace)
graph export "`outdir'/OutOfRangeVsAge.eps", replace

twoway (scatter MeanOverDatePrevBus PreviousBusinesses if PreviousBusinessesTag == 1 & PreviousBusinesses >= 0) ///
    (scatter MeanBelowDatePrevBus PreviousBusinesses if PreviousBusinessesTag == 1 & PreviousBusinesses >= 0) ///
    (scatter MeanOutOfRangeDatePrevBus PreviousBusinesses if PreviousBusinessesTag == 1 & PreviousBusinesses >= 0) , ///
    xtitle("# of Previous Businesses") ///
    ytitle("% Prediction Outside of Range") ///
    scheme(pretty1) name("PercOutVsPrevBus", replace)
graph export "`outdir'/OutOfRangeVsPrevBus.eps", replace

pretty (hist PrevAnnualRev , xlogbase(1.8) zeros(1) frac), ///
    xtitle("Annual Revenue") name("AnnualRev")  ///
    save("`outdir'/PrevAnnualRev.eps")
*/

*******************************************************************************
**
*******************************************************************************
