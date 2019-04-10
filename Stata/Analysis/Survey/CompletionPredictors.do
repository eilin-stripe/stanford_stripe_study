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
local demographics = "`clean_internal'/Demographics.dta"
local sample = "`clean_sampling'/Sample.dta"
local main = "`clean_main_survey'/Main.dta"
local history0 = "`clean_conversion'/HistoryWave0.dta"
local history1 = "`clean_conversion'/HistoryWave1.dta"
local history2 = "`clean_conversion'/HistoryWave2.dta"

local responsedatacsv = "`clean_conversion'/ResponseData.csv"
local responsedata = "`clean_conversion'/ResponseData.dta"

*******************************************************************************
**
*******************************************************************************
use "`sample'"
merge 1:1 ExternalReference using "`history2'", keep(1 3)
drop _merge
merge 1:1 ExternalReference using "`history1'", keep(1 3)
drop _merge

merge 1:1 ExternalReference  using "`demographics'"
drop _merge

keep if inlist(Wave , 2)

replace Email = strlower(Email)
gen InfoDummy = regexm(Email, "info")
gen ServiceDummy = regexm(Email, "service")
gen CustomerDummy = regexm(Email, "customer")
gen SupportDummy = regexm(Email, "support")
gen AdminDummy = regexm(Email, "admin")
gen ContactDummy = regexm(Email, "contact")
gen PaymentDummy = regexm(Email, "payment")
gen MarketingDummy = regexm(Email, "marketing")
gen BillingDummy = regexm(Email, "billing")
gen SalesDummy = regexm(Email, "sales")
gen AccountingDummy = regexm(Email, "accounting")
gen AccountsDummy = regexm(Email, "accounts")

egen Generic = rowmax(*Dummy)

gen Generic2 = 0
replace Generic2 = 1 if (AdminDummy == 1 | ContactDummy == 1 | SalesDummy == 1)


sort PrimaryIndustry
by PrimaryIndustry: gen PrimaryIndustryCount = _N

replace PrimaryIndustry = 100 if PrimaryIndustryCount < 100

gen LogLifetimeVolume = log(1 + LifetimeVolume)

sum LastChargeDate
local LastDate = r(max)
gen DaysSinceCharge = `LastDate' - LastChargeDate
gen DaysSinceFirstCharge = `LastDate' - FirstChargeDate

*******************************************************************************
** Time Since last Sale
*******************************************************************************
gen TimeGroups = .
replace TimeGroups = DaysSinceCharge if DaysSinceCharge < 7
replace TimeGroups = 7 if DaysSinceCharge >= 7 & DaysSinceCharge < 14
replace TimeGroups = 8 if DaysSinceCharge >= 14 & DaysSinceCharge < 21
replace TimeGroups = 9 if DaysSinceCharge >= 21 & DaysSinceCharge < 30
replace TimeGroups = 10 if DaysSinceCharge >= 30 & DaysSinceCharge < 60
replace TimeGroups = 11 if DaysSinceCharge >= 60 & DaysSinceCharge < 90
replace TimeGroups = 12 if DaysSinceCharge >= 90 & DaysSinceCharge < 180
replace TimeGroups = 13 if DaysSinceCharge >= 180 & DaysSinceCharge < 270
replace TimeGroups = 14 if DaysSinceCharge >= 270 & DaysSinceCharge < 365
replace TimeGroups = 15 if DaysSinceCharge >= 365 & DaysSinceCharge < 730
replace TimeGroups = 16 if DaysSinceCharge >= 730

label define TimeGroups 1 "1 Day" 2 "2 Days" 3 "3 Days" 4 "4 Days" ///
    5 "5 Days" 6 "6 Days" 7 "1 Week" 8 "2 Weeks" 9 "3 Weeks" ///
    10 "1 Month" 11 "2 Months" 12 "1 Quarter" 13 "2 Quarters" ///
    14 "3 Quarters" 15 "1 Year " 16 "2 Years"

label values TimeGroups TimeGroups

sort TimeGroups
by TimeGroups : egen MeanFinishedGroups= mean(Finished)

*******************************************************************************
** Conversion Analysis
*******************************************************************************
foreach variable of varlist LegalType TimeGroups {
    egen `variable'Tag = tag(`variable')
    sort `variable'

    by `variable': egen `variable'_Total = total(Sent)
    by `variable': egen `variable'_TotalDelivered = total(Delivered)
    by `variable': egen `variable'_TotalOpened = total(Opened)
    by `variable': egen `variable'_TotalStarted = total(Started)
    by `variable': egen `variable'_TotalFinished = total(Finished)
    by `variable': egen `variable'_TotalOptedOut = total(OptedOut)
    by `variable': egen `variable'_TotalBlocked = total(Blocked)
    by `variable': egen `variable'_TotalBounced = total(Bounced)

    by `variable': gen `variable'_TotalConversion = (`variable'_Total / `variable'_Total)*100
    by `variable': gen `variable'_DeliveredConversion = ((`variable'_Total - `variable'_TotalBlocked - `variable'_TotalBounced) / `variable'_Total)*100
    by `variable': gen `variable'_DidntOptOutConversion = ((`variable'_Total - `variable'_TotalOptedOut) / (`variable'_Total - `variable'_TotalBlocked - `variable'_TotalBounced) )*100
    * by `variable': gen `variable'_DeliveredConversion = (TotalDelivered / Total) * 100
    by `variable': gen `variable'_OpenedConversion = (`variable'_TotalOpened / `variable'_TotalDelivered) * 100
    by `variable': gen `variable'_StartedConversion = (`variable'_TotalStarted / `variable'_TotalOpened ) *  100
    by `variable': gen `variable'_FinishedConversion = (`variable'_TotalFinished / `variable'_TotalStarted) * 100

    by `variable': gen `variable'_TotalRate = (`variable'_Total / `variable'_Total)*100
    by `variable': gen `variable'_DeliveredRate = ((`variable'_Total - `variable'_TotalBounced - `variable'_TotalBlocked) / `variable'_Total) * 100
    by `variable': gen `variable'_DidntOptOutRate = ((`variable'_Total - `variable'_TotalOptedOut) / `variable'_Total) * 100
    by `variable': gen `variable'_OpenedRate = (`variable'_TotalOpened / `variable'_Total) * 100
    by `variable': gen `variable'_StartedRate = (`variable'_TotalStarted / `variable'_Total) *  100
    by `variable': gen `variable'_FinishedRate = (`variable'_TotalFinished / `variable'_Total) * 100


    format *Conversion *Rate %4.2f

/*
    preserve

    keep `variable' `variable'_*Conversion `variable'_*Rate ExternalReference

    rename `variable'_*Rate *Rate
    rename `variable'_*Conversion *Conversion
    rename *Rate *1
    rename *Conversion *2

    reshape long Total Delivered DidntOptOut Opened Started Finished, i(ExternalReference) j(type)

    sort `variable' type

    eststo clear
    by `variable' type : eststo: quietly estpost summarize Total Delivered DidntOptOut Opened Started Finished , listwise

    sort type
    by type : eststo: quietly estpost summarize Total Delivered DidntOptOut Opened Started Finished , listwise

    esttab using "`output'/Conversion/ConversionRatesWave_`variable'.html", ///
        cells("mean(fmt(2))") label nodepvar replace collabels(none) ///
        varlabels(Total "Sent Email" ///
                    Delivered "Received Email" ///
                    DidntOptOut "Did Not Opt Out" ///
                    Opened "Opened Email" ///
                    Started "Clicked Link" ///
                    Finished "Finished" ///
            ) width(60%) nonumbers alignment(center) ///
            mtitles("Small <br/> Rate" "Small <br/> Conversion" ///
                "Big <br/> Rate" "Big <br/> Conversion" ///
                "Funded <br/> Rate" "Funded <br/> Conversion" ///
                "Total <br/> Rate" "Total <br/> Conversion")

    restore
*/


    sum `variable'
    local max_`variable' = r(max)

    pretty (scatter `variable'_FinishedRate `variable' if `variable'Tag == 1 , ///
        xlabel(1/`max_`variable'', angle(forty_five) valuelabel) ) , ///
        xtitle("Time Since Last Charge") ytitle("Finished %") ///
        name("FinishVs`variable'") ///
        save("`output'/Predictors/FinishVs`variable'.eps")

    pretty (scatter `variable'_OpenedConversion `variable' if `variable'Tag == 1 , ///
        xlabel(1/`max_`variable'', angle(forty_five) valuelabel) ) , ///
        xtitle("Time Since Last Charge") ytitle("Opened Conversion Rate") ///
        name("OpenedConversionVs`variable'") ///
        save("`output'/Predictors/OpenedConversionVs`variable'.eps")

    pretty (scatter `variable'_StartedConversion `variable' if `variable'Tag == 1 , ///
        xlabel(1/`max_`variable'', angle(forty_five) valuelabel) ) , ///
        xtitle("Time Since Last Charge") ytitle("Started Conversion Rate") ///
        name("StartedConversionVs`variable'") ///
        save("`output'/Predictors/StartedConversionVs`variable'.eps")

    pretty (scatter `variable'_FinishedConversion `variable' if `variable'Tag == 1 , ///
        xlabel(1/`max_`variable'', angle(forty_five) valuelabel) ) , ///
        xtitle("Time Since Last Charge") ytitle("Finished Conversion Rate") ///
        name("FinishedConversionVs`variable'") ///
        save("`output'/Predictors/FinishedConversionVs`variable'.eps")
}

tab Strata , gen(Strata_)
tab TimeGroups , gen(TimeGroups_)
tab PrimaryIndustry , gen(PrimaryIndustry_)
tab CompanyProfile , gen(CompanyProfile_)
tab LegalType , gen(LegalType_)
tab ConnectType , gen(ConnectType_)

export delimited using "`responsedatacsv'", replace
save "`responsedata'", replace

*******************************************************************************
** Generics
*******************************************************************************
eststo clear
sort LegalType
by LegalType : eststo: quietly estpost summarize Generic Generic2 if LegalType != 2, listwise
esttab using "`output'/Predictors/GenericByType.tex", ///
    cells("mean(fmt(2))") label nodepvar replace collabels(none) ///
    nonumbers alignment(center)


*******************************************************************************
** Regressions
*******************************************************************************
logit Finished i.Strata
logit Finished i.PrimaryIndustry

* logit Finished i.PrimaryIndustry i.Strata
* logit Finished i.PrimaryIndustry#Strata

eststo clear
eststo: logistic Finished i.PrimaryIndustry i.Strata i.CompanyProfile ///
    i.LegalType i.ConnectType LogLifetimeVolume *Dummy  ///
    i.TimeGroups

esttab using "`output'/Predictors/Logit1.html", label wide replace ///
    nodepvar collabels(none) nonumbers alignment(center)

eststo: cvlasso Finished i.PrimaryIndustry i.Strata i.CompanyProfile ///
    i.LegalType i.ConnectType LogLifetimeVolume *Dummy  ///
    i.TimeGroups, lopt seed(123) postest

estpost tab Generic2 LegalType

logistic Finished i.PrimaryIndustry i.Strata i.CompanyProfile ///
    i.LegalType i.ConnectType LogLifetimeVolume *Dummy  ///
    i.TimeGroups

predict PredFinished

eststo: cvlasso Finished i.PrimaryIndustry i.Strata i.CompanyProfile ///
    i.LegalType i.ConnectType LogLifetimeVolume *Dummy  ///
    i.TimeGroups, lopt seed(123) postest

predict double PredFinished, lopt

sum PredFinished
sum Finished if PredFinished != .
local baseline = r(mean)

sum PredFinished if LegalType == 5  | PrimaryIndustry == 107
sum PredFinished if TimeGroups > 11
sum PredFinished if Generic2


sum PredFinished if LegalType != 5 & PrimaryIndustry != 107
sum PredFinished if TimeGroups <= 11
sum PredFinished if !(Generic2)
sum PredFinished if TimeGroups <= 11 & (LegalType != 5 & PrimaryIndustry != 107) & !Generic2
local improved = r(mean)

disp (`improved' / `baseline')
disp (`improved' / `baseline') * .25

eststo clear
estpost tab LegalType Generic2 if LegalType != 2
esttab, ///
    cell(rowpct(fmt(2))) unstack noobs replace ///
    nodepvar collabels(none) nonumbers

*******************************************************************************
** PLogit with dummies
*******************************************************************************
sum Finished if TimeGroups <= 11 & (LegalType != 5 & PrimaryIndustry != 107) & !Generic2


sum Finished if TimeGroups <= 12 & (LegalType != 5 & PrimaryIndustry != 107) & !Generic2

sum Finished if TimeGroups <= 11 & (LegalType != 5 & PrimaryIndustry != 107) & !Generic


crossfold plogit Finished Strata_2-Strata_3 *Dummy LogLifetimeVolume ///
    TimeGroups_2-TimeGroups_17 PrimaryIndustry_2-PrimaryIndustry_9 ///
    CompanyProfile_2-CompanyProfile_7 LegalType_2-LegalType_5 ///
    ConnectType_2-ConnectType_4, lasso


xtile VolumeTiles = LifetimeVolume , n(10)
sort VolumeTiles
by VolumeTiles: egen AvgGeneric = mean(Generic)
by VolumeTiles: egen AvgGeneric2 = mean(Generic2)

scatter AvgGeneric VolumeTiles
scatter AvgGeneric2 VolumeTiles

gen VolPerDay = LifetimeVolume / (LastChargeDate - FirstChargeDate)
xtile VolPerDayTiles = VolPerDay , n(10)
sort VolPerDayTiles

by VolPerDayTiles: egen AvgPerDayGeneric = mean(Generic)
by VolPerDayTiles: egen AvgPerDayGeneric2 = mean(Generic2)

scatter AvgPerDayGeneric VolPerDayTiles
scatter AvgPerDayGeneric2 VolPerDayTiles

pretty (scatter AvgPerDayGeneric VolPerDayTiles) ///
    (lfit AvgPerDayGeneric VolPerDayTiles) , ///
    xtitle("Volume Per Day Bin") ytitle("% Generic2 Email") ///
    legend(off) name("Generic22VsSize") ///
    save("`output'/Predictors/Generic2VsSize.eps")

pretty (scatter AvgPerDayGeneric2 VolPerDayTiles) ///
    (lfit AvgPerDayGeneric2 VolPerDayTiles),
    xtitle("Volume Per Day Bin") ytitle("% Generic2 Email") ///
    legend(off) name("GenericVsSize") ///
    save("`output'/Predictors/GenericVsSize.eps")

/*

predict double xbhat1, lopt

plogit Finished i.PrimaryIndustry i.Strata i.CompanyProfile ///
    i.LegalType i.ConnectType LogLifetimeVolume *Dummy  ///
    i.TimeGroups , lasso

*/



/*
logit Finished i.CapMonthsSinceCharge

xtile Monthtiles = MonthsSinceCharge, nquantiles(24)
sort Monthtiles
by Monthtiles : egen MeanFinishedMonth = mean(Finished)
egen MonthtilesTag = tag(Monthtiles)

scatter MeanFinished Monthtiles if MonthtilesTag == 1

xtile Daytiles = DaysSinceCharge, nquantiles(24)
sort Daytiles
by Daytiles : egen MeanFinishedDay = mean(Finished)
egen DaytilesTag = tag(Daytiles)

scatter MeanFinished Monthtiles if MonthtilesTag == 1

scatter MeanFinishedDay Daytiles if DaytilesTag == 1

gen QuartersSinceCharge = floor(MonthsSinceCharge / 3)
by MonthsSinceCharge : egen MeanFinished = mean(Finished)
egen MonthTag = tag(MonthsSinceCharge)


sort Daytiles
by Daytiles: egen MinDay = min(DaysSinceCharge)
by Daytiles: egen MaxDay = max(DaysSinceCharge)
tostring MinDay MaxDay, replace
gen DaytilesLabel = MinDay + "-" + MaxDay
replace DaytilesLabel = MinDay if MinDay == MaxDay
*/

/*
cvlasso Finished i.Strata i.PrimaryIndustry i.mcc LifetimeVolume ///
    FirstChargeDate CreatedDate ApplicationDate LastChargeDate ///
    i.CompanyProfile i.LegalType i.ConnectType *Dummy , seed(123)
cvlasso Finished i.Strata i.PrimaryIndustry i.mcc LifetimeVolume ///
    FirstChargeDate CreatedDate ApplicationDate LastChargeDate ///
    i.CompanyProfile i.LegalType i.ConnectType *Dummy , lopt seed(123) postest

eststo: cvlasso Finished i.Strata i.PrimaryIndustry i.mcc LifetimeVolume ///
        FirstChargeDate CreatedDate ApplicationDate LastChargeDate ///
        i.CompanyProfile i.LegalType i.ConnectType *Dummy , lopt seed(123) postest
*/
