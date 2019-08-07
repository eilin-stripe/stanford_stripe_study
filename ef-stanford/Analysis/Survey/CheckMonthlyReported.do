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
local survey = "`clean_main_survey'/Survey.dta"
local main = "`clean_main_survey'/Main.dta"

local outdir = "`output'/ReportedVsActual"

* local period = "Month"
local period = "12Months"

if "`period'" == "Month" {
    local logbase = 1.2
}
else if "`period'" == "12Months" {
    local logbase = 1.4
}
*******************************************************************************
** Stats
*******************************************************************************
use "`main'", replace
keep if Finished == 1
keep *Rev* *Date*

// Convert Stripe numbers from dollars to cents
rename TotalRev RevLast12Months
replace RevLast12Months = RevLast12Months / 100

replace DecRev = DecRev / 100
replace JanRev = JanRev / 100
replace FebRev = FebRev / 100

// set the last month revenue based on what month they completed the survey
gen EndMonth = month(EndDate)
gen StartMonth = month(StartDate)
gen Month = .
replace Month = EndMonth if StartMonth == EndMonth

gen RevLastMonth = .
replace RevLastMonth = JanRev if Month == 2
replace RevLastMonth = DecRev if Month == 1

// Convert the reported values from thousands of dollars to dollars
gen RevPastMonthAdj = (RevPastMonth * 1000)
replace PercRevStripe = PercRevStripe * 100 if PercRevStripe > 0 & PercRevStripe <= 1
gen RevPast12MonthsAdj = (RevPast12Months * (PercRevStripe / 100)* 1000)


*******************************************************************************
** We have some uncertainty over which month they responded to. Get rid of obs
** with uncertainty
*******************************************************************************
/*
keep if inlist(Month, 1, 2)
*/
*******************************************************************************
**
*******************************************************************************


pretty (hist RevLast`period' , frac xlogbase(`logbase') zeros(1)) , ///
    name("ActualRev`period'") save("`outdir'/ActualRev`period'.eps")
pretty (hist RevPast`period'Adj , frac xlogbase(`logbase') zeros(1)), ///
    name("ReportedRev`period'") save("`outdir'/ReportedRev`period'.eps")

// Round to the nearest thousand, so if you earned $600 you can enter a 1 into the box
gen RevLast`period'Adj = RevLast`period'
replace RevLast`period'Adj = RevPast`period'Adj if abs(RevLast`period'Adj - RevPast`period'Adj) < 1000
replace RevLast`period'Adj = round(RevLast`period'Adj, 1000)
replace RevPast`period'Adj = round(RevPast`period'Adj, 1000)
pretty (hist RevLast`period'Adj , xlogbase(`logbase') zeros(1) ), ///
    name("RoundedActual`period'Rev") save("`outdir'/RoundedActual`period'Rev.eps")
pretty (hist RevPast`period'Adj , xlogbase(`logbase') zeros(1) ), ///
    name("RoundedReported`period'Rev") save("`outdir'/RoundedReported`period'Rev.eps")


gen OrdersOff2 = RevLast`period'Adj / RevPast`period'Adj
replace OrdersOff2 = 1 if RevLast`period' == 0 & RevPast`period' == 0
replace OrdersOff2 = -777 if RevLast`period' != 0 & RevPast`period' == 0

gen OrdersOff = RevPast`period'Adj / RevLast`period'Adj
replace OrdersOff = 1 if RevLast`period' == 0 & RevPast`period' == 0
replace OrdersOff = -777 if RevLast`period' == 0 & RevPast`period' != 0

if "`period'" == "Month" {
    gen Quarterly =  RevLast`period' * 3
    replace Quarterly = RevPast`period'Adj if abs(Quarterly - RevPast`period'Adj) < 1000
    replace Quarterly = round(Quarterly, 1000)

    gen Ten =  RevLast`period' * 10
    replace Ten = RevPast`period'Adj if abs(Ten - RevPast`period'Adj) < 1000
    replace Ten = round(Ten, 1000)

    gen Annual =  RevLast`period' * 12
    replace Annual = RevPast`period'Adj if abs(Annual - RevPast`period'Adj) < 1000
    replace Annual = round(Annual, 1000)
}

pretty (hist OrdersOff , xlogbase(`logbase') zeros(1) ), ///
    name("Ratio`period'") save("`outdir'/Ratio`period'.eps")

replace RevLast`period'Adj = RevLast`period'Adj / 1000
replace RevPast`period'Adj = RevPast`period'Adj / 1000

if "`period'" == "Month" {
    replace Quarterly = Quarterly / 1000
    replace Ten = Ten / 1000
    replace Annual = Annual / 1000
}

pretty (scatter RevLast`period'Adj RevPast`period'Adj, xlogbase(`logbase') ylogbase(`logbase')) ///
    , xtitle("Reported Revenue") ///
    ytitle("Observed Revenue") ///
    title("Observed vs. Reported Revenue") ///
    name("ObsVsRepLast`period'") save("`outdir'/ObsVsRepLast`period'.eps")


if "`period'" == "Month" {
    pretty (scatter RevLast`period'Adj RevPast`period'Adj ///
        if !((Quarterly == RevPast`period'Adj | Ten == RevPast`period'Adj ///
            | Annual == RevPast`period'Adj) & RevLast`period'Adj != RevPast`period'Adj)  ///
        , xlogbase(`logbase') ylogbase(`logbase')) ///
        , xtitle("Reported Revenue") ///
        ytitle("Observed Revenue") ///
        title("Observed vs. Reported Revenue") ///
        name("ObsVsRepLast`period'Drop") save("`outdir'/ObsVsRepLast`period'Drop.eps")
}


 br OrdersOff if (OrdersOff > 2 | OrdersOff < .5) & OrdersOff != .
/*
 pretty (scatter RevLastMonthAdj RevPastMonthAdj ///
     if OrdersOff < 2  ///
     , xlogbase(1.2) ylogbase(1.2)) ///
     , xtitle("Reported Revenue Last Month") ///
     ytitle("Observed Revenue Last Month") ///
     title("Observed vs. Reported Revenue Last Month") ///
     name("ObsVsRepLastMonthDrop2")







*******************************************************************************
