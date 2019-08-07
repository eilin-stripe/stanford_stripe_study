# Cleaning Documentation

## Overview
This directory contains files used for the purpose of cleaning raw data. In particular, they reference the raw data in Data/Raw, edit them, and then store them in Data/Clean

### File List - Survey data

#### CleanConversion.do
-   This creates conversion tables that tell us how likely respondents are to move from one step to the next (e.g from opening the email, to starting the survey, to finishing it.)

#### CleanDemographicsData.do
-   This cleans the internal Stripe Data extracts to merge in with the Survey data

#### CleanPayment.do
-   Cleans the survey data to generate new lists for payment

#### CleanPilot.do
-   Cleans the survey data for the main analysis

#### CleanRecords.do
-   Cleans Sales history records for checking Prediction accuracy

#### CleanSampling.do
-   Cleans the original sampling data used in the pilots, Wave 1, and Wave 2

#### CleanSampling2.do
-   Cleans the updated sampling data used in Wave 3

#### MergeData.do
-   Merges the survey data with the internal records data and the sampling data

### File List - Survey Data Analysis

#### Predictions.do


### File List - Observational Data

#### CleanCharacteristics.do
Cleans up the static characteristics of firms in the panel, such as location, estimated gender of the stripe account holder, etc.

#### CleanEmployeePanel.do
-   Takes the raw employee count data from Stripe and cleans it

#### CleanGDP.do
-   Cleans GDP data
-   Input raw **qgsp_all.csv**
-   Output clean **state_gdp.dta** and **state_gdp_industry.dta**

#### CleanMCC.do
-   Cleans a list of MCC codes in order to merge them into the Stripe Data
-   Input raw **mcc_codes.dta**
-   Output clean **mcc_codes.dta**

#### CleanPanel.do
-   Cleans up the panel of firms for analysis of growth rates
-   Input - **panel_may11.dta**
-   Ouput - **PanelActivated.dta**
-   Merges In - **EmployeePanel.data** (if it's not commented out)

#### CleanDisputes.do
-   Cleans panel data on disputes and fraud for the main sample
