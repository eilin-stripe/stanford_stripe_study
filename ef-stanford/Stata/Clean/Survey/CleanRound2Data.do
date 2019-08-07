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
local survey_label = "`raw_survey'/Round2/Stripe+Enterprise+FollowUp+Apr4th2019_June+4,+2019_20.06.csv"
local save = "`clean_main_survey'/Round2.dta"
*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************
import delimited "`survey_label'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress
tempfile label1
save "`label1'", replace

*******************************************************************************
** SETUP: ef
*******************************************************************************
// starts with round 1 data (excludes previous pilots)

rename responseid ResponseID

qui {
    label variable qid9_4 "First Name"
    label variable qid9_5 "Last Name"
    label variable qid9_6 "Email Address"
    label variable qid103 "Consent"
    label variable q28 "Has this business closed?"
    label variable q35 "Are you still affiliated with this business?"
    label variable q36 "Does the business still use Stripe to process payments?"
    label variable q40_1 "When did the Business Close? (Year)"
    label variable q40_2 "When did the Business Close? (Month)"
    label variable q53 "How was this business closed?"
    label variable q53_3_text "How was this business closed?"
    label variable q54 "Was closing the business voluntary?"
    label variable q41 "Decided or among those who decided to close the business?"
    label variable q55_1 "Which of the following were important to you in deciding to close the business?"
    label variable q55_2 "Which of the following were important to you in deciding to close the business?"
    label variable q55_3 "Which of the following were important to you in deciding to close the business?"
    label variable q55_4 "Which of the following were important to you in deciding to close the business?"
    label variable q55_5 "Which of the following were important to you in deciding to close the business?"
    label variable q55_6 "Which of the following were important to you in deciding to close the business?"
    label variable q55_7 "Which of the following were important to you in deciding to close the business?"
    label variable q55_8 "Which of the following were important to you in deciding to close the business?"
    label variable q55_9 "Which of the following were important to you in deciding to close the business?"
    label variable q55_10 "Which of the following were important to you in deciding to close the business?"
    label variable q55_11 "Which of the following were important to you in deciding to close the business?"
    label variable q55_12 "Which of the following were important to you in deciding to close the business?"
    label variable q55_12_text "Which of the following were important to you in deciding to close the business?"
    label variable q56_1 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_2 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_3 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_4 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_5 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_6 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_7 "What metrics, if any, did you use in your decision to close the business?"
    label variable q56_7_text "What metrics, if any, did you use in your decision to close the business?"
    label variable q57 "At first survey, did you consider that your business might close?"
    label variable q58 "At first survey, How likely did you think it was that your business would close?"
    label variable q59 "What is your current employment status?"
    label variable q60 "What is your current pre-tax annual income?"
    label variable q61 "How does your current employment compare with what your thought was available?"
    label variable qid56 "Last Words?"
    label variable q37_2 "contact information of the person who can speak about the business. (First Name)"
    label variable q37_3 "contact information of the person who can speak about the business. (Last Name)"
    label variable q37_4 "contact information of the person who can speak about the business. (Email)"
    label variable q39_1 "When did you end your affiliation with this business? (Year)"
    label variable q39_1 "When did you end your affiliation with this business? (Month)"
    label variable q38 "How did you end your affiliation with this business?"
    label variable q52 "Which of the following best describes this business today?"
    label variable qid81 "About how much in revenue did this business generate over the last 12 months? "
    label variable qid82 "Of your total revenue, what percent took place online? "
    label variable qid83 "Of your total revenue, what percent took place on Stripe? "
    label variable qid91 "Revenue on Stripe over February, March and April 2019?"
    label variable qid92 "predict your revenue on Stripe in June, July, and August 2019 combined"
    label variable qid95 "predict your revenue on Stripe over the next 12 months"
    label variable qid27 "Best possible outcome 12 months"
    label variable qid97 "Best possible outcome 3 months"
    label variable qid99 "Worst possible outcome 3 months"
    label variable qid100 "Worst possible outcome 12 months"
    label variable qid28_4 "Including the owners, how many people are working at this company?  (FULL_TIME)"
    label variable qid28_5 "Including the owners, how many people are working at this company?  (PART TIME)"
    label variable qid29_4 "In 3 years, how many people do you predict will be working here full time?"
    label variable qid29_5 "In 3 years, how many people do you predict will be working here part time?"
    label variable q27 "What did you do when a service or production problem arises in your business?"
    label variable q29 "How many key performance indicators (KPIs) are monitored at your business?"
    label variable q30 "How frequently are KPIs typically reviewed at your business?"
    label variable q32 "What describes the time frame of your service/production targets?"
    label variable q33 "How easy or difficult is it to achieve service, or production targets?"
    label variable q34 "What are the primary way employees are promoted in your business?"
    label variable v85 "When is an under-performing employee reassigned or dismissed?"
    label variable v86 "How do you handle record-keeping for budgeting and finance activities?"
    label variable q37 "How are data from budgeting and finance records used in decisions?"
    label variable q37_7_text "How are data from budgeting and finance records used in decisions?"
    label variable v89 "How frequently does your business rely on predictive analytics, ML, or AI"
    label variable qid37 "Hours Worked"
    label variable qid39 "Income From Business"
    label variable v92 "Over past 12 months, what was your total pre-tax income from all income sources?"
    label variable qid40 "Do you currently work for any other employer, excluding self-employment?"
    label variable qid44 "What is minimum annual income business have to provide to work on it full-time?"
    label variable qid44_3_text "What is minimum annual income business have to provide to work on it full-time?"
    label variable qid49 "What is min annual income business needs to provide to continue on it full-time"
    label variable qid49_4_text "What is min annual income business needs to provide to continue on it full-time"
    label variable q62 "Why did you decide to stop processing with Stripe?"
    label variable email "Email"
    label variable firstname "First Name"
    label variable lastname "Last Name"
    label variable winner "Winner"
}

destring * , replace

compress

rename finished FinishedTemp
encode FinishedTemp , gen(Finished)  label(TrueFalse)
drop FinishedTemp

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
drop Status

rename ipaddress IPAddress
drop IPAddress

rename progress Progress
rename durationinseconds Duration



rename recipientlastname LastName
rename recipientfirstname FirstName
rename recipientemail Email

rename externalreference ExternalReference
replace ExternalReference = "" if ExternalReference == "big"
replace ExternalReference = "" if ExternalReference == "small"

rename locationlatitude Lat
rename locationlongitude Lon

rename distributionchannel DistributionChannelTemp
replace DistributionChannelTemp = proper(DistributionChannelTemp)
encode DistributionChannelTemp , gen(DistributionChannel) label(DistributionChannel)
drop DistributionChannelTemp

rename userlanguage LanguageTemp
encode LanguageTemp , gen(Language) label(Language)
drop LanguageTemp

* drop Label*
*******************************************************************************
** CONSENT
*******************************************************************************
rename qid103 ConsentTemp
encode ConsentTemp, gen(Consent) label(Consent)
drop ConsentTemp

*******************************************************************************
** SCREEN
*******************************************************************************
rename qid9_4 SurveyFirstName
rename qid9_5 SurveyLastName
rename qid9_6 SurveyEmail

drop if inlist(Email, "eilin.francis@gmail.com", "rsfletch@stanford.edu", ///
    "eyeh@stripe.com", "anovet@stripe.com")
drop if DistributionChannel == 3

*******************************************************************************
** Business Closed
*******************************************************************************
rename q28 BusCloseFlagTemp
encode BusCloseFlagTemp, gen(BusCloseFlag) label(YesNo)
drop BusCloseFlagTemp

rename q40_1 BusCloseYear
replace BusCloseYear = -777 if BusCloseFlag == 0

rename q40_2 BusCloseMonthTemp
replace BusCloseMonthTemp = "NA" if BusCloseFlag ! = 1
encode BusCloseMonthTemp , gen(BusCloseMonth) label(Months)
drop BusCloseMonthTemp

rename q53 BusClosedHow
rename q53_3_text BusClosedHowOtherText

rename q54 BusCloseVoluntaryFlagTemp
encode BusCloseVoluntaryFlagTemp, gen(BusCloseVoluntaryFlag) label(YesNo)
drop BusCloseVoluntaryFlagTemp


rename q41 BusCloseDecisionMakerTemp
encode BusCloseDecisionMakerTemp, gen(BusCloseDecisionMaker) label(YesNo)
drop BusCloseDecisionMakerTemp

rename q57 BusCloseAnticipatedFlagTemp
encode BusCloseAnticipatedFlagTemp, gen(BusCloseAnticipatedFlag) label(YesNo)
drop BusCloseAnticipatedFlagTemp

rename q58 BusCloseHowLikelyTemp
encode BusCloseHowLikelyTemp , gen(BusCloseHowLikely) label(CatPercRev)
drop BusCloseHowLikelyTemp

rename q59 BusClosedCurrentEmploymentStatus
rename q60 BusClosedCurrentIncome
rename q61 BusClosedIncomeExpectations
rename qid56 LastWords

*******************************************************************************
** Not Affiliated
*******************************************************************************
rename q35 AffiliatedTemp
encode AffiliatedTemp, gen(AffiliatedFlag) label(YesNo)
drop AffiliatedTemp

rename q36 StripeUserTemp
encode StripeUserTemp, gen(StripeUserFlag) label(YesNo)
drop StripeUserTemp

rename q37_2 NotAffilContactFirstName
rename q37_3 NotAffilContactLastName
rename q37_4 NotAffilContactEmail
rename q39_1 NotAffilEndMonth
rename q38 NonAffilHow

rename q52 PhysicalOnlineBothTemp
replace PhysicalOnlineBothTemp = "Physical" if PhysicalOnlineBothTemp == "Physical business alone"
replace PhysicalOnlineBothTemp = "Online" if PhysicalOnlineBothTemp == "Online business alone"
replace PhysicalOnlineBothTemp = "Both" if PhysicalOnlineBothTemp == "Online & physical business"
encode PhysicalOnlineBothTemp, gen(PhysicalOnlineBoth) label( PhysicalOnlineBoth)
drop PhysicalOnlineBothTemp

rename qid81 RevPast12Months
rename qid82 PercRevOnline
rename qid83 PercRevStripe

rename qid91 RevPast3Months
rename qid92 Predict3Months
rename qid95 Predict12Months
rename qid27 Bad3Months
rename qid97 Good3Months
rename qid99 Bad12Months
rename qid100 Good12Months

rename qid28_4 NumFullTime
rename qid28_5 NumPartTime

gen NumEmployees = NumFullTime + NumPartTime

rename qid29_4 PredictFullTime
rename qid29_5 PredictPartTime

rename qid37 HoursPerWeek

* rename email Email
* rename firstname FirstName
* rename lastname LastName
rename rewardcode RewardCode
rename thankyoucode ThankYouCode
rename winner WinnerTemp
encode WinnerTemp , gen(Winner) label(YesNo)
drop WinnerTemp

drop RewardCode ThankYouCode

*******************************************************************************
** Management
*******************************************************************************
rename q29 NumKPIsTemp
tab NumKPIsTemp
replace NumKPIsTemp = regexr(NumKPIsTemp, " key performance indicators", "")
tab NumKPIsTemp
replace NumKPIsTemp = "0" if NumKPIsTemp == "No"
tab NumKPIsTemp
replace NumKPIsTemp = "10+" if NumKPIsTemp == "10 or more"
tab NumKPIsTemp
encode NumKPIsTemp , gen(NumKPIs) label(NumKPIs)
drop NumKPIsTemp

rename q30 HowFrequentKPIsTemp
encode HowFrequentKPIsTemp, gen(HowFrequentKPIs) label(Frequency)
drop HowFrequentKPIsTemp

rename q27 ProblemAdressingMethodTemp
replace ProblemAdressingMethodTemp = "Fixed it, no further action" if ///
    ProblemAdressingMethodTemp == "We fixed it but did not take further action"
replace ProblemAdressingMethodTemp = "Fixed it, took further action" if ///
    ProblemAdressingMethodTemp == "We fixed it and took action to make sure that it did not happen again"
replace ProblemAdressingMethodTemp = "Continuous improvement process" if ///
    regexm(ProblemAdressingMethodTemp, "continuous improvement process")
encode ProblemAdressingMethodTemp, gen(ProblemAdressingMethod) label(ProblemAdressingMethod)
drop ProblemAdressingMethodTemp


rename q32 TargetsTimeFrameTemp
replace TargetsTimeFrameTemp = "Both" if regexm(TargetsTimeFrameTemp, "Combination")
replace TargetsTimeFrameTemp = "Short term" if regexm(TargetsTimeFrameTemp, "short term")
replace TargetsTimeFrameTemp = "Long term" if regexm(TargetsTimeFrameTemp, "long term")
encode TargetsTimeFrameTemp, gen(TargetsTimeFrame) label(TargetsTimeFrame)
drop TargetsTimeFrameTemp

rename q33 TargetsDifficultyTemp
encode TargetsDifficultyTemp, gen(TargetsDifficulty) label(TargetsDifficulty)
drop TargetsDifficultyTemp

rename q34 HowPromoteEmployeesTemp
replace HowPromoteEmployeesTemp = "Not normally promoted" if ///
    HowPromoteEmployeesTemp == "Employees are not normally promoted."
replace HowPromoteEmployeesTemp = "Partly performance/ability" if ///
    HowPromoteEmployeesTemp == "Promotions were based partly on performance and ability and partly on other factors (for example, tenure or family connections)"
replace HowPromoteEmployeesTemp = "Solely performance/ability" if ///
    HowPromoteEmployeesTemp == "Promotions were based solely on performance and ability"
encode HowPromoteEmployeesTemp, gen(HowPromoteEmployees) label(HowPromoteEmployees)
drop HowPromoteEmployeesTemp


rename v85 UnderperformingEmployeeTemp
replace UnderperformingEmployeeTemp = "None Identified" ///
    if UnderperformingEmployeeTemp == "No under-performing employees identified"
replace UnderperformingEmployeeTemp = "Never" ///
    if UnderperformingEmployeeTemp == "Under-performing employees are not normally reassigned or dismissed"
replace UnderperformingEmployeeTemp = "< 6 Months" ///
    if UnderperformingEmployeeTemp == "Within 6 months of identifying employee under-performance"
replace UnderperformingEmployeeTemp = "> 6 Months" ///
    if UnderperformingEmployeeTemp == "After 6 months of identifying employee under-performance"
encode UnderperformingEmployeeTemp, gen(UnderperformingEmployee) label(UnderperformingEmployee)
drop UnderperformingEmployeeTemp

rename v86 RecordsMethodTemp
replace RecordsMethodTemp = "Electronic" if ///
    RecordsMethodTemp == "Keeps electronic records"
replace RecordsMethodTemp = "Paper" if ///
    RecordsMethodTemp == "Keeps paper records"
replace RecordsMethodTemp = "No Records" if ///
    RecordsMethodTemp == "Records not kept for budgeting and finance activities"
replace RecordsMethodTemp = "Kept by another business" if ///
    RecordsMethodTemp == "Records handled by another business"
encode RecordsMethodTemp, gen(RecordsMethod) label(RecordsMethod)
drop RecordsMethodTemp

rename q37 RecordsUsedHowTemp
replace RecordsUsedHowTemp = "Taxes" if ///
    RecordsUsedHowTemp == "Preparing this businessâs taxes"
replace RecordsUsedHowTemp = "Targeting Customers" if ///
    RecordsUsedHowTemp == "Targeting potential customers"
replace RecordsUsedHowTemp = "Forecasting Demand" if ///
    RecordsUsedHowTemp == "Forecasting demand for products or services"
replace RecordsUsedHowTemp = "Ordering Inputs" if ///
    RecordsUsedHowTemp == "Ordering supplies or materials"
replace RecordsUsedHowTemp = "Product Design" if ///
    RecordsUsedHowTemp == "Design of new products or services"
replace RecordsUsedHowTemp = "Other" if ///
    RecordsUsedHowTemp == "Other:"
replace RecordsUsedHowTemp = "Scheudling Deliveries" if ///
    RecordsUsedHowTemp == "Scheduling or managing deliveries Financial planning"
encode RecordsUsedHowTemp, gen(RecordsUsedHow) label(RecordsUsedHow)
drop RecordsUsedHowTemp

rename q37_7_text RecordsUsedHowOther

rename v89 PredictiveAnalyticsFlagTemp
encode PredictiveAnalyticsFlagTemp, gen(PredictiveAnalyticsFlag) label(Frequency)
drop PredictiveAnalyticsFlagTemp

*******************************************************************************
** Earnings
*******************************************************************************

rename qid39 EarningsPast12Months

rename qid40 OtherJobFlagTemp
encode OtherJobFlagTemp , gen(OtherJobFlag) label(YesNo)
drop OtherJobFlagTemp

rename qid44 MinIncomeLeaveOtherJobStated
replace MinIncomeLeaveOtherJobStated = "1" if MinIncomeLeaveOtherJobStated ///
    == "Minimum income:"
replace MinIncomeLeaveOtherJobStated = "0" if MinIncomeLeaveOtherJobStated ///
    == "I'm not interested in working on this business full-time"
destring MinIncomeLeaveOtherJobStated, replace
replace MinIncomeLeaveOtherJobState = -777 if OtherJobFlag == 0

rename qid44_3_text MinIncomeLeaveOtherJob
replace MinIncomeLeaveOtherJob = subinstr(MinIncomeLeaveOtherJob, ",", "", .)
destring MinIncomeLeaveOtherJob, replace
replace MinIncomeLeaveOtherJob = -777 if OtherJobFlag == 0
replace MinIncomeLeaveOtherJob = -777 if MinIncomeLeaveOtherJobStated == 0

rename qid49 MinIncomeStayFullTimeStated
replace MinIncomeStayFullTimeStated = "1" if MinIncomeStayFullTimeStated ///
    == "Minimum income:"
replace MinIncomeStayFullTimeStated = "0" if MinIncomeStayFullTimeStated ///
    == "Iâm not interested in continuing to work full-time on this business"
destring MinIncomeStayFullTimeStated, replace
replace MinIncomeStayFullTimeStated = -777 if OtherJobFlag == 1

rename qid49_4_text MinIncomeStayFullTime
replace MinIncomeStayFullTime = subinstr(MinIncomeStayFullTime, ",", "", .)
destring MinIncomeStayFullTime, replace
replace MinIncomeStayFullTime= -777 if OtherJobFlag == 1
replace MinIncomeStayFullTime = -777 if MinIncomeStayFullTimeStated == 0

rename q62 WhyQuitStripe

rename v92 TotalIncomeAllSources


drop q55* q56*
dropmiss *, force

save "`save'", replace
