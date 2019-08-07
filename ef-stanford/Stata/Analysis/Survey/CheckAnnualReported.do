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
include `base'/Code/Stata/file_header.do

** Load in the Stripe Panel data
local survey = "`clean_survey'/Survey.dta"
local main = "`clean_survey'/Main.dta"

local outdir = "`output'/ReportedVsActual"
*******************************************************************************
** Stats
*******************************************************************************
use "`main'", replace

rename TotalRev RevLast12Months
replace RevLast12Months = RevLast12Months / 100
gen RevPast12MonthsAdj = (RevPast12Months * 1000)

pretty (hist RevLastMonth , xlogbase(1.2) zeros(1)) , ///
    name("ActualRev") save("`outdir'/ActualRev.eps")
pretty (hist RevPastMonthAdj , xlogbase(1.2) zeros(1)), ///
    name("ReportedRev") save("`outdir'/ReportedRev.eps")

// Round to the nearest thousand, so if you earned $600 you can enter a 1 into the box
gen RevLastMonthAdj = RevLastMonth
replace RevLastMonthAdj = RevPastMonthAdj if abs(RevLastMonthAdj - RevPastMonthAdj) < 1000
replace RevLastMonthAdj = round(RevLastMonthAdj, 1000)
pretty (hist RevLastMonthAdj , xlogbase(1.2) zeros(1) ), ///
    name("RoundedActualRev") save("`outdir'/RoundedActualRev.eps")

gen OrdersOff2 = RevLastMonthAdj / RevPastMonthAdj
replace OrdersOff2 = 1 if RevLastMonth == 0 & RevPastMonth == 0
replace OrdersOff2 = -777 if RevLastMonth != 0 & RevPastMonth == 0

gen OrdersOff = RevPastMonthAdj / RevLastMonthAdj
replace OrdersOff = 1 if RevLastMonth == 0 & RevPastMonth == 0
replace OrdersOff = -777 if RevLastMonth == 0 & RevPastMonth != 0


gen Quarterly =  RevLastMonth * 3
replace Quarterly = RevPastMonthAdj if abs(Quarterly - RevPastMonthAdj) < 1000
replace Quarterly = round(Quarterly, 1000)

gen Ten =  RevLastMonth * 10
replace Ten = RevPastMonthAdj if abs(Ten - RevPastMonthAdj) < 1000
replace Ten = round(Ten, 1000)

gen Annual =  RevLastMonth * 12
replace Annual = RevPastMonthAdj if abs(Annual - RevPastMonthAdj) < 1000
replace Annual = round(Annual, 1000)

gen OrdersOff3 = RevPastMonthAdj / RevLastMonth
replace OrdersOff = 1 if RevLastMonth == 0 & RevPastMonth == 0
replace OrdersOff = -777 if RevLastMonth == 0 & RevPastMonth != 0

pretty (hist OrdersOff , xlogbase(1.2) zeros(1) ), ///
    name("Ratio") save("`outdir'/Ratio.eps")

replace RevLastMonthAdj = RevLastMonthAdj / 1000
replace RevPastMonthAdj = RevPastMonthAdj / 1000
replace Quarterly = Quarterly / 1000
replace Ten = Ten / 1000
replace Annual = Annual / 1000

pretty (scatter RevLastMonthAdj RevPastMonthAdj, xlogbase(1.2) ylogbase(1.2)) ///
    , xtitle("Reported Revenue Last Month") ///
    ytitle("Observed Revenue Last Month") ///
    title("Observed vs. Reported Revenue Last Month") ///
    name("ObsVsRepLastMonth") save("`outdir'/ObsVsRepLastMonth.eps")

pretty (scatter RevLastMonthAdj RevPastMonthAdj ///
    if !((Quarterly == RevPastMonthAdj | Ten == RevPastMonthAdj ///
        | Annual == RevPastMonthAdj) & RevLastMonthAdj != RevPastMonthAdj)  ///
    , xlogbase(1.2) ylogbase(1.2)) ///
    , xtitle("Reported Revenue Last Month") ///
    ytitle("Observed Revenue Last Month") ///
    title("Observed vs. Reported Revenue Last Month") ///
    name("ObsVsRepLastMonthDrop") save("`outdir'/ObsVsRepLastMonthDrop.eps")

 br OrdersOff if OrdersOff > 2 & OrdersOff != .
/*
 pretty (scatter RevLastMonthAdj RevPastMonthAdj ///
     if OrdersOff < 2  ///
     , xlogbase(1.2) ylogbase(1.2)) ///
     , xtitle("Reported Revenue Last Month") ///
     ytitle("Observed Revenue Last Month") ///
     title("Observed vs. Reported Revenue Last Month") ///
     name("ObsVsRepLastMonthDrop2")







*******************************************************************************
