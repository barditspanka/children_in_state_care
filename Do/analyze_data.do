********************************************************************************
*Data analysis for chilrden in state care
*code by Anna Bárdits, 17/07/2024
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
*Table 2 OLS
*-------------------------------------------------------------------------------

use "Output_data/CISC_regdata.dta", clear
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
foreach x of varlist outcome_index {
	
reg `x' i.foster, robust
eststo `x'_ols
	
}
esttab using "Results/regresult_main_descdiff.csv", keep(1.foster _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

esttab

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
*Table 5 - IV first stage
*-------------------------------------------------------------------------------
*prepare data for IV
*high, low fostermum rate, cut at median
cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)


global countycontrols employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c

*first stage

eststo clear

eststo: ivreg2  outcome_index (foster=fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first savefirst savefprefix(s1) liml
estadd scalar cdf1 =  `e(cdf)': s1foster


eststo: ivreg2  ever_pregnant (foster=fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first savefirst savefprefix(s3) liml
estadd scalar cdf1 =  `e(cdf)': s3foster


esttab s1foster s3foster,  keep(fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stats(cdf1 N, labels("CD Wald F" "N"))  


esttab s1foster s3foster  using "Results/reg_iv_first_countyc.csv",  b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) stats(cdf1 N, labels("CD Wald F" "N")) replace

*-------------------------------------------------------------------------------
*Table 6 - Reduced form
*-------------------------------------------------------------------------------

eststo clear
foreach x of varlist $outcomes outcome_index{	
/*reg `x' i.fostermums_rate01_pest $countycontrols if county_gr6!=. & county_gr6!=99 & foster<=1, vce(cluster county_gr6) 
eststo `x'_ivnoc*/	
reg `x' i.fostermums_rate01_pest $countycontrols if county_gr6!=. & county_gr6!=99 & foster<=1, robust
eststo `x'_ivc
	
}



esttab , keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 

esttab using "Results/reg_iv_reduced_countyc.tex", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/reg_iv_reduced_countyc.csv", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace



*-------------------------------------------------------------------------------
*Table 7 - IV
*-------------------------------------------------------------------------------

eststo clear
foreach x of varlist $outcomes outcome_index {
	
*ivreg2 `x' (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first
disp "`x'" 
disp "*****************************************************************"
ivreg2 `x' (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first
eststo `x'_iv	
}

esttab, keep(1.foster _cons) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_iv_countyc.tex", keep(1.foster) stat(arfp N cdf) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_iv_countyc.csv", keep(1.foster) stat(arfp N cdf) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Figure 2 - robustness checks
*-------------------------------------------------------------------------------
do "Do/robustness_checks.do"

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
*Figure A3 - preapred during robustness checks
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
foreach x of varlist $outcomes outcome_index_all{
reg `x' i.home_type_nok $controls, robust
eststo `x'
}

esttab, keep(2.home_type_nok 3.home_type_nok) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

esttab using "Results/regresult_all.tex", keep(2.home_type_nok 3.home_type_nok) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/regresult_all.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace

*-------------------------------------------------------------------------------
*Table A5 - foster mother qaulity
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
*Table A6 - heterogeneity by Special needs
*-------------------------------------------------------------------------------
*Heterogeneity by sni

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
*Table A7 - IV placebo
*-------------------------------------------------------------------------------

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)

global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index_all

eststo clear
foreach x of varlist $outcomes {		
reg `x' i.fostermums_rate01_pest $countycontrols if county_gr6!=. & county_gr6!=99 & home_type_clean==0, robust
eststo `x'_ivc	
}

esttab , keep(1.fostermums_rate01_pest) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) 
esttab using "Results/reg_iv_placebo_countyc.tex", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/reg_iv_placebo_countyc.csv", keep(1.fostermums_rate01_pest _cons) b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace


*-------------------------------------------------------------------------------
*Table A8 - IV Balance
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
*Table A8 - IV Compliers
*-------------------------------------------------------------------------------
*compliers

tab boy if !missing(fostermums_rate01_pest) & !missing(foster)
reg foster fostermums_rate01_pest if boy==1
reg foster fostermums_rate01_pest if boy!=1
reg foster fostermums_rate01_pest if sni==0
reg foster fostermums_rate01_pest if sni!=0
gen sni01=0 if sni==0
replace sni01=1 if sni>=1 & !missing(sni)
sum sni01 if !missing(fostermums_rate01_pest) & !missing(foster)

reg foster fostermums_rate01_pest if grade_behav>=4 & !missing(grade_behav)
reg foster fostermums_rate01_pest  if grade_behav<4
gen grade_behav01=0 if grade_behav<4 & !missing(grade_behav)
replace grade_behav01=1 if grade_behav>=4 & !missing(grade_behav)

sum grade_behav01 if !missing(fostermums_rate01_pest) & !missing(foster)

reg foster fostermums_rate01_pest  if num_siblings>=2 & !missing(num_siblings)
reg foster fostermums_rate01_pest  if num_siblings<2
gen num_siblings01=0 if num_siblings<2 & !missing(num_siblings)
replace num_siblings01=1 if num_siblings>=2 & !missing(num_siblings)
sum num_siblings01 if !missing(fostermums_rate01_pest) & !missing(foster)



*-------------------------------------------------------------------------------
*Table B1 - Proxy control avility
*-------------------------------------------------------------------------------


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

