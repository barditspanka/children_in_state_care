********************************************************************************
*Data analysis for chilrden in state care
*code by Anna Bárdits, 06/05/2025
********************************************************************************
*set working directory (only needed if run without data preparation)
cd "/homeKRTK/barditsa_prosp/children_in_state_care"

set scheme cleanplots
*use "Output_data/CISC_regdata-just6.dta", clear
*the age at which 
global maxage=19


*******************************************************************************
*Figures and Tables in the order they appear in the manuscript
******************************************************************************
*-------------------------------------------------------------------------------
* Figure 1
*-------------------------------------------------------------------------------
do "Do/fig_countries_res_ratio.do"


use "Output_data/CISC_regdata.dta", clear

global maxage=19

global controls ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.sni i.num_siblings

global mcontrols ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.sni i.num_siblings


*controls in descriptive table
global desccontrols m_zpsc o_zpsc grade*_nomiss numsiblings_nomiss boy age snidummy* late_schoolstarter



*outcome variables
global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index



*-------------------------------------------------------------------------------
*Table 1 - Descriptive statistics
*-------------------------------------------------------------------------------

eststo clear

foreach x of varlist $desccontrols $outcomes{
	
eststo: reg `x' foster, robust

}

*p values for differences
esttab, se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) 
esttab using "Results/descriptives_pvalues.csv", se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) replace

*means of the variables
preserve
drop if missing(foster)
	gcollapse (mean) $desccontrols $outcomes, by(foster)
	export excel "Results/descriptives.xls", firstrow(variables) 	replace

restore


*-------------------------------------------------------------------------------
*Table 2 OLS with oster bounds - 
*-------------------------------------------------------------------------------

*create dummy variables for oster for oster
tab m_szint, gen(oster_mszint)
tab o_szint, gen(oster_oszint)
tab grade_math, gen(oster_grade_math)
tab grade_grammar, gen(oster_grade_grammar)
tab grade_lit, gen(oster_grade_lit)
tab grade_behav, gen(oster_grade_behav)
tab grade_effort, gen(oster_grade_effort)
tab age_cat_6_grade, gen(oster_age_cat)
tab year19, gen(oster_year19)
tab county_gr6, gen(oster_county)
tab num_siblings, gen(oster_siblings)

global mcontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.num_siblings

*calculate OSter bounds for all outcomes with delta values
foreach x of varlist $outcomes{

	
disp "-------------------------------------------------------"	
disp "OUTCOME `x' NO CONTROLS"
reg  `x'  i.foster, robust

disp "-------------------------------------------------------"	
disp "OUTCOME `x' BASELINE CONTROLS"
reg  `x'  i.foster /*
*/i.boy i.year${maxage} i.county_gr6 i.num_siblings i.age_cat_6_grade, robust

disp "OUTCOME `x' COGNITIVE CONTROLS"
reg  `x'  i.foster /*
*/ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit, robust

disp "OUTCOME `x' BEHAV CONTROLS"
reg `x'  i.foster ib(3).grade_behav ib(3).grade_effort i.sni, robust

disp "OUTCOME `x' BEHAV CONTROLS + BASELINE"
reg `x'  i.foster ib(3).grade_behav ib(3).grade_effort i.sni i.age_cat_6_grade i.boy i.year${maxage} i.county_gr6 i.num_siblings, robust

disp "-------------------------------------------------------"
disp "OUTCOME `x' ALL CONTROLS"

reg  `x'  i.foster $controls, robust

quietly regress `x' foster oster_mszint1 oster_mszint2 oster_mszint3 oster_mszint5 oster_mszint6 oster_mszint7 oster_mszint8 oster_mszint9  oster_oszint1 oster_oszint2 oster_oszint3 oster_oszint5 oster_oszint6 oster_oszint7 oster_oszint8 oster_oszint9 oster_grade_math1 oster_grade_math2 oster_grade_math4 oster_grade_math5 oster_grade_math6 oster_grade_grammar1 oster_grade_grammar2 oster_grade_grammar4 oster_grade_grammar5 oster_grade_grammar6 oster_grade_lit1 oster_grade_lit2 oster_grade_lit4 oster_grade_lit5 oster_grade_lit6 oster_grade_behav1 oster_grade_behav2 oster_grade_behav4 oster_grade_behav5 oster_grade_behav6 oster_grade_effort1 oster_grade_effort2 oster_grade_effort4 oster_grade_effort5 oster_grade_effort6 boy oster_age_cat2 oster_age_cat3 oster_age_cat4 oster_year192 oster_year193 oster_year194  oster_year195  oster_year196  oster_year197  oster_year198 oster_year199  oster_year1910 i.sni oster_county2 oster_county3 oster_county4 oster_county5 oster_county6 oster_county7 oster_county8 oster_county9 oster_county10 oster_county11 oster_county12 oster_county13 oster_county14 oster_county15 oster_county16 oster_county17 oster_county18 oster_county18 oster_county19 oster_county20 oster_county21 oster_siblings2 oster_siblings3 oster_siblings4 oster_siblings5 oster_siblings6 oster_siblings7, robust

*using rmax - 1.3*r2 from the regression with the fulls et of controls
local rmax=1.3*e(r2)

disp "-------------------------------------------------------"
disp "`x' ALL CONTROLS"
psacalc beta foster, rmax(`rmax')

disp "`x' ALL CONTROLS DELTA"
psacalc delta foster, rmax(`rmax')

disp "-------------------------------------------------------"
disp "`x' MCONTROLS"
psacalc beta foster, rmax(`rmax') mcontrol(oster_grade_behav1 oster_grade_behav2 oster_grade_behav4 oster_grade_behav5 oster_grade_behav6 oster_grade_effort1 oster_grade_effort2 oster_grade_effort4 oster_grade_effort5 oster_grade_effort6 boy oster_age_cat2 oster_age_cat3 oster_age_cat4 oster_year192 oster_year193 oster_year194  oster_year195  oster_year196  oster_year197  oster_year198 oster_year199  oster_year1910 i.sni oster_county2 oster_county3 oster_county4 oster_county5 oster_county6 oster_county7 oster_county8 oster_county9 oster_county10 oster_county11 oster_county12 oster_county13 oster_county14 oster_county15 oster_county16 oster_county17 oster_county18 oster_county18 oster_county19 oster_county20 oster_county21 oster_siblings2 oster_siblings3 oster_siblings4 oster_siblings5 oster_siblings6 oster_siblings7)

disp "-------------------------------------------------------"
disp "`x' delta MCONTROLS"
psacalc delta foster, rmax(`rmax') mcontrol(oster_grade_behav1 oster_grade_behav2 oster_grade_behav4 oster_grade_behav5 oster_grade_behav6 oster_grade_effort1 oster_grade_effort2 oster_grade_effort4 oster_grade_effort5 oster_grade_effort6 boy oster_age_cat2 oster_age_cat3 oster_age_cat4 oster_year192 oster_year193 oster_year194  oster_year195  oster_year196  oster_year197  oster_year198 oster_year199  oster_year1910 i.sni oster_county2 oster_county3 oster_county4 oster_county5 oster_county6 oster_county7 oster_county8 oster_county9 oster_county10 oster_county11 oster_county12 oster_county13 oster_county14 oster_county15 oster_county16 oster_county17 oster_county18 oster_county18 oster_county19 oster_county20 oster_county21 oster_siblings2 oster_siblings3 oster_siblings4 oster_siblings5 oster_siblings6 oster_siblings7)


}

*regression results to table
eststo clear
foreach x of varlist $outcomes{
	
reg `x' i.foster $controls, robust
eststo `x'_olsc	
}

esttab, keep(1.foster) b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_main_ols.tex", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_main_ols.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab, keep(1.foster) se star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*uncontrolled difference for comparison
eststo clear
foreach x of varlist $outcomes {
	
reg `x' i.foster, robust
eststo `x'_ols
	
}
esttab
esttab using "Results/regresult_main_descdiff.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Table 3. OLS by foster mother's education
*-------------------------------------------------------------------------------
eststo clear

foreach x of varlist $outcomes outcome_index{
reg `x' i.foster_by_educ $controls, robust
eststo `x'	
}

esttab , keep(1.foster_by_educ 2.foster_by_educ) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_feduc.tex", keep(1.foster_by_educ 2.foster_by_educ) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_feduc.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

eststo clear

*check if difference is stat significant

foreach x of varlist $outcomes outcome_index{
reg `x' ib(1).foster_by_educ $controls, robust
eststo `x'	
}

esttab , keep(0.foster_by_educ 2.foster_by_educ) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)


*-------------------------------------------------------------------------------
*Table 4 OLS by gender
*-------------------------------------------------------------------------------
*heterogenous effects
*gender
cap drop girl
gen girl=1-boy
global bgcontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.sni i.age_cat_6_grade i.year${maxage} i.county_gr6 i.num_siblings

eststo clear
foreach x of varlist $outcomes{
reg `x' i.foster##i.girl $bgcontrols , robust
eststo `x'	

}

esttab, keep(1.foster 1.foster#1.girl) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_main_boygirl.tex", keep(1.foster 1.foster#1.girl) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_main_boygirl.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Table 5 - The effect of foster parent capcity on outcomes, reduced form
*-------------------------------------------------------------------------------
*prepare data for IV
*high, low fostermum rate, cut at median
cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=23
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>23 & !missing(fostermums_100kid_pest)


global countycontrols employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c

global ivcontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.sni i.num_siblings komplex_c  employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c


eststo clear
foreach x of varlist $outcomes outcome_index{	
/*reg `x' i.fostermums_rate01_pest $countycontrols if county_gr6!=. & county_gr6!=99 & foster<=1, vce(cluster county_gr6) 
eststo `x'_ivnoc*/	
reg `x' i.fostermums_rate01_pest $ivcontrols if county_gr6!=. & county_gr6!=99 & foster<=1, robust
eststo `x'_ivc
	
}

esttab , keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 

esttab using "Results/reg_iv_reduced_idiv.tex", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/reg_iv_reduced_indiv.csv", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

*control means
foreach x of varlist $outcomes outcome_index{
sum `x' if fostermums_rate01_pest==0 & !missing(foster)
}

*-------------------------------------------------------------------------------
*Table 7 - Placebo
*-------------------------------------------------------------------------------


global outcomes_p secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index_all

eststo clear
foreach x of varlist $outcomes_p {		
reg `x' i.fostermums_rate01_pest $ivcontrols  if county_gr6!=. & county_gr6!=99 & home_type_clean==0, robust
eststo `x'_ivc	
}

esttab , keep(1.fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 
esttab using "Results/reg_iv_placebo.tex", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/reg_iv_placebo.csv", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

*control means
foreach x of varlist $outcomes_p {
sum `x' if fostermums_rate01_pest==0 & home_type_clean==0 & county_gr6!=. & county_gr6!=99 
}



*-------------------------------------------------------------------------------
*Figure 2 - Specification curve analysis
*-------------------------------------------------------------------------------
*this runs all regression and saves values needed for the curve. The plot itself is made by a sperate R script

do "Do/specification_curve_analysis.do"

*run nullfied version for the bootstrap

do "Do/specification_curve_analysis_bootsrap.do"


********************************************************************************
*APPENDIX
********************************************************************************
*-------------------------------------------------------------------------------
*Figure A1 - hun residential ratio
*-------------------------------------------------------------------------------

do "Do/fig_residential_ratio_hun.do"


*-------------------------------------------------------------------------------
*Figure A2 - foster parent capacity by counnty
*-------------------------------------------------------------------------------
use "Output_data/county_data.dta", clear


*use foster mothers in 2015
gen foster_mother_s=foster_mother if ev==2015
bysort county: gegen foster_mother_2015=max(foster_mother_s)


gen num_statecare=2444/2 if county==1
replace num_statecare=778/2 if county==2
replace num_statecare=1253/2 if county==3
replace num_statecare=704/2 if county==4
replace num_statecare=2260/2 if county==5
replace num_statecare=670/2 if county==6
replace num_statecare=690/2 if county==7
replace num_statecare=415/2 if county==8
replace num_statecare=1606/2 if county==9
replace num_statecare=456/2 if county==10
replace num_statecare=457/2 if county==11
replace num_statecare=322/2 if county==12
replace num_statecare=2313/2 if county==13
replace num_statecare=886/2 if county==14
replace num_statecare=2366/2 if county==15
replace num_statecare=905/2 if county==16
replace num_statecare=468/2 if county==17
replace num_statecare=379/2 if county==18
replace num_statecare=468/2 if county==19
replace num_statecare=432/2 if county==20

gen fostermums_100kid=foster_mother_2015/num_statecare*100

gen county_pest=county
replace county_pest=21 if county==1 | county==13
lab var county_pest "bp and pest togehther"

label define megye 21"Pest+Budapest", add
label values county_pest megye

gen foster_mother_2015_pest=foster_mother_2015
replace foster_mother_2015_pest=67+283 if county_pest==21


gen num_statecare_pest=num_statecare
replace num_statecare_pest=2444+2313 if county_pest==21

gen fostermums_100kid_pest= foster_mother_2015_pest/num_statecare_pest*100

rename * *_c

rename county_c county_gr6

*pest+bp one entity

keep if ev_c==2015

collapse (mean) mean_wagen fostermums_100kid_c, by(county_pest)
egen pos_var=mlabvpos(fostermums_100kid_c mean_wagen)
twoway scatter fostermums_100kid_c mean_wagen, mlab(county_pest) mlabvpos(pos_var) xtitle(Mean wage in county (monthly HUF), size(large)) ytitle("Number of foster mothers" "per 100 child in statecare", size(large)) xscale(range(150000(25000)280000)) xlabel(,labsize(large)) ylabel(,labsize(large))|| lfit fostermums_100kid_c mean_wagen, legend(off)

graph export "Results/wage_fmcapacity.png", replace

*-------------------------------------------------------------------------------
*Figures A3 - A7 preapred during specification curve naanylis, and R scripts produce the plots
*------------------------------------------------------------------------------


*-------------------------------------------------------------------------------
*Table A3 - q vaules
*-------------------------------------------------------------------------------
*uncomment and follow the prompt if replication is needed, and copy  Input_data/p_values_for_fdr.xls for the pvlaues.
*do "Do/fdr_sharpened_qvalues.do"

*-------------------------------------------------------------------------------
*Table A4 -OLS including children living with own parents
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata.dta", clear


*Regression on full sample for effect size comparison

cap drop home_type_nok
gen home_type_nok=home_type_clean if home_type_clean!=1
eststo clear
foreach x of varlist $outcomes_p {
reg `x' i.home_type_nok $controls, robust
eststo `x'
}

esttab, keep(2.home_type_nok 3.home_type_nok) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_all.tex", keep(2.home_type_nok 3.home_type_nok) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_all.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


esttab , keep(1.fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 

*control means
foreach x of varlist $outcomes_p {
sum `x' if home_type_clean==0 & !missing(county_gr6) & county_gr6!=99
}

*-------------------------------------------------------------------------------
*Table A5 - OSter bounds for model 5 and 6
*-------------------------------------------------------------------------------
*already prepred in Table2

*-------------------------------------------------------------------------------
*Table A6 - foster mother qaulity
*-------------------------------------------------------------------------------

tab mother_educ

gen fmother_hschool=.
replace fmother_hschool=0 if mother_educ<=3
replace fmother_hschool=1 if mother_educ>=4 & mother_educ<=5

replace fmother_hschool=. if foster!=1

tab fmother_hschool

gen min300books=0
replace min300books=1 if booknum>=4 & booknum<=7

gen talks_read=0
replace talks_read=1 if family_talkread>=2 & family_talkread<=4

gen talks_school=0
replace talks_school=1 if family_talkschool>=2 & family_talkschool<=4

gen parent_t_conf=0
replace parent_t_conf=1 if parent_teacher_conf==4

cap drop hh_min7
gen hh_min7=.
replace hh_min7=0 if household_size<=6
replace hh_min7=1 if household_size>=7



eststo clear

foreach x of varlist internet own_desk min300books talks_read talks_school parent_t_conf hh_min7{
	
eststo: reg `x' fmother_hschool, robust

}

esttab, se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) 
esttab using "Results/fmother_educ_pvalues.csv", se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) replace

preserve
drop if missing(foster)
	gcollapse (mean) internet own_desk min300books talks_read talks_school parent_t_conf hh_min7, by(fmother_hschool)
	export excel "Results/fmother_educ_descriptives.xls", firstrow(variables) 	replace

restore

*-------------------------------------------------------------------------------
*Table A7 - child descritives by foster mother educ
*-------------------------------------------------------------------------------

eststo clear



foreach x of varlist $desccontrols{
	
eststo: reg `x' foster_by_educ if foster==1, robust

}

*p values for differences
esttab, se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) 
esttab using "Results/descriptives_pvalues_feduc.csv", se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) replace

*means of the variables
preserve
drop if foster!=1
	gcollapse (mean) $desccontrols, by(foster_by_educ)
	export excel "Results/descriptives_feduc.xls", firstrow(variables) replace

restore

*-------------------------------------------------------------------------------
*Table A8 - heterogeneity by Special needs
*-------------------------------------------------------------------------------
*Heterogeneity by sn

*sni type
global snicontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.num_siblings

cap drop any_sni
gen any_sni=0 if sni==0 | missing(sni)
replace any_sni=1 if sni>=1 & !missing(sni)

eststo clear
foreach x of varlist $outcomes outcome_index{
reg `x' i.foster##i.any_sni $snicontrols , robust
eststo `x'	
}

esttab, keep(1.foster 1.foster#1.any_sni) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab using "Results/regresult_main_sni.tex", keep(1.foster 1.foster#1.any_sni) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_main_sni.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Table A9 - Placebo on chilrden with a positive propesnity of getting into statecare
*-------------------------------------------------------------------------------

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=23
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>23 & !missing(fostermums_100kid_pest)


global countycontrols employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c

global ivcontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.sni i.num_siblings komplex_c  employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c

cap drop statecare
gen statecare=0 if home_type_clean==0
replace statecare=1 if !missing(foster)

probit statecare $controls

cap drop pred_statecare
predict pred_statecare

sum pred_statecare if !missing(foster), detail
global predscmedian=r(p50)
disp "$predscmedian"

eststo clear
foreach x of varlist $outcomes_p {		
reg `x' i.fostermums_rate01_pest $ivcontrols  if county_gr6!=. & county_gr6!=99 & home_type_clean==0 & pred_statecare>=$predscmedian, robust
eststo `x'_iv_pc	
}

esttab , keep(1.fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 

*control means
foreach x of varlist $outcomes_p{
sum `x' if fostermums_rate01_pest==0 & home_type_clean==0 & county_gr6!=. & county_gr6!=99 & pred_statecare>=$predscmedian
}


*-------------------------------------------------------------------------------
*Table A10 - Inference for spec curve anaylsis - in R script
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
*Table A11 - Regression of children living with biological family in garde 6
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata_h6sc8.dta", clear
drop if missing(monthly_age)

*Generate index of outcomes - positive value shows more favorable outcome
*calculate only for popultaion of children in state care
cap drop z_*
foreach x of varlist neet_6m ever_mental_problem ever_pregnant {
cap drop `x'_neg
gen `x'_neg=-`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_neg)
}

foreach x of varlist secondary_finished_19 {
cap drop `x'_fost
gen `x'_fost=`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_fost)
}

cap drop outcome_index
egen outcome_index=rmean(z_*)


eststo clear
foreach x of varlist $outcomes outcome_index{
	
reg `x' i.foster $controls, robust
eststo `x'_olsc	
}

esttab, keep(1.foster) b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_main_ols_h6sc8.tex", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_main_ols_h6sc8.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab, keep(1.foster) se star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*uncontrolled difference for comparison
eststo clear
foreach x of varlist $outcomes outcome_index {
	
reg `x' i.foster, robust
eststo `x'_ols
	
}
esttab using "Results/regresult_main_descdiff_h6sc8.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab


*-------------------------------------------------------------------------------
*Table A12 - Regression of children with missing home type in grade 6
*-------------------------------------------------------------------------------

use "Output_data/CISC_regdata_m6sc8.dta", clear
drop if missing(monthly_age)

eststo clear
foreach x of varlist $outcomes outcome_index{
	
reg `x' i.foster $controls, robust
eststo `x'_olsc	
}

esttab, keep(1.foster) b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_main_ols_m6sc8.tex", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_main_ols_m6sc8.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab, keep(1.foster) se star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*uncontrolled difference for comparison
eststo clear
foreach x of varlist $outcomes outcome_index {
	
reg `x' i.foster, robust
eststo `x'_ols
	
}
esttab using "Results/regresult_main_descdiff_m6sc8.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab


*-------------------------------------------------------------------------------
*Table A13 - LASSO ddml
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata.dta", clear

*create dummy variables
tab m_szint, gen(oster_mszint)
tab o_szint, gen(oster_oszint)
tab grade_math, gen(oster_grade_math)
tab grade_grammar, gen(oster_grade_grammar)
tab grade_lit, gen(oster_grade_lit)
tab grade_behav, gen(oster_grade_behav)
tab grade_effort, gen(oster_grade_effort)
tab age_cat_6_grade, gen(oster_age_cat)
tab year19, gen(oster_year19)
tab county_gr6, gen(oster_county)
tab num_siblings, gen(oster_siblings)


*LASSO
foreach x of varlist $outcomes{
	*set random seed for replication
set seed 422
qddml `x'  foster  (oster_mszint1 oster_mszint2 oster_mszint3 oster_mszint5 oster_mszint6 oster_mszint7 oster_mszint8 oster_mszint9  oster_oszint1 oster_oszint2 oster_oszint3 oster_oszint5 oster_oszint6 oster_oszint7 oster_oszint8 oster_oszint9 oster_grade_math1 oster_grade_math2 oster_grade_math4 oster_grade_math5 oster_grade_math6 oster_grade_grammar1 oster_grade_grammar2 oster_grade_grammar4 oster_grade_grammar5 oster_grade_grammar6 oster_grade_lit1 oster_grade_lit2 oster_grade_lit4 oster_grade_lit5 oster_grade_lit6 oster_grade_behav1 oster_grade_behav2 oster_grade_behav4 oster_grade_behav5 oster_grade_behav6 oster_grade_effort1 oster_grade_effort2 oster_grade_effort4 oster_grade_effort5 oster_grade_effort6 boy oster_age_cat2 oster_age_cat3 oster_age_cat4 oster_year192 oster_year193 oster_year194  oster_year195  oster_year196  oster_year197  oster_year198 oster_year199  oster_year1910 i.sni oster_county2 oster_county3 oster_county4 oster_county5 oster_county6 oster_county7 oster_county8 oster_county9 oster_county10 oster_county11 oster_county12 oster_county13 oster_county14 oster_county15 oster_county16 oster_county17 oster_county18 oster_county18 oster_county19 oster_county20 oster_county21 oster_siblings2 oster_siblings3 oster_siblings4 oster_siblings5 oster_siblings6 oster_siblings7) if !missing(foster), model(partial) cmd(pdslasso) robust
}
foreach x of varlist $outcomes{

pdslasso `x' i.foster ($controls)
*matlist r(table)
disp "Outcome: `x' above"
}


*-------------------------------------------------------------------------------
*Table A14 - estimates for foster care using a more leninet def
*-------------------------------------------------------------------------------

use "Output_data/CISC_regdata.dta", clear


gen foster_lenient=0 if t20==3
replace foster_lenient=1 if t20==2

*Generate index of outcomes - positive value shows more favorable outcome
*calculate only for popultaion of children in state care
cap drop z_*
foreach x of varlist neet_6m ever_mental_problem ever_pregnant {
cap drop `x'_neg
gen `x'_neg=-`x' if !missing(foster_lenient)
cap drop z_`x' 	
egen z_`x' = std(`x'_neg)
}

foreach x of varlist secondary_finished_19 {
cap drop `x'_fost
gen `x'_fost=`x' if !missing(foster_lenient)
cap drop z_`x' 	
egen z_`x' = std(`x'_fost)
}

cap drop outcome_index
egen outcome_index=rmean(z_*)


eststo clear
foreach x of varlist $outcomes outcome_index{
	
reg `x' i.foster_lenient $controls, robust
eststo `x'_olsc	
}

esttab, keep(1.foster_lenient) b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)


*-------------------------------------------------------------------------------
*Table A15 - Confidence intervals
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata.dta", clear

*original
eststo clear
foreach x of varlist $outcomes{
	
reg `x' i.foster $controls , robust
eststo `x'_olsc	
}

esttab, keep(1.foster)   b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*clustered
eststo clear
foreach x of varlist $outcomes{
	
reg `x' i.foster $controls , cluster(county_gr6)
eststo `x'_olsc	
}

esttab, keep(1.foster)   b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

*bootstrap
eststo clear
foreach x of varlist $outcomes{
	
reg `x' i.foster $controls , vce(bootstrap, seed(442))
eststo `x'_olsc	
}

esttab, keep(1.foster)   b(3) se ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)




*-------------------------------------------------------------------------------
*Table B1 - Proxy control ability
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata.dta", clear

cap drop early_schoolstarter
gen early_schoolstarter=1-late_schoolstarter

*calculate index of ability in 6th grade
cap drop z_*
foreach x of varlist snidummy2-snidummy8 {
cap drop `x'_neg
gen `x'_neg=-`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_neg)
}

foreach x of varlist grade*_nomiss m_zpsc o_zpsc  {
cap drop `x'_fost
gen `x'_fost=`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_fost)
}

cap drop abilty_index6
egen ability_index6=rmean(z_*)

pwcorr ability_index6 ${desccontrols} if !missing(foster), sig


*Proxy control
replace early_schoolstarter=. if missing(late_schoolstarter)
eststo clear
eststo: reg ability_index6 i.foster early_schoolstarter
esttab , b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


esttab using "Results/proxycontrol_ability.tex", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Table B2 - OLS estimates for the effect of foster care
*-------------------------------------------------------------------------------


eststo clear
foreach x of varlist $outcomes outcome_index{

reg `x' i.foster ability_index6 i.boy i.county_gr6 i.grade i.num_siblings i.year, robust
eststo `x'

	
}

esttab using "Results/proxycontrol_outcome.tex", keep(1.foster ability_index6) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/proxycontrol_outcome.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace



*-------------------------------------------------------------------------------
*Table C1 - IV first stage
*-------------------------------------------------------------------------------
use "Output_data/CISC_regdata.dta", clear

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=23
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>23 & !missing(fostermums_100kid_pest)

eststo clear

eststo: ivreg2  outcome_index (foster=fostermums_rate01_pest) $ivcontrols if county_gr6!=. & county_gr6!=99, first savefirst savefprefix(s1) liml
estadd scalar cdf1 =  `e(cdf)': s1foster


eststo: ivreg2  ever_pregnant (foster=fostermums_rate01_pest) $ivcontrols if county_gr6!=. & county_gr6!=99, first savefirst savefprefix(s3) liml
estadd scalar cdf1 =  `e(cdf)': s3foster


esttab s1foster s3foster,  keep(fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stats(cdf1 N, labels("CD Wald F" "N"))  


esttab s1foster s3foster  using "Results/reg_iv_first_countyc.csv",  b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stats(cdf1 N, labels("CD Wald F" "N")) replace

*-------------------------------------------------------------------------------
*Table C2 - IV Balance
*-------------------------------------------------------------------------------

gen fmother_voc_educ= fmother_sec_educ
replace fmother_voc_educ=1 if mother_educ==3 & foster==1
eststo clear

global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index

replace fosterfam_quality=. if foster!=1

foreach x of varlist $desccontrols $outcomes fmother_voc_educ fosterfam_quality{
	
eststo: reg `x' fostermums_rate01_pest if !missing(foster), robust

}
esttab using "Results/descriptives_iv_pvalues.csv", se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) replace

eststo clear

foreach x of varlist $desccontrols $outcomes fmother_voc_educ fosterfam_quality{
	
eststo: reg `x' fostermums_rate01_pest $countycontrols if !missing(foster), robust

}

esttab , se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) 
esttab using "Results/descriptives_iv_controlled_pvalues.csv", se  star(+ 0.10 * 0.05 ** 0.01 *** 0.001 ) replace



preserve
drop if missing(foster)
	gcollapse (mean) $desccontrols $outcomes fmother_voc_educ, by(fostermums_rate01_pest)
	export excel "Results/descriptives_iv.xls", firstrow(variables) 	replace

restore


preserve
drop if missing(foster)
	gcollapse (sd) $desccontrols $outcomes fmother_voc_educ, by(fostermums_rate01_pest)
	export excel "Results/descriptives_sd_iv.xls", firstrow(variables) 	replace

restore



*-------------------------------------------------------------------------------
*Table C3 - IV
*-------------------------------------------------------------------------------
cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=23
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>23 & !missing(fostermums_100kid_pest)


eststo clear
foreach x of varlist $outcomes outcome_index {
	
*ivreg2 `x' (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first
disp "`x'" 
disp "*****************************************************************"
ivreg2 `x' (i.foster=i.fostermums_rate01_pest) $ivcontrols if county_gr6!=. & county_gr6!=99, first
eststo `x'_iv	
}

esttab, keep(1.foster _cons) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_iv.tex", keep(1.foster) stat(arfp N cdf) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_iv.csv", keep(1.foster) stat(arfp N cdf) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
