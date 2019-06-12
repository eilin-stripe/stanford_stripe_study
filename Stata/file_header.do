** Data Directories
local data = "`base'/Data"

** Raw Data
local raw_data = "`data'/Raw"
local raw_geo = "`raw_data'/Geo"
local raw_industry = "`raw_data'/Industry"
local raw_economy = "`raw_data'/Economy"
local raw_stripe = "`raw_data'/Stripe"
local raw_survey = "`raw_data'/Survey"
local raw_completed = "`raw_survey'/CompletedWaves"
local raw_internal = "`raw_survey'/Internal"
local raw_sampling = "`raw_survey'/Sampling"
local raw_operations = "`raw_survey'/Operations"
local raw_distribution = "`raw_survey'/Distribution"
local ReferenceUSA = "`raw_data'/ReferenceUSA"
local compustat = "`raw_data'/Compustat"
local tiger = "`raw_geo'/TIGER"
local raw_bds = "`raw_data'/BDS"
local raw_ase = "`raw_data'/ASE"

** Clean Data
local clean_data = "`data'/Clean"
local clean_geo = "`clean_data'/Geo"
local clean_industry = "`clean_data'/Industry"
local clean_economy = "`clean_data'/Economy"
local clean_stripe = "`clean_data'/Stripe"
local clean_survey = "`clean_data'/Survey"
local clean_payment = "`clean_survey'/Payment"
local clean_internal = "`clean_survey'/Internal"
local clean_sampling= "`clean_survey'/Sampling"
local clean_main_survey = "`clean_survey'/MainSurvey"
local clean_conversion = "`clean_survey'/Conversion"

** Simulated Data
local sim_data = "`data'/Simulated"


local main_panel = "`clean_stripe'/PanelActivated.dta"


** Code Directories
local code = "`base'/Code"
local stata = "`code'/Stata"
local clean_stata = "`stata'/Clean"


** Output Directories
local output = "`base'/Output"


** Other
local sandbox = "`base'/Sandbox"

*******************************************************************************
** Define Value Labels for General Use
*******************************************************************************
// General
label define TrueFalse 0 "False" 1 "True"
label define YesNo 0 "No" 1 "Yes" -777 "NA" -999 "Missing"

// Survey Variables
label define Language 1 EN
label define Consent 1 "I consent"
label define PreviousBusinesses 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+" -777 "NA"
label define NumBusOwned 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+" -777 "NA"
label define StartingFunding 1 "Less than $1,000" ///
    2 "$1,000-$4,999" 3 "$5,000-$9,999" 4 "$10,000-$24,999" ///
    5 "$25,000-$49,000" 6 "$50,000-$99,000" 7 "$100,000-$249,999" ///
    8 "$250,000-$999,999" 9 "$1,000,000-$2,999,000" 10 "$3,000,000 or more" ///
    -777 "NA"
label define HarderOrEasier 1 "Easier" 2 "No Change" 3 "Harder" -777 "NA" -999 "Missing"
label define CatPercRev 1 "0-24%" 2 "25-49%" 3 "50-74%" 4 "75-100%" -999 "Missing"
label define WorkLocation 1 "Home" 2 "Cafe/Public Space" 3 "Co-Working Space" ///
    4 "Office Space" -888 "Other"
label define HowLeftPrevJob 1 "Quit" 2 "Laid Off/Fired" ///
    3 "Employer Closed" -888 "Other" -777 "NA"
label define PrevJobQuitReason 1 "Focus on This" 2 "Explore Business Ideas" ///
    3 "Find Other Jobs" 4 "Break" -888 "Other" -777 "NA"
label define Months 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" ///
    6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" ///
    12 "December" -777 "NA"
label define Country 1 "United States" -888 "Other"
label define Female 0 "Male" 1 "Female"
label define Education 1 "< High School" 2 "High School" ///
    3 "Some College" 4 "2-Year Degree" ///
    5 "Bachelors" 6 "Masters+"
label define NumFounders 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+" -777 "NA"

// Sampling Variables
label define Wave 1 "Wave 1" 2 "Wave 2" 3 "Wave 3" 21 "mass pilot 1" 22 "mass pilot 2 (attempt 2)" ///
    23 "mass pilot 2 sending failed" 24 "mass pilot 3" 25 "mass pilot 4" ///
    26 "mass pilot 5"
label define SurveyRound 1 "Wave1" 2 "Wave2" 3 "Pilot1" 4 "Pilot2"
label define Strata 0 "Small" 1 "Big" 2 "Funded"
label define SmallBig 1 Small 2 Big
label define DistributionChannel 1 Email 2 Anonymous

// Stripe Internal Variables
label define CompanyProfile 1 "Small Business" 2 "Medium Business" ///
    3 "Large Business" 4 "Enterprise" 5 "Startup" 6 "Growth" 7 "Late Stage"
label define LegalType 1 "Sole Prop" 2 "Partnership" 3 "LLC" ///
    4 "Corporation" 5 "Non Profit"
label define ConnectType 1 "Direct" 2 "Standard" 3 "Platform" ///
    4 "Express"

// Round 2 Variables
label define PhysicalOnlineBoth 1 "Physical" 2 "Online" 3 "Both"
label define NumKPIs 0 "0" 1 "1-2" 2 "3-9" 3 "10+"
label define Frequency 0 "Never" 1 "Yearly" 2 "Quarterly" ///
     3 "Monthly" 4 "Weekly" 5 "Daily"
label define ProblemAdressingMethod ///
    0 "No problem has ever arisen" 1 "Fixed it, no further action" ///
    2 "Fixed it, took further action" 3 "Continuous improvement process"
label define TargetsTimeFrame ///
    0 "No targets" 1 "Short term" 2 "Long term" 3 "Both"
label define TargetsDifficulty ///
    1 "Minimal Effort" 2 "Less than normal effort" 3 "Normal effort" ///
    4 "More than normal effort" 5 "Extraordinary effort"
label define HowPromoteEmployees ///
    1 "Not normally promoted" 2 "Partly performance/ability" ///
    3 "Solely performance/ability"
label define UnderperforingEmployee ///
    0 "None Identified" 1 "Never" 2 "< 6 Months" 3 "> 6 Months"
label define RecordsMethod ///
    0 "No Records" 1 "Paper" 2 "Electronic" 3 "Kept by another business"
label define RecordsUsedHow ///
    1 "Taxes" 2 "Targeting Customers" 3 "Forecasting Demand" ///
    4 "Ordering Inputs" 5 "Product Design"  ///
    6 "Scheudling Deliveries" -888 "Other" 



*******************************************************************************
