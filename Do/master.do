*******************************************************************************
*The Gains from Family Foster Care: Evidence from HUngary
*Anna Bárdits, Gábor Kertesi
*2023
******************************************************************************

*set working directory
cd "/homeKRTK/barditsa_prosp/children_in_state_care"
*-------------------------------------------------------------------------------
cap log close
log using "Log/test_250506", replace
disp "DateTime: $S_DATE $S_TIME"


*install required packages


*clean and prepare data for main analysis
do "Do/create_clean_dataset.do"
do "Do/create_regression_sample.do"

*do additional cleaning and data preparation for robustness checks
do "Do/create_regression_sample_h6sc8.do"
do "Do/create_regression_sample_m6sc8.do"
do "Do/create_regression_sample_maxage18.do"
do "Do/create_regression_sample_maxage19.do"
do "Do/create_regression_sample_maxage20.do"
do "Do/create_regression_sample_maxage18.do"
do "Do/create_regression_sample_maxage19.do"
do "Do/create_regression_sample_maxage20.do"

*run analysis
do "Do/analyze_data.do"



disp "DateTime: $S_DATE $S_TIME"
log close
********************************************************************************


