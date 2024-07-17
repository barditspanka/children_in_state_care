*******************************************************************************
*Family foster care or residential care: the impact of home environment on children raised in state care
*Anna Bárdits, Gábor Kertesi
*2024
******************************************************************************

*set working directory
cd "/homeKRTK/barditsa_prosp/children_in_state_care"
*-------------------------------------------------------------------------------
cap log close
log using "Log/test_240305", replace
disp "DateTime: $S_DATE $S_TIME"


*install required packages


*clean and prepare data for main analysis
do "Do/create_clean_dataset.do"
do "Do/create_regression_sample.do"

*do additional cleaning and data preparation for robustness checks
do "Do/create_regression_sample_h6sc8.do"
do "Do/create_regression_sample_just6.do"


*run analysis
do "Do/analyze_data.do"



disp "DateTime: $S_DATE $S_TIME"
log close
********************************************************************************


