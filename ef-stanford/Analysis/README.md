# Analysis Code

This Directory contains all the Stata code for the analysis of this project.

## File Listing

### Survey analysis

#### SurveyStats.do
Does basic stats covering nearly all of the questions in the survey (a few may be missing and need to be added)

#### CompletionPredictors.do
Looks at what predicts whether or not someone invited to take the survey ultimately takes and finished the survey. There is a more extensive analysis in the python folder

#### Predictions.do
Analyzes how accurate predictions are. Is currently a precursor to the accuracy check file for whether or not individuals won the prize

#### CheckMonthlyReported.do
Checks how reported monthly revenue compares with observed monthly revenue

#### CheckAnnualReported.do
Checks how reported annual revenue compares with observed annual revenue


### Observational Analysis

#### explore_growth.do
This produces some simple histograms of what growth looks like and then looks at how the variance in growth decreases over time

#### IndustryFocus.do
This produces graphs of how growth fluctuates over time within industries.

#### explore_years_out.do
Looks at how likely a firm is to have a sale in the next x number of years based on its recent sales history.
