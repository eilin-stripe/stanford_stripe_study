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
local survey_label = "`raw_survey'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award ($100)_December 9, 2018_20.17_choice.csv"
local survey_label2 = "`raw_survey'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award_December 10, 2018_02.13_choice.csv"
local survey_nolabel = "`raw_survey'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award ($100)_December 9, 2018_20.17_num.csv"
local survey_nolabel2 = "`raw_survey'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award_December 10, 2018_02.13_num.csv"
local save = "`clean_survey'/Survey.dta"
*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************
import delimited "`survey_label'", varnames(1) encoding(ISO-8859-1) clear
drop if inlist(_n, 1, 2)
compress
tempfile label1
save "`label1'", replace

import delimited "`survey_label2'", varnames(1) encoding(ISO-8859-1) clear
append using "`label1'"

rename * Label*
rename Labelresponseid ResponseID
drop if inlist(_n, 1, 2)
compress
tempfile labelfile
save "`labelfile'", replace

import delimited "`survey_nolabel'", varnames(1) encoding(ISO-8859-1) clear
drop if inlist(_n, 1, 2)
tempfile nolabel1
save "`nolabel1'", replace
import delimited "`survey_nolabel2'", varnames(1) encoding(ISO-8859-1) clear
append using "`nolabel1'"

{
    label variable qid103 "Consent"
    label variable qid10 "Were you one of the business founders? "
    label variable qid104 "What is your job title at this business?"
    label variable qid16 "How many people founded this business originally?"
    label variable qid87_1 "What were the key factors in deciding to start this business? "
    label variable qid87_11 "What were the key factors in deciding to start this business? "
    label variable qid87_12 "What were the key factors in deciding to start this business? "
    label variable qid87_13 "What were the key factors in deciding to start this business? "
    label variable qid87_14 "What were the key factors in deciding to start this business? "
    label variable qid87_15 "What were the key factors in deciding to start this business? "
    label variable qid87_7 "What were the key factors in deciding to start this business? "
    label variable qid87_7_text "What were the key factors in deciding to start this business? "
    label variable qid17 "Prior to starting this business, how many other businesses did you start?"
    label variable q76 "Including this business, how many businesses do you currently own?"
    label variable qid19_1 "What sources of funding were used to start this business in the first year?"
    label variable qid19_2 "What sources of funding were used to start this business in the first year?"
    label variable qid19_3 "What sources of funding were used to start this business in the first year?"
    label variable qid19_4 "What sources of funding were used to start this business in the first year?"
    label variable qid19_6 "What sources of funding were used to start this business in the first year?"
    label variable qid19_7 "What sources of funding were used to start this business in the first year?"
    label variable qid19_9 "What sources of funding were used to start this business in the first year?"
    label variable qid19_7_text "What sources of funding were used to start this business in the first year?"
    label variable qid33 "How much money was used to fund this business in the first year?"
    label variable qid105_1 "What are your biggest current challenges for this business? "
    label variable qid105_2 "What are your biggest current challenges for this business? "
    label variable qid105_3 "What are your biggest current challenges for this business? "
    label variable qid105_4 "What are your biggest current challenges for this business? "
    label variable qid105_5 "What are your biggest current challenges for this business? "
    label variable qid105_6 "What are your biggest current challenges for this business? "
    label variable qid105_7 "What are your biggest current challenges for this business? "
    label variable qid105_6_text "What are your biggest current challenges for this business? "
    label variable qid23 "Over past year, has it become easier or harder to build business home country?"
    label variable q74 "What percent of your revenue comes from online transactions?"
    label variable qid67 "Are you proficient in one or more coding languages?"
    label variable qid30_1 "When did this business hire an employee for the first time?"
    label variable qid38 "Where do you do most of your work?"
    label variable qid40 "Do you currently work for any other employer, excluding self-employment?"
    label variable qid44 "What is minimum annual income business have to provide to work on it full-time?"
    label variable qid69 "Were you ever employed by someone else before founding this business? "
    label variable qid70 "How did you leave your most recent job?"
    label variable qid46 "What was the primary reason you quit your previous job?"
    label variable qid47_2 "When did you quit this previous job? (Month)"
    label variable qid71_2 "When did this job end? (Month)"
    label variable qid49 "What is min annual income business needs to provide to continue on it full-time"
    label variable qid72_1 "What country do you live in?"
    label variable qid53 "What is your gender?"
    label variable qid55 "What is the highest level of education you have completed?"
    label variable recordeddate "Recorded date"
    label variable responseid "Response ID"
    label variable recipientlastname "Respondent last name (Stripe)"
    label variable recipientfirstname "Respondent first name (Stripe)"
    label variable recipientemail "Respondent email"
    label variable qid9_4 "Respondent last name"
    label variable qid9_5 "Respondent first name"
    label variable qid87_7_text "What were the key factors in deciding to start this business? OTHER"
    label variable qid76_1 "When did this business make its first sale to a customer? "
    label variable qid90_1 "When did this business incur its first cost?"
    label variable qid19_7_text "What sources of funding were used to start this business in the first year?"
    label variable qid22 "Please briefly describe this business"
    label variable qid66 "Please briefly describe this business's mission"
    label variable qid105_6_text "What are your biggest current challenges for this business?  OTHER"
    label variable qid81 "About how much in revenue did this business generate over the last 12 months? "
    label variable qid82 "Of your total revenue, what percent took place online? "
    label variable qid83 "Of your total revenue, what percent took place on Stripe? "
    label variable qid91 "What was your revenue on Stripe last month?"
    label variable qid92 "What do you predict your revenue on Stripe will be over the next 3 months?"
    label variable qid95 "What do you predict your revenue on Stripe will be over the next 12 months ?"
    label variable qid27 "If this business does worse than expected, what would you expect instead?"
    label variable qid97 "If this business does better than expected, what would you expect instead? "
    label variable qid99 "If this business does worse than expected, what would you expect instead?"
    label variable qid100 "If this business does better than expected, what would you expect instead?"
    label variable qid28_4 "Including the owners, how many people are working at this company?  (FULL_TIME)"
    label variable qid28_5 "Including the owners, how many people are working at this company?  (PART TIME)"
    label variable qid29_4 "In 3 years, how many people do you predict will be working here full time?"
    label variable qid29_5 "In 3 years, how many people do you predict will be working here part time?"
    label variable qid68_4 "How many people here work as software engineers or developers full time?"
    label variable qid68_5 "How many people here work as software engineers or developers part time?"
    label variable qid31 "What share of your revenue is international? Must be between 0% and 100%."
    label variable qid34 "In 3 years, what share of your revenue do you predict will be international?"
    label variable qid37 "Over past 3 months, typical number of hours per week spent on this business?"
    label variable qid38_5_text "Where do you do most of your work? OTHER"
    label variable qid39 "Over past 12 months, total pre-tax earnings and dividends from this business?"
    label variable qid41 "Typical hours per week that you spend working in other jobs and businesses? "
    label variable qid42_1 "Why are you still working in another job, rather than this business full-time?"
    label variable qid42_2 "Why are you still working in another job, rather than this business full-time?"
    label variable qid42_3 "Why are you still working in another job, rather than this business full-time?"
    label variable qid42_4 "Why are you still working in another job, rather than this business full-time?"
    label variable qid42_5 "Why are you still working in another job, rather than this business full-time?"
    label variable qid42_5_text "Why are you still working in another job, rather than this business full-time?"
    label variable qid43 "What is your pre-tax annual income from other jobs and businesses"
    label variable qid44_3_text "Min annual income your business would have to provide to work on it full-time?"
    label variable qid70_4_text "How did you leave your most recent job? OTHER"
    label variable qid46_2_text "What was the primary reason you quit your previous job? OTHER"
    label variable qid47_1 "When did you quit this previous job? "
    label variable qid71_1 "When did this job end? "
    label variable qid48 "What was your annual income in this prior job?"
    label variable qid49_4_text "Min annual income your business needs to provide to continue on it full-time?"
    label variable qid73 "What zip code do you live in?"
    label variable qid54 "What is your current age?"
    label variable qid56 "Is there anything you'd like to share with Stripe or Stanford?"
}

rename responseid ResponseID
drop if inlist(_n, 1, 2)
destring * , replace

compress

merge 1:1 ResponseID using "`labelfile'"
drop _merge

compress

rename startdate StartDateTemp
replace StartDateTemp = substr(StartDateTemp, 1, 10)
gen StartDate =  date(StartDateTemp,"YMD",1999)
format StartDate %td
drop StartDateTemp

rename enddate EndDateTemp
replace EndDateTemp = substr(EndDateTemp, 1, 10)
gen EndDate =  date(EndDateTemp,"YMD",1999)
format EndDate %td
drop EndDateTemp

rename recordeddate RecordedDateTemp
replace RecordedDateTemp = substr(RecordedDateTemp, 1, 10)
gen RecordedDate =  date(RecordedDateTemp,"YMD",1999)
format RecordedDate %td
drop RecordedDateTemp

rename status Status
rename ipaddress IPAddress
rename progress Progress
rename durationinseconds Duration
rename finished Finished
rename recipientlastname LastName
rename recipientfirstname FirstName
rename recipientemail Email
rename externalreference ExternalReference
rename locationlatitude Lat
rename locationlongitude Lon
rename distributionchannel DistributionChannel
rename userlanguage Language

drop IPAddress ResponseID ExternalReference DistributionChannel Language

local labelvars = "103 10 87_1 87_11 87_12 87_13 87_14 87_15 17 " ///
    + " 67 72_1 53 55 69 70 23 38 40"
foreach var of local labelvars {
    disp "`lab'"
    local lab = "Labelqid`var'"
    labmask qid`var' , values(`lab')
}

local labelvars2 = "76"
foreach var of local labelvars2 {
    disp "`lab'"
    local lab = "Labelq`var'"
    labmask q`var' , values(`lab')
}

* drop Label*
*******************************************************************************
** CONSENT
*******************************************************************************
rename qid103 Consent

*******************************************************************************
** SCREEN
*******************************************************************************
rename qid9_4 SurveyLastName
rename qid9_5 SurveyFirstName
rename qid10 FounderFlag
rename qid104 JobTitle
replace JobTitle = "NA" if FounderFlag == 1

*******************************************************************************
** Founding
*******************************************************************************
rename qid16 NumFounders
replace NumFounders = -777 if FounderFlag == 2 & NumFounders == .

egen KeyFactorsAnswered = rownonmiss(qid87_*) , strok
rename qid87_1 KeyBeBoss
replace KeyBeBoss = 0 if KeyFactorsAnswered > 0 & KeyBeBoss == .
replace KeyBeBoss = -777 if FounderFlag == 2

rename qid87_11 KeyFlexible
replace KeyFlexible = 0 if KeyFactorsAnswered > 0 & KeyFlexible == .
replace KeyFlexible = -777 if FounderFlag == 2

rename qid87_12 KeyEarnMore
replace KeyEarnMore = 0 if KeyFactorsAnswered > 0 & KeyEarnMore == .
replace KeyEarnMore = -777 if FounderFlag == 2

rename qid87_13 KeyBestAvenue
replace KeyBestAvenue = 0 if KeyFactorsAnswered > 0 & KeyBestAvenue == .
replace KeyBestAvenue = -777 if FounderFlag == 2

rename qid87_14 KeyPositive
replace KeyPositive = 0 if KeyFactorsAnswered > 0 & KeyPositive == .
replace KeyPositive = -777 if FounderFlag == 2

rename qid87_15 KeyLearning
replace KeyLearning = 0 if KeyFactorsAnswered > 0 & KeyLearning == .
replace KeyLearning = -777 if FounderFlag == 2

rename qid87_7 KeyOther
replace KeyOther = 0 if KeyFactorsAnswered > 0 & KeyOther == .
replace KeyOther = -777 if FounderFlag == 2

rename qid87_7_text KeyOtherText
replace KeyOtherText = "NA" if KeyOther == 0
replace KeyOtherText = "NA" if FounderFlag == 2

rename qid17 PreviousBusinesses
replace PreviousBusinesses = -777 if FounderFlag == 2
rename q76 NumBusOwned
replace NumBusOwned = -777 if FounderFlag == 2

rename qid76_1 FirstSaleYear
replace FirstSaleYear = (2019 - FirstSaleYear)
replace FirstSaleYear = -777 if FounderFlag == 2

rename qid90_1 FirstCostYear
replace FirstCostYear = (2019 - FirstCostYear)
replace FirstCostYear = -777 if FounderFlag == 2

gen DifSaleCostYear = FirstSaleYear - FirstCostYear
replace DifSaleCostYear = -777 if FounderFlag == 2

*******************************************************************************
** FUNDING
*******************************************************************************


egen SourcesAnswered = rownonmiss(qid19_*) , strok
rename qid19_1 SourcesPersonalSavings
replace SourcesPersonalSavings = 0 if SourcesAnswered > 0 & SourcesPersonalSavings == .
replace SourcesPersonalSavings = -777 if FounderFlag == 2

rename qid19_2 SourcesCredit
replace SourcesCredit = 0 if SourcesAnswered > 0 & SourcesCredit == .
replace SourcesCredit = -777 if FounderFlag == 2

rename qid19_3 SourcesBankLoan
replace SourcesBankLoan = 0 if SourcesAnswered > 0 & SourcesBankLoan == .
replace SourcesBankLoan = -777 if FounderFlag == 2

rename qid19_4 SourcesGovLoan
replace SourcesGovLoan = 0 if SourcesAnswered > 0 & SourcesGovLoan == .
replace SourcesGovLoan = -777 if FounderFlag == 2

rename qid19_6 SourcesInvestor
replace SourcesInvestor = 0 if SourcesAnswered > 0 & SourcesInvestor == .
replace SourcesInvestor = -777 if FounderFlag == 2

rename qid19_7 SourcesOther
replace SourcesOther = 0 if SourcesAnswered > 0 & SourcesOther == .
replace SourcesOther = -777 if FounderFlag == 2

rename qid19_9 SourcesNone
replace SourcesNone = 0 if SourcesAnswered > 0 & SourcesNone == .
replace SourcesNone = -777 if FounderFlag == 2

rename qid19_7_text SourcesOtherText
replace SourcesOtherText = "NA" if SourcesAnswered > 0 & SourcesOtherText == ""
replace SourcesOtherText = "NA" if KeyOther == 0
replace SourcesOtherText= "NA" if FounderFlag == 2

replace SourcesNone = 1 if SourcesOtherText == "None"
replace SourcesOther = 0 if SourcesOtherText == "None"
replace SourcesOtherText = "NA" if SourcesOtherText == "None"

rename qid33 StartingFunding
replace StartingFunding = StartingFunding + 1
replace StartingFunding = 1 if StartingFunding == 13
replace StartingFunding = -777 if FounderFlag == 2
replace StartingFunding = -777 if SourcesNone == 1
label define StartingFunding 2 "1k-5k" 3 "5k-10k" 4 "10k-25k" 5 "25k-50k" ///
    6 "50k-100k" 7 "100k-250k" 8 "250k-1M" 9 "1M-3M" 10 "3M+" 1 "<1k" ///
    -777 "NA" , replace
label val StartingFunding StartingFunding

*******************************************************************************
** BUSINESS CHARACTERISTICS
*******************************************************************************
rename qid22 Description
rename qid66 MissionStatement

egen ChallengesAnswered = rownonmiss(qid105_*) , strok
rename qid105_1 ChallengesFindingCust
replace ChallengesFindingCust = 0 if ChallengesAnswered > 0 & ChallengesFindingCust == .

rename qid105_2 ChallengesFunding
replace ChallengesFunding = 0 if ChallengesAnswered > 0 & ChallengesFunding == .

rename qid105_3 ChallengesHiring
replace ChallengesHiring = 0 if ChallengesAnswered > 0 & ChallengesHiring == .

rename qid105_4 ChallengesRegulations
replace ChallengesRegulations = 0 if ChallengesAnswered > 0 & ChallengesRegulations == .

rename qid105_5 ChallengesCompetition
replace ChallengesCompetition = 0 if ChallengesAnswered > 0 & ChallengesCompetition == .

rename qid105_6 ChallengesOther
replace ChallengesOther = 0 if ChallengesAnswered > 0 & ChallengesOther == .

rename qid105_7 ChallengesTaxes
replace ChallengesTaxes = 0 if ChallengesAnswered > 0 & ChallengesTaxes == .

rename qid105_6_text ChallengesOtherText
replace ChallengesOtherText = "NA" if ChallengesOther == 0
replace ChallengesOtherText = "NA" if FounderFlag == 2

rename qid23 HarderOrEasier

rename q74 CatPercRevOnline
label define CatPercRevOnline 13 "0-24%" 14 "25-49%" 15 "50-74%" 16 "75-100%", replace
label val CatPercRevOnline CatPercRevOnline

rename qid67 CodingProficient
rename qid81 RevPast12Months
rename qid82 PercRevOnline
rename qid83 PercRevStripe

// TODO: Generate the qid87 graphs


*******************************************************************************
** PREDICTION
*******************************************************************************
rename qid91 RevPastMonth
rename qid92 Predict3Months
rename qid95 Predict12Months
rename qid27 Bad3Months
rename qid97 Good3Months
rename qid99 Bad12Months
rename qid100 Good12Months  // TODO: Make sure Mapping is right

*******************************************************************************
** Employees
*******************************************************************************
rename qid28_4 NumFullTime
rename qid28_5 NumPartTime
rename qid29_4 PredictFullTime
rename qid29_5 PredictPartTime
rename qid68_4 NumSoftwareFullTime
rename qid68_5 NumSoftwarePartTime
rename qid30_1 FirstHireYear

replace FirstHireYear = (2019 - FirstHireYear)

rename qid31 PercRevInternational
rename qid34 PredictRevInternational

*******************************************************************************
** Labor
*******************************************************************************
rename qid37 HoursPerWeek
rename qid38 WorkLocation
label define WorkLocation 1 "Home" 2 "Cafe/Public" 5 "Other" 4 "Office Space"
label val WorkLocation WorkLocation
rename qid38_5_text WorkLocationOtherText
replace WorkLocationOtherText = "NA" if WorkLocation != 5
rename qid39 EarningsPast12Months
rename qid40 OtherJobFlag

*******************************************************************************
** OTHER JOB
*******************************************************************************
rename qid41 HoursPerWeekOtherJob
replace HoursPerWeekOtherJob = -777 if OtherJobFlag == 2

egen WhyOtherJobAnswered = rownonmiss(qid42_*) , strok
rename qid42_1 WhyOtherJobIncome
replace WhyOtherJobIncome = 0 if WhyOtherJobAnswered  > 0 & WhyOtherJobIncome == .
replace WhyOtherJobIncome = -777 if OtherJobFlag == 2

rename qid42_2 WhyOtherJobMoreWork
replace WhyOtherJobMoreWork = 0 if WhyOtherJobAnswered > 0 & WhyOtherJobMoreWork == .
replace WhyOtherJobMoreWork = -777 if OtherJobFlag == 2

rename qid42_3 WhyOtherJobTesting
replace WhyOtherJobTesting = 0 if WhyOtherJobAnswered > 0 & WhyOtherJobTesting == .
replace WhyOtherJobTesting = -777 if OtherJobFlag == 2

rename qid42_4 WhyOtherJobEnjoy
replace WhyOtherJobEnjoy = 0 if WhyOtherJobAnswered > 0 & WhyOtherJobEnjoy == .
replace WhyOtherJobEnjoy = -777 if OtherJobFlag == 2

rename qid42_5 WhyOtherJobOther
replace WhyOtherJobOther = 0 if WhyOtherJobAnswered > 0 & WhyOtherJobOther == .
replace WhyOtherJobOther = -777 if OtherJobFlag == 2

rename qid42_5 WhyOtherJobOtherText
replace WhyOtherJobOtherText = -777 if WhyOtherJobOther == 0
replace WhyOtherJobOtherText = -777 if OtherJobFlag == 2

rename qid43 OtherJobIncome
replace OtherJobIncome = -777 if OtherJobFlag == 2

rename qid44 MinIncomeLeaveOtherJob
replace MinIncomeLeaveOtherJob = -777 if OtherJobFlag == 2
rename qid44_3_text MinIncomeLeaveOtherJobText
replace MinIncomeLeaveOtherJobText = subinstr(MinIncomeLeaveOtherJobText, ",", "", .)
destring MinIncomeLeaveOtherJobText, replace
replace MinIncomeLeaveOtherJobText = -777 if OtherJobFlag == 2

*******************************************************************************
** Previous Job
*******************************************************************************

rename qid69 PrevJobFlag
replace PrevJobFlag = -777 if OtherJobFlag == 1

rename qid70 HowLeftPrevJob
replace HowLeftPrevJob = -777 if PrevJobFlag != 1
label define HowLeftPrevJob 1 "Quit" 2 "Laid Off/Fired" ///
    3 "Employer Closed" -777 "Never Had Pevious Job", replace
label val HowLeftPrevJob HowLeftPrevJob

rename qid70_4_text HowLeftPrevJobText
replace HowLeftPrevJobText = -777 if PrevJobFlag != 1

gen QuitFlag = 0
replace QuitFlag = 1 if HowLeftPrevJob == 1

rename qid46 PrevJobQuitReason
replace PrevJobQuitReason = -777 if QuitFlag != 1
label define PrevJobQuitReason 1 "Focus on This" 2 "Other" ///
    4 "Explore Business Ideas" -777 "Never Quit", replace
label val PrevJobQuitReason PrevJobQuitReason

rename qid46_2_text PrevJobQuitReasonText
replace PrevJobQuitReasonText = "NA" if PrevJobQuitReason != 2

rename qid47_1 QuitPrevJobYear
* replace QuitPrevJobYear = (2019 - QuitPrevJobYear)
replace QuitPrevJobYear = -777 if QuitFlag != 1

rename qid47_2 QuitPrevJobMonth
replace QuitPrevJobMonth = -777 if QuitFlag != 1

rename qid71_1 PrevJobEndYear
replace PrevJobEndYear = -777 if OtherJobFlag == 1
replace PrevJobEndYear = -777 if PrevJobFlag == 2
replace PrevJobEndYear = -777 if QuitFlag == 1

rename qid71_2 PrevJobEndMonth
replace PrevJobEndMonth = -777 if OtherJobFlag == 1
replace PrevJobEndMonth = -777 if PrevJobFlag == 2
replace PrevJobEndMonth = -777 if QuitFlag == 1

rename qid48 PrevJobIncome
replace PrevJobIncome = subinstr(PrevJobIncome, ",", "", .)
destring PrevJobIncome, replace
replace PrevJobIncome = -777 if PrevJobFlag != 1

rename qid49 MinIncomeStayFullTime
rename qid49 MinIncomeStayFullTimeText

* replace qid70 = -777 if PrevEmploymentFlag == 2
* replace qid46 = -777 if PrevEmploymentFlag == 2

*******************************************************************************
** DEMOGRAPHICS
*******************************************************************************
rename qid72_1 Country
rename qid73 ZipCode
rename qid53 Gender
rename qid54 Age
rename qid55 Education
label define Education 1 "< Highscool" 2 "HighSchool/GED" ///
    3 "Technical, Trade, Vocational" 4 "Some College" 5 "Associates" ///
    6 "Bachelors" 7 "Masters+", replace
label val Education Education
rename qid56 ShareText
rename qid97 Topics

drop Label*

save "`save'", replace

/*


*Cleaning variables asking for figures 'in 1000s' which have been inserted in full instead

*qid81: About how much in revenue did this business generate over the last 12 months? Please answer in thousands of dollars.
replace qid81 = 60 if qid81 == 60000
replace qid81 = 2 if qid81 == 1500
replace qid81 = 7 if qid81 == 6500

*qid91: What was your revenue on Stripe last month,  ? Please answer in thousands of dollars.
replace qid91 = 5 if qid91 == 4900
replace qid91 = 2 if qid91 == 2115

*qid92: What do you predict your revenue on Stripe will be over the next 3 months from ,  through , ? Please answer in thousands of dollars.
replace qid92 = 25 if qid92 == 25000

*qid95: What do you predict your revenue on Stripe will be over the next 12 months through , ? Please answer in thousands of dollars.
replace qid95 = 80 if qid95 == 80000

*qid27: If this business does worse than expected, what would you expect instead?
replace qid27 = 15 if qid27 == 15000

*qid97: If this business does better than expected, what would you expect instead?
replace qid97 = 35 if qid97 == 35000

*qid99: If this business does worse than expected, what would you expect instead?
replace qid99 = 60 if qid99 == 60000

*qid100: If this business does better than expected, what would you expect instead?
replace qid100 = 100 if qid100 == 100000

*qid39: Over the past 12 months, what was the total amount of pre-tax earnings and divided
replace qid39 = 390 if qid39 == 390000
