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
local survey_label = "`raw_completed'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award ($100)_December 19, 2018_01.36.csv"
local survey_label2 = "`raw_completed'/Stripe Enterprise Survey NH 181105_1 - temp pilot modified baseline only no award_December 19, 2018_01.35.csv"
local survey_label3 = "`raw_completed'/Stripe+Enterprise+Survey_FINAL_wave+1_March+7,+2019_19.11.csv"
local survey_label4 = "`raw_survey'/Stripe+Enterprise+Survey_wave2_May+13,+2019_13.57.csv"
local save = "`clean_main_survey'/Survey.dta"
*******************************************************************************
** SETUP CORE VARIABLES
*******************************************************************************
import delimited "`survey_label'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress
tempfile label1
save "`label1'", replace

drop _all
import delimited "`survey_label2'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress
tempfile label2
save "`label2'", replace

drop _all
import delimited "`survey_label4'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress
tempfile label4
save "`label4'", replace

drop _all
import delimited "`survey_label3'", varnames(1) encoding(ISO-8859-1)
drop if inlist(_n, 1, 2)
compress

append using "`label4'" "`label1'" "`label2'" , generate(SurveyRound)
replace SurveyRound = SurveyRound + 1
label values SurveyRound SurveyRound
/*
gen Wave = .
replace Wave = 1 if SurveyRound == 0
replace Wave = 2 if SurveyRound == 1
*/

rename responseid ResponseID

qui {
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
    label variable q74new "What percent of your revenue goes through Stripe or a platform that uses Stripe?"
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
    label variable ResponseID "Response ID"
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

destring * , replace

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

rename beforebuschardate BeforePredictionDateTemp
replace BeforePredictionDateTemp = substr(BeforePredictionDateTemp, 1, 10)
gen BeforePredictionDate =  date(BeforePredictionDateTemp,"YMD",1999)
format BeforePredictionDate %td
replace BeforePredictionDate = -999 if inlist(SurveyRound, 1, 3, 4)
drop BeforePredictionDateTemp

rename afterbuschardate AfterPredictionDateTemp
replace AfterPredictionDateTemp = substr(AfterPredictionDateTemp, 1, 10)
gen AfterPredictionDate =  date(AfterPredictionDateTemp,"YMD",1999)
format AfterPredictionDate %td
replace AfterPredictionDate = -999 if inlist(SurveyRound, 1, 3, 4)
drop AfterPredictionDateTemp

rename status Status
drop Status

rename ipaddress IPAddress
drop IPAddress

rename progress Progress
rename durationinseconds Duration

rename finished FinishedTemp
encode FinishedTemp , gen(Finished)  label(TrueFalse)
drop FinishedTemp

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

rename qid10 FounderFlagTemp
encode FounderFlagTemp, gen(FounderFlag) label(YesNo)
drop FounderFlagTemp

rename qid104 JobTitle
replace JobTitle = "NA" if FounderFlag == 1

*******************************************************************************
** Founding
*******************************************************************************
rename qid16 NumFoundersTemp
replace NumFoundersTemp = "1" if NumFoundersTemp == ///
    "1 -- I founded this company by myself"
encode NumFoundersTemp, gen(NumFounders) label(NumFounders)
replace NumFounders = -777 if FounderFlag == 0 & NumFounders == .
drop NumFoundersTemp

egen AnsweredKeyFactors = rownonmiss(qid87_*) , strok

rename qid87_1 KeyBeBoss
replace KeyBeBoss = "1" if KeyBeBoss == "Wanted to be my own boss"
destring KeyBeBoss, replace
replace KeyBeBoss = 0 if AnsweredKeyFactors > 0 & KeyBeBoss == .
replace KeyBeBoss = -777 if FounderFlag == 0
label var KeyBeBoss "Be Own Boss"

rename qid87_11 KeyFlexible
replace KeyFlexible = "1" if KeyFlexible == "Flexible schedule"
destring KeyFlexible, replace
replace KeyFlexible = 0 if AnsweredKeyFactors > 0 & KeyFlexible == .
replace KeyFlexible = -777 if FounderFlag == 0
label var KeyFlexible "Flexible Schedule"

rename qid87_12 KeyEarnMore
replace KeyEarnMore = "1" if KeyEarnMore == "Earn more income"
destring KeyEarnMore , replace
replace KeyEarnMore = 0 if AnsweredKeyFactors > 0 & KeyEarnMore == .
replace KeyEarnMore = -777 if FounderFlag == 0
label var KeyEarnMore "Earn More"

rename qid87_13 KeyBestAvenue
replace KeyBestAvenue = "1" if KeyBestAvenue == ///
    "Best avenue for my ideas/goods/services"
destring KeyBestAvenue , replace
replace KeyBestAvenue = 0 if AnsweredKeyFactors > 0 & KeyBestAvenue == .
replace KeyBestAvenue = -777 if FounderFlag == 0
label var KeyBestAvenue "Best Avenue for Ideas"

rename qid87_14 KeyPositive
replace KeyPositive = "1" if KeyPositive == "Positive impact"
replace KeyPositive = "1" if KeyPositive == "Positive social impact"
destring KeyPositive , replace
replace KeyPositive = 0 if AnsweredKeyFactors > 0 & KeyPositive == .
replace KeyPositive = -777 if FounderFlag == 0
label var KeyPositive "Positive Impact"

rename qid87_15 KeyLearning
gen KeyLifeChangingMoney = .
replace KeyLearning = "1" if KeyLearning == "Learning opportunity"
replace KeyLifeChangingMoney = 1 if KeyLearning == "Chance to make a life-changing amount of money / get rich"
replace KeyLearning = "" if KeyLearning == "Chance to make a life-changing amount of money / get rich"
destring KeyLearning , replace
replace KeyLearning = 0 if AnsweredKeyFactors > 0 & KeyLearning == .
replace KeyLifeChangingMoney = 0 if AnsweredKeyFactors > 0 & KeyLifeChangingMoney == .
replace KeyLearning = -777 if FounderFlag == 0
replace KeyLifeChangingMoney = -777 if FounderFlag == 0
replace KeyLearning = -777 if inlist(SurveyRound, 2)
replace KeyLifeChangingMoney = -777 if inlist(SurveyRound, 1, 3, 4)
label var KeyLearning "Learning"
label var KeyLifeChangingMoney "Life Changing Amount of Money"

rename qid87_7 KeyOther
replace KeyOther = "1" if KeyOther == "Other "
destring KeyOther , replace
replace KeyOther = 0 if AnsweredKeyFactors > 0 & KeyOther == .
replace KeyOther = -777 if FounderFlag == 0
label var KeyOther "Other"

rename qid87_7_text TextKeyOther
replace TextKeyOther = "NA" if KeyOther == 0
replace TextKeyOther = "NA" if FounderFlag == 0

rename qid17 PreviousBusinessesTemp
replace PreviousBusinessesTemp = "0" if PreviousBusinessesTemp == ///
    "0 -- This is my first business"
replace PreviousBusinessesTemp = "NA" if FounderFlag == 0
encode PreviousBusinessesTemp, gen(PreviousBusinesses) label(PreviousBusinesses)
drop PreviousBusinessesTemp

rename q76 NumBusOwnedTemp
replace NumBusOwnedTemp = "1" if NumBusOwnedTemp == "1 -- Just this business"
replace NumBusOwned = "NA" if FounderFlag == 0
encode NumBusOwnedTemp, gen(NumBusOwned) label(NumBusOwned)
drop NumBusOwnedTemp

rename q86 FriendsBusinessFoundersTemp
encode FriendsBusinessFoundersTemp, gen(FriendsBusinessFounders) label(YesNo)
replace FriendsBusinessFounders = -777 if FounderFlag == 0
replace FriendsBusinessFounders = -999 if inlist(SurveyRound, 1, 3, 4)
drop FriendsBusinessFoundersTemp


rename qid76_1 FirstSaleYear
replace FirstSaleYear = -777 if FounderFlag == 0

rename qid90_1 FirstCostYear
replace FirstCostYear = -777 if FounderFlag == 0

gen DifSaleCostYear = FirstSaleYear - FirstCostYear
replace DifSaleCostYear = -777 if FounderFlag == 0
label variable DifSaleCost "Number of years it took for the first sale after the first business expenditure"

*******************************************************************************
** FUNDING
*******************************************************************************

egen AnsweredSources = rownonmiss(qid19_*) , strok

rename qid19_1 SourcesPersonalSavings
replace SourcesPersonalSavings = "1" if SourcesPersonalSavings == ///
    "Personal savings of founders, family, or friends (cash, home equity, etc.)"
destring SourcesPersonalSavings , replace
replace SourcesPersonalSavings = 0 if AnsweredSources > 0 ///
    & SourcesPersonalSavings == .
replace SourcesPersonalSavings = -777 if FounderFlag == 0
label var SourcesPersonalSavings "Personal"

rename qid19_2 SourcesCredit
replace SourcesCredit = "1" if SourcesCredit == "Credit cards"
destring SourcesCredit , replace
replace SourcesCredit = 0 if AnsweredSources > 0 & SourcesCredit == .
replace SourcesCredit = -777 if FounderFlag == 0
label var SourcesCredit "Credit Cards"

rename qid19_3 SourcesBankLoan
replace SourcesBankLoan = "1" if SourcesBankLoan == "Bank loans"
destring SourcesBankLoan , replace
replace SourcesBankLoan = 0 if AnsweredSources > 0 & SourcesBankLoan == .
replace SourcesBankLoan = -777 if FounderFlag == 0
label var SourcesBankLoan "Bank Loan"

rename qid19_4 SourcesGovLoan
replace SourcesGovLoan = "1" if SourcesGovLoan == "Government loans or grants"
destring SourcesGovLoan , replace
replace SourcesGovLoan = 0 if AnsweredSources > 0 & SourcesGovLoan == .
replace SourcesGovLoan = -777 if FounderFlag == 0
label var SourcesGovLoan "Government Loan"

rename qid19_6 SourcesInvestor
replace SourcesInvestor = "1" if SourcesInvestor == "Investment by venture capitalists, angel investors, incubators/accelerators"
destring SourcesInvestor , replace
replace SourcesInvestor = 0 if AnsweredSources > 0 & SourcesInvestor == .
replace SourcesInvestor = -777 if FounderFlag == 0
label var SourcesInvestor "Investor"

rename qid19_7 SourcesOther
replace SourcesOther = "1" if SourcesOther == "Other "
destring SourcesOther , replace
replace SourcesOther = 0 if AnsweredSources > 0 & SourcesOther == .
replace SourcesOther = -777 if FounderFlag == 0
label var SourcesOther "Other"

rename qid19_9 SourcesNone
replace SourcesNone = "1" if SourcesNone == "None needed"
destring SourcesNone , replace
replace SourcesNone = 0 if AnsweredSources > 0 & SourcesNone == .
replace SourcesNone = -777 if FounderFlag == 0
label var SourcesNone "None"

rename qid19_7_text TextSourcesOther
replace TextSourcesOther = "NA" if AnsweredSources > 0 & TextSourcesOther == ""
replace TextSourcesOther = "NA" if SourcesOther == 0
replace TextSourcesOther = "NA" if FounderFlag == 0

replace SourcesNone = 1 if TextSourcesOther == "None"
replace SourcesOther = 0 if TextSourcesOther == "None"
replace TextSourcesOther = "NA" if TextSourcesOther == "None"

rename qid33 StartingFundingTemp
replace StartingFunding = "NA" if FounderFlag == 0
replace StartingFunding = "NA" if SourcesNone == 1
encode StartingFundingTemp , gen(StartingFunding) label(StartingFunding)
drop StartingFundingTemp

*******************************************************************************
** BUSINESS CHARACTERISTICS
*******************************************************************************
rename qid22 Description
rename qid66 MissionStatement

egen AnsweredChallenges = rownonmiss(qid105_*) , strok

rename qid105_1 ChallengesFindingCust
replace ChallengesFindingCust = "1" if ChallengesFindingCust == ///
    "Finding customers"
destring ChallengesFindingCust , replace
replace ChallengesFindingCust = 0 if AnsweredChallenges > 0 & ChallengesFindingCust == .
replace ChallengesFindingCust = -777 if SurveyRound == 2
label var ChallengesFindingCust "Finding customers"

rename qid105_2 ChallengesFunding
replace ChallengesFunding = "1" if ChallengesFunding == "Funding"
destring ChallengesFunding , replace
replace ChallengesFunding = 0 if AnsweredChallenges > 0 & ChallengesFunding == .
replace ChallengesFunding = -777 if SurveyRound == 2
label var ChallengesFunding "Funding"

rename qid105_3 ChallengesHiring
replace ChallengesHiring = "1" if ChallengesHiring == "Hiring"
destring ChallengesHiring , replace
replace ChallengesHiring = 0 if AnsweredChallenges > 0 & ChallengesHiring == .
replace ChallengesHiring = -777 if SurveyRound == 2
label var ChallengesHiring "Hiring"

rename qid105_4 ChallengesRegulations
replace ChallengesRegulations = "1" if ChallengesRegulations == "Regulations"
destring ChallengesRegulations , replace
replace ChallengesRegulations = 0 if AnsweredChallenges > 0 & ChallengesRegulations == .
replace ChallengesRegulations = -777 if SurveyRound == 2
label var ChallengesRegulations "Regulations"

rename qid105_5 ChallengesCompetition
replace ChallengesCompetition = "1" if ChallengesCompetition == "Competition"
destring ChallengesCompetition , replace
replace ChallengesCompetition = 0 if AnsweredChallenges > 0 & ChallengesCompetition == .
replace ChallengesCompetition = -777 if SurveyRound == 2
label var ChallengesCompetition "Competition"

rename qid105_6 ChallengesOther
replace ChallengesOther = "1" if ChallengesOther == "Other: "
destring ChallengesOther , replace
replace ChallengesOther = 0 if AnsweredChallenges > 0 & ChallengesOther == .
replace ChallengesOther = -777 if SurveyRound == 2
label var ChallengesOther "Other"

rename qid105_7 ChallengesTaxes
replace ChallengesTaxes = "1" if ChallengesTaxes == "Taxes"
destring ChallengesTaxes , replace
replace ChallengesTaxes = 0 if AnsweredChallenges > 0 & ChallengesTaxes == .
replace ChallengesTaxes = -777 if SurveyRound == 2
label var ChallengesTaxes "Taxes"

rename qid105_6_text TextChallengesOther
replace TextChallengesOther = "NA" if ChallengesOther == 0
replace TextChallengesOther = "Missing" if SurveyRound == 2

rename qid23 HarderOrEasierTemp
replace HarderOrEasierTemp = "Missing" if inlist(SurveyRound, 1, 2)
replace HarderOrEasierTemp = proper(HarderOrEasierTemp)
encode HarderOrEasierTemp , gen(HarderOrEasier) label(HarderOrEasier)
drop HarderOrEasierTemp

rename q74 CatPercRevOnlineTemp
replace CatPercRevOnlineTemp = "Missing" if SurveyRound == 2
encode CatPercRevOnlineTemp , gen(CatPercRevOnline) label(CatPercRev)
drop CatPercRevOnlineTemp

rename q74new CatPercRevStripeTemp
replace CatPercRevStripeTemp = "Missing" if inlist(SurveyRound, 1, 3, 4)
encode CatPercRevStripeTemp , gen(CatPercRevStripe) label(CatPercRev)
drop CatPercRevStripeTemp

rename qid67 CodingProficientTemp
encode CodingProficientTemp, gen(CodingProficient) label(YesNo)
drop CodingProficientTemp

rename qid81 RevPast12Months
rename qid82 PercRevOnline
rename qid83 PercRevStripe

// TODO: Generate the qid87 graphs


*******************************************************************************
** PREDICTION
*******************************************************************************
rename qid91 RevPastMonth
gen RevPast3Months = .
replace RevPast3Months = RevPastMonth if SurveyRound == 2
replace RevPastMonth = . if SurveyRound == 2
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
replace NumPartTime = 2 if NumPartTime == 2.5

gen NumEmployees = NumFullTime + NumPartTime

rename qid29_4 PredictFullTime
rename qid29_5 PredictPartTime
rename qid68_4 NumSoftwareFullTime
rename qid68_5 NumSoftwarePartTime

rename qid30_1 FirstHireYear
replace FirstHireYear = "-777" if FirstHireYear == "Never"
destring FirstHireYear, replace

rename qid31 PercRevInternational
rename qid34 PredictRevInternational

*******************************************************************************
** Labor
*******************************************************************************
rename qid37 HoursPerWeek

rename qid38 WorkLocationTemp
replace WorkLocationTemp = "Home" if WorkLocationTemp == "At home"
replace WorkLocationTemp = "Office Space" if WorkLocationTemp == ///
    "In your own office space"
replace WorkLocationTemp = "Cafe/Public Space" if WorkLocationTemp == ///
    "In cafes or other public spaces"
replace WorkLocationTemp = "Co-working Space" if WorkLocationTemp == ///
    "In a dedicated co-working space"
encode WorkLocationTemp , gen(WorkLocation) label(WorkLocation)
drop WorkLocationTemp

rename qid38_5_text WorkLocationOtherText
replace WorkLocationOtherText = "NA" if WorkLocation != -888
rename qid39 EarningsPast12Months

rename qid40 OtherJobFlagTemp
encode OtherJobFlagTemp , gen(OtherJobFlag) label(YesNo)
drop OtherJobFlagTemp

*******************************************************************************
** OTHER JOB
*******************************************************************************
rename qid41 HoursPerWeekOtherJob
replace HoursPerWeekOtherJob = -777 if OtherJobFlag == 0

egen AnsweredWhyOtherJob = rownonmiss(qid42_*) , strok

rename qid42_1 WhyOtherJobIncome
replace WhyOtherJobIncome = "1" if WhyOtherJobIncome == ///
    "Need income to support myself"
destring WhyOtherJobIncome, replace
replace WhyOtherJobIncome = 0 if AnsweredWhyOtherJob  > 0 & WhyOtherJobIncome == .
replace WhyOtherJobIncome = -777 if OtherJobFlag == 0
label var WhyOtherJobIncome "Need Income"

rename qid42_2 WhyOtherJobMoreWork
replace WhyOtherJobMoreWork = "1" if WhyOtherJobMoreWork == ///
    "This business doesn't have enough work to occupy me full-time"
destring WhyOtherJobMoreWork, replace
replace WhyOtherJobMoreWork = 0 if AnsweredWhyOtherJob > 0 & WhyOtherJobMoreWork == .
replace WhyOtherJobMoreWork = -777 if OtherJobFlag == 0
label var WhyOtherJobMoreWork "Need More Work"

rename qid42_3 WhyOtherJobTesting
replace WhyOtherJobTesting = "1" if WhyOtherJobTesting == ///
    "I'm testing out whether I like running this business"
destring WhyOtherJobTesting, replace
replace WhyOtherJobTesting = 0 if AnsweredWhyOtherJob > 0 & WhyOtherJobTesting == .
replace WhyOtherJobTesting = -777 if OtherJobFlag == 0
label var WhyOtherJobTesting "Testing out Business"

rename qid42_4 WhyOtherJobEnjoy
replace WhyOtherJobEnjoy = "1" if WhyOtherJobEnjoy == ///
    "I enjoy my current job, I have no intention to quit"
destring WhyOtherJobEnjoy, replace
replace WhyOtherJobEnjoy = 0 if AnsweredWhyOtherJob > 0 & WhyOtherJobEnjoy == .
replace WhyOtherJobEnjoy = -777 if OtherJobFlag == 0
label var WhyOtherJobEnjoy "Enjoy Current Job"

rename qid42_5 WhyOtherJobOther
replace WhyOtherJobOther = "1" if WhyOtherJobOther == "Other"
destring WhyOtherJobOther, replace
replace WhyOtherJobOther = 0 if AnsweredWhyOtherJob > 0 & WhyOtherJobOther == .
replace WhyOtherJobOther = -777 if OtherJobFlag == 0
label var WhyOtherJobOther "Other"

rename qid42_5 TextWhyOtherJobOther
replace TextWhyOtherJobOther = "NA" if WhyOtherJobOther == 0
replace TextWhyOtherJobOther = "NA" if OtherJobFlag == 0

rename qid43 OtherJobIncome
replace OtherJobIncome = -777 if OtherJobFlag == 0

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

*******************************************************************************
** Previous Job
*******************************************************************************

rename qid69 PrevJobFlagTemp
replace PrevJobFlagTemp = "NA" if OtherJobFlag == 1
encode PrevJobFlagTemp , gen(PrevJobFlag) label(YesNo)
drop PrevJobFlagTemp


rename qid70 HowLeftPrevJobTemp
replace HowLeftPrevJobTemp = trim(HowLeftPrevJobTemp)
replace HowLeftPrevJobTemp = "Quit" if HowLeftPrevJobTemp == "I quit the job"
replace HowLeftPrevJobTemp = "Laid Off/Fired" if HowLeftPrevJobTemp == "I was laid off or fired"
replace HowLeftPrevJobTemp = "Employer Closed" if HowLeftPrevJobTemp == "The employer closed"
replace HowLeftPrevJobTemp = "NA" if inlist(PrevJobFlag, -777, 0)
encode HowLeftPrevJobTemp , gen(HowLeftPrevJob) label(HowLeftPrevJob)
drop HowLeftPrevJobTemp

rename qid70_4_text HowLeftPrevJobText
replace HowLeftPrevJobText = "NA" if HowLeftPrevJob != -888

gen QuitFlag = 0
replace QuitFlag = 1 if HowLeftPrevJob == 1
replace QuitFlag = -777 if inlist(PrevJobFlag, -777, 0)

rename qid46 PrevJobQuitReasonTemp
replace PrevJobQuitReasonTemp = "Focus on This" if PrevJobQuitReasonTemp == "To focus full-time on this business"
replace PrevJobQuitReasonTemp = "Explore Business Ideas" if PrevJobQuitReasonTemp == "To explore various business ideas"
replace PrevJobQuitReasonTemp = "Find Other Jobs" if PrevJobQuitReasonTemp == "To look for other jobs"
replace PrevJobQuitReasonTemp = "Break" if PrevJobQuitReasonTemp == "To take a break / enjoy life"
replace PrevJobQuitReasonTemp = "Other" if PrevJobQuitReasonTemp == "Other "
replace PrevJobQuitReason = "NA" if QuitFlag != 1
encode PrevJobQuitReasonTemp, gen(PrevJobQuitReason) label(PrevJobQuitReason)
drop PrevJobQuitReasonTemp

rename qid46_2_text PrevJobQuitReasonText
replace PrevJobQuitReasonText = "NA" if PrevJobQuitReason != -888

rename qid47_1 QuitPrevJobYear
replace QuitPrevJobYear = -777 if QuitFlag != 1

rename qid47_2 QuitPrevJobMonthTemp
replace QuitPrevJobMonthTemp = "NA" if QuitFlag != 1
encode QuitPrevJobMonthTemp , gen(QuitPrevJobMonth) label(Months)
drop QuitPrevJobMonthTemp

rename qid71_1 PrevJobEndYear
replace PrevJobEndYear = -777 if OtherJobFlag == 1
replace PrevJobEndYear = -777 if inlist(PrevJobFlag, 0, -777)
replace PrevJobEndYear = -777 if QuitFlag == 1

rename qid71_2 PrevJobEndMonthTemp
replace PrevJobEndMonthTemp = "NA" if OtherJobFlag == 1
replace PrevJobEndMonthTemp = "NA" if inlist(PrevJobFlag, 0, -777)
replace PrevJobEndMonthTemp = "NA" if QuitFlag == 1
encode PrevJobEndMonthTemp , gen(PrevJobEndMonth) label(Months)
drop PrevJobEndMonthTemp

rename qid48 PrevJobIncome
replace PrevJobIncome = subinstr(PrevJobIncome, ",", "", .)
destring PrevJobIncome, replace
replace PrevJobIncome = -777 if PrevJobFlag != 1


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

*******************************************************************************
** DEMOGRAPHICS
*******************************************************************************
rename qid72_1 CountryTemp
encode CountryTemp , gen(Country) label(Country)
drop CountryTemp

rename qid73 ZipCode

rename qid53 FemaleTemp
encode FemaleTemp, gen(Female) label(Female)
drop FemaleTemp

rename qid54 Age

rename qid55 EducationTemp
replace EducationTemp = "Bachelors" if EducationTemp == "Bachelor's degree"
replace EducationTemp = "2-Year Degree" if EducationTemp == "Associate degree"
replace EducationTemp = "High School" if EducationTemp == ///
    "High school graduate - diploma or GED"
replace EducationTemp = "< High School" if EducationTemp == ///
    "Less than high school graduate"
replace EducationTemp = "Masters+" if EducationTemp == ///
    "Master's, doctorate, or professional degree"
replace EducationTemp = "2-Year Degree" if ///
    EducationTemp == "Technical, trade or vocational school"
replace EducationTemp = "2-Year Degree" if ///
    EducationTemp == "Associate, vocational, technical, or trade degree"
replace EducationTemp = "Some College" if EducationTemp == ///
    "Some college, but no degree"
encode EducationTemp, gen(Education) label(Education)
drop EducationTemp

egen AnsweredDegree = rownonmiss(q78_*) , strok

rename q78_1 DegreeSTEM
replace DegreeSTEM = "1" if DegreeSTEM == ///
    "Science, Technology, Engineering, Mathematics (STEM)"
destring DegreeSTEM, replace
replace DegreeSTEM = 0 if AnsweredDegree > 0 & DegreeSTEM == .
replace DegreeSTEM = -777 if inlist(Education, 1, 2)
replace DegreeSTEM = -999 if inlist(Education, 1, 2)
label var DegreeSTEM "STEM"

rename q78_2 DegreeEconBus
replace DegreeEconBus = "1" if DegreeEconBus == ///
    "Economics, Business, Management"
destring DegreeEconBus, replace
replace DegreeEconBus = 0 if AnsweredDegree > 0 & DegreeEconBus == .
replace DegreeEconBus = -777 if inlist(Education, 1, 2)
replace DegreeEconBus = -999 if inlist(Education, 1, 2)
label var DegreeEconBus "Economics, Business, Management"

rename q78_3 DegreeSocialSciences
replace DegreeSocialSciences = "1" if regexm(DegreeSocialSciences, ///
    "Politics, Sociology and other [Ss]ocial [Ss]ciences")
destring DegreeSocialSciences, replace
replace DegreeSocialSciences = 0 if AnsweredDegree > 0 & DegreeSocialSciences == .
replace DegreeSocialSciences = -777 if inlist(Education, 1, 2)
replace DegreeSocialSciences = -999 if inlist(Education, 1, 2)
label var DegreeSocialSciences "Politics, Sociology and other Social Sciences"

rename q78_4 DegreeLaw
replace DegreeLaw = "1" if DegreeLaw == ///
    "Law"
destring DegreeLaw, replace
replace DegreeLaw = 0 if AnsweredDegree > 0 & DegreeLaw == .
replace DegreeLaw = -777 if inlist(Education, 1, 2)
replace DegreeLaw = -999 if inlist(Education, 1, 2)
label var DegreeLaw "Law"

rename q78_5 DegreeHumanitiesArts
replace DegreeHumanitiesArts = "1" if DegreeHumanitiesArts == ///
    "Humanities and Arts"
destring DegreeHumanitiesArts, replace
replace DegreeHumanitiesArts = 0 if AnsweredDegree > 0 & DegreeHumanitiesArts == .
replace DegreeHumanitiesArts = -777 if inlist(Education, 1, 2)
replace DegreeHumanitiesArts = -999 if inlist(Education, 1, 2)
label var DegreeHumanitiesArts "Humanities and Arts"

rename q78_6 DegreeOther
replace DegreeOther= "1" if DegreeOther == ///
    "Other"
destring DegreeOther, replace
replace DegreeOther = 0 if AnsweredDegree > 0 & DegreeOther == .
replace DegreeOther = -777 if inlist(Education, 1, 2)
replace DegreeOther = -999 if inlist(Education, 1, 2)
label var DegreeOther "Other"

rename qid56 ShareText
rename qid97 Topics
drop Topics

drop if FirstName == "Kerenssa" & LastName == "Kay"
drop if LastName == "" & FirstName == ""

save "`save'", replace

keep if SurveyRound == 2
gen test = Predict3Months / RevPast3Month
replace test = -777 if RevPast3Month == 0

count if (test >0 & test <= .25) | (test >=4)
count if (test >0 & test <= .2) | (test >=5)
pretty (hist test, xlogbase(1.2)) , name("PredVsActual3") save("/tmp/PredVsActual3.eps")



* keep if Finished == 1
