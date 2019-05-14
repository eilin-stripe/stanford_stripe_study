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

local Temp1_1 = "`raw_distribution'/Stripe_Enterprise_Survey_NH_181105_1__temp_pilot_modified_baseline_only_no_award-Distribution_History.csv"
local Temp1_2 = "`raw_distribution'/Stripe_Enterprise_Survey_NH_181105_1__temp_pilot_modified_baseline_only_no_award-Distribution_History (1).csv"
local Temp1_3 = "`raw_distribution'/Stripe_Enterprise_Survey_NH_181105_1__temp_pilot_modified_baseline_only_no_award-Distribution_History (2).csv"
local Temp2_1 = "`raw_distribution'/Stripe_Enterprise_Survey_NH_181105_1__temp_pilot_modified_baseline_only_no_award_100-Distribution_History.csv"
local Temp2_2 = "`raw_distribution'/Stripe_Enterprise_Survey_NH_181105_1__temp_pilot_modified_baseline_only_no_award_100-Distribution_History (1).csv"
local Wave1 = "`raw_distribution'/Stripe_Enterprise_Survey_FINAL_wave_1-Distribution_History.csv"
local Wave2_1 = "`raw_distribution'/Wave2Mar5th2019_2019_05_04.csv"
local Wave2_2 = "`raw_distribution'/Wave2Mar6th2019_2019_05_04.csv"
local Wave2_add1 = "`raw_distribution'/Wave2Mar5th2019_2019_05_03.csv"
local Wave2_add2 = "`raw_distribution'/Wave2Mar6th2019_2019_05_03.csv"
local Wave3_1 = "`raw_distribution'/Wave3Apr2nd2019_2019_05_03.csv"
local Wave3_2 = "`raw_distribution'/Wave3Apr3rd2019_2019_05_03.csv"
local Wave3_3 = "`raw_distribution'/Wave3Apr4th2019_2019_05_03.csv"
local Wave3_4 = "`raw_distribution'/Wave3Apr5th2019_2019_05_03.csv"
local Wave3_5 = "`raw_distribution'/Wave3Apr6th2019_2019_05_03.csv"
local Wave3_6 = "`raw_distribution'/Wave3Apr7th2019_2019_05_03.csv"
local Wave3_7 = "`raw_distribution'/Wave3Apr9th2019_2019_05_03.csv"

local save = "`clean_survey'/History/Conversions.dta"
local sample = "`clean_sampling'/Sample2.dta"

*******************************************************************************
**
*******************************************************************************
local wave = 0
local history = "`clean_survey'/History/HistoryWave`wave'.dta"

if `wave' == 1 {
    import delimited "`Wave1'" , varnames(1) clear
}
else if `wave' == 2 {
    import delimited "`Wave2_1'" , varnames(1)
    tempfile dist1
    save "`dist1'"

    import delimited "`Wave2_2'" , varnames(1) clear
    append using "`dist1'"
}
else if `wave' == 3 {
    tempfile iter3
    save `iter3', emptyok
    forvalues x = 1/7 {
        import delimited "`Wave3_`x''" , varnames(1) clear
        append using `iter3'
        save "`iter3'", replace
    }
}
else if `wave' == 0 {
    import delimited "`Temp1_1'" , varnames(1)
    tempfile dist1
    tostring externaldatareference , replace
    save "`dist1'"

    import delimited "`Temp1_2'" , varnames(1) clear
    tempfile dist2
    tostring externaldatareference , replace
    save "`dist2'"

    import delimited "`Temp1_3'" , varnames(1) clear
    tempfile dist3
    save "`dist3'"

    import delimited "`Temp2_1'" , varnames(1) clear
    tempfile dist4
    save "`dist4'"

    import delimited "`Temp2_2'" , varnames(1) clear
    tostring externaldatareference , replace
    append using "`dist1'" "`dist2'" "`dist3'" "`dist4'"

    rename externaldatareference Strata
    replace Strata = "0" if Strata == "small"
    replace Strata = "1" if Strata == "big"
    replace Strata = "2" if Strata == "Funded"
    destring Strata, replace
    label define Strata 0 "Small" 1 "Big" 2 "Funded"
    label values Strata Strata

    gen externaldatareference = _n
}

rename responseid ResponseID
rename externaldatareference ExternalReference
rename firstname FirstName
rename lastname LastName
rename emailaddress Email
rename status StatusTemp
rename link Link

rename enddate EndDateTemp
replace EndDateTemp = substr(EndDateTemp, 1, 10)
gen EndDate =  date(EndDateTemp,"YMD",1999)
format EndDate %td
drop EndDateTemp


rename linkexpiration ExpirationDateTemp
replace ExpirationDateTemp  = substr(ExpirationDateTemp , 1, 10)
gen ExpirationDate =  date(ExpirationDateTemp ,"YMD",1999)
format ExpirationDate %td
drop ExpirationDateTemp

replace StatusTemp = "Blocked" if StatusTemp == "Email Blocked"
replace StatusTemp = "Bounced" if StatusTemp == "Email Hard Bounce"
replace StatusTemp = "Sent" if StatusTemp == "Email Sent"
replace StatusTemp = "Opened" if StatusTemp == "Email Opened"
replace StatusTemp = "OptedOut" if StatusTemp == "Opted Out"
replace StatusTemp = "Started" if StatusTemp == "Survey Started"
replace StatusTemp = "Finished" if StatusTemp == "Survey Finished"

label define Status 1 Bounced 2 Blocked 3 Sent 4 Opened 5 OptedOut ///
    6 Started 7 Finished

encode StatusTemp, gen(Status)
drop StatusTemp

gen Sent = 1
gen Bounced = (Status == 1)
gen Blocked = (Status == 2)
gen Delivered = (Status >= 3)
gen Opened = (Status >= 4)
gen Started = (Status >= 6)
gen Finished = (Status == 7)
gen OptedOut = (Status == 5)

drop Link

save "`history'", replace

*******************************************************************************
** Conversion Rate Calculatioins
*******************************************************************************

if `wave' != 0 {
    merge 1:1 ExternalReference using "`sample'", keep(1 3)
    drop _merge
}

sort Strata

by Strata: egen Total = total(Sent)
by Strata: egen TotalDelivered = total(Delivered)
by Strata: egen TotalOpened = total(Opened)
by Strata: egen TotalStarted = total(Started)
by Strata: egen TotalFinished = total(Finished)
by Strata: egen TotalOptedOut = total(OptedOut)
by Strata: egen TotalBlocked = total(Blocked)
by Strata: egen TotalBounced = total(Bounced)

by Strata: gen TotalConversion = (Total / Total)*100
by Strata: gen DeliveredConversion = ((Total - TotalBlocked - TotalBounced) / Total)*100
by Strata: gen DidntOptOutConversion = ((Total - TotalOptedOut) / (Total - TotalBlocked - TotalBounced) )*100
* by Strata: gen DeliveredConversion = (TotalDelivered / Total) * 100
by Strata: gen OpenedConversion = (TotalOpened / TotalDelivered) * 100
by Strata: gen StartedConversion = (TotalStarted / TotalOpened ) *  100
by Strata: gen FinishedConversion = (TotalFinished / TotalStarted) * 100

by Strata: gen TotalRate = (Total / Total)*100
by Strata: gen DeliveredRate = ((Total - TotalBounced - TotalBlocked) / Total) * 100
by Strata: gen DidntOptOutRate = ((Total - TotalOptedOut) / Total) * 100
by Strata: gen OpenedRate = (TotalOpened / Total) * 100
by Strata: gen StartedRate = (TotalStarted / Total) *  100
by Strata: gen FinishedRate = (TotalFinished / Total) * 100



egen StrataTag = tag(Strata)

format *Conversion *Rate %4.2f

list Strata *Conversion *Rate if StrataTag == 1

keep Strata *Conversion *Rate ExternalReference
* keep if StrataTag == 1

rename *Rate *1
rename *Conversion *2

reshape long Total Delivered DidntOptOut Opened Started Finished, i(ExternalReference) j(type)

sort Strata type

eststo clear
by Strata type : eststo: quietly estpost summarize Total Delivered DidntOptOut Opened Started Finished , listwise

sort type
by type : eststo: quietly estpost summarize Total Delivered DidntOptOut Opened Started Finished , listwise

if `wave' != 0 {
    esttab using "`output'/Conversion/ConversionRatesWave`wave'.html", ///
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
}
else if `wave' == 0 {
    esttab using "`output'/Conversion/ConversionRatesWave`wave'.html", ///
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
                "Total <br/> Rate" "Total <br/> Conversion")
}

save "`save'" , replace













*******************************************************************************
