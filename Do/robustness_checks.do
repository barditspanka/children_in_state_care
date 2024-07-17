*Store main result to graph

use "Output_data/CISC_regdata.dta", clear
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

*outcome variables
global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index


*control variables
global controls ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.sni i.num_siblings



cap drop outcome_index
egen outcome_index=rmean(z_*)


reg outcome_index i.foster $controls, robust
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, main) replace

global countycontrols employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)

ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivmain, iv, 1) append

eststo clear
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first
eststo iv_outcome

esttab, keep(1.foster) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)

ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, cluster(county_gr6)
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivcluster, iv, 1) append

eststo clear
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, cluster(county_gr6) first
eststo iv_outcome

esttab, keep(1.foster) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)


ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) if county_gr6!=. & county_gr6!=99
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivnocontrol, iv, 1) append

eststo clear
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest)  if county_gr6!=. & county_gr6!=99, first
eststo iv_outcome

esttab, keep(1.foster) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)




global ivcontrols ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.sni i.num_siblings employment_c unemployment_c komplex_c birth_rate_c mean_wageno0_c 

ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $ivcontrols if county_gr6!=. & county_gr6!=99
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivallcontrol, iv, 1) append

eststo clear
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $ivcontrols if county_gr6!=. & county_gr6!=99, first
eststo ivoutcome
esttab, keep(1.foster) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)


****************************************************************************
eststo clear
cap drop propscore
logit foster $controls
predict propscore

esttab using "Results/logit_ol.tex", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace
esttab using "Results/logit_ol.csv", b(3) se(3) ar2(3) star(+ 0.10 * 0.05 ** 0.01 *** 0.001) replace



twoway hist propscore if foster==1, width(0.05) start(0) color(red%50) freq || hist propscore if foster==0, width(0.05) start(0) color(eltblue%50) freq xtitle("Pr(Foster Care | X)", size(large)) ytitle(,size(large)) xlabel(,labsize(large)) ylabel(,labsize(large)) ///   
       legend(order(1 "Foster Care" 2 "Residential Care" ) size(large))
 graph export "Results/overlap.png", replace


cap drop overlap
gen overlap=0
replace overlap=1 if propscore<=0.9 & propscore>=0.3

*overlap satisfied
reg outcome_index i.foster $controls if overlap==1, robust
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, overlap) append

*late schoolstart added
reg outcome_index i.foster $controls late_schoolstarter, robust
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, earlyab) append

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)

/*
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99 & overlap==1
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivoverlap, iv, 1) append
*/
****************************************************************************
*just6
************************************************************************
*need the code which creates this
use "Output_data/CISC_regdata_robust.dta", clear
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

*outcome variables
global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index


*control variables
global controls ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.sni i.num_siblings



cap drop outcome_index
egen outcome_index=rmean(z_*)

*init dataset to store results

reg outcome_index i.foster $controls, robust
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, just6) append

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)

ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivjust6, iv, 1) append

eststo clear
ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99, first
eststo ivoucme

esttab, keep(1.foster) b(3) se(3)  scalars(arfp N cdf) star(+ 0.10 * 0.05 ** 0.01 *** 0.001)



*need the code which creates this
use "Output_data/CISC_regdata_h6sc8.dta", clear
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


reg outcome_index i.foster $controls, robust
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, h6sc8) append

cap drop fostermums_rate01_pest
gen fostermums_rate01_pest=0 if fostermums_100kid_pest<=24
replace fostermums_rate01_pest=1 if fostermums_100kid_pest>24 & !missing(fostermums_100kid_pest)

ivreg2 outcome_index (i.foster=i.fostermums_rate01_pest) $countycontrols if county_gr6!=. & county_gr6!=99
regsave 1.foster using "Results/robust_regs.dta", ci level (95) addlabel(spec, ivh6sc8, iv, 1) append



*make graph
*OLS

use "Results/robust_regs.dta", clear
keep if missing(iv)
*sort
gen sorter=0-_n
sort sorter
mkmat coef ci_lower ci_upper, matrix(ols)



global label r1="Main specification" r2="Overlap" r3="Early ability included as control" r4="Just 6th grade home type" r5="Own family in 6th grade" 
coefplot (matrix(ols[,1]),  ci((ols[,2] ols[,3])) msize(large) msymbol(O)  mcolor(red) ciopts(lcolor(red)) ), coeflabels( ${label} ) xline(0, lpattern(.) lcolor(red) lwidth(0.5)) xtitle("Effect of family foster care" "with 95% CI", size(large) ) xscale(range(-0.05 0.45)) xlabel(#10, labsize(large)) ylabel(, labsize(large))
graph export "Results/robust_ols.png", replace

use "Results/robust_regs.dta", clear
keep if iv==1
drop if spec=="ivoverlap"
drop if spec=="ivh6sc8"
*sort
gen sorter=0-_n
sort sorter
mkmat coef ci_lower ci_upper, matrix(iv)


global label r1="Main specification" r2="Clustered errors" r3="No controls" r4="Individual controls" r5="Just 6th grade home type"

coefplot (matrix(iv[,1]),  ci((iv[,2] iv[,3])) msize(large) msymbol(O)  mcolor(red) ciopts(lcolor(red)) ), coeflabels( ${label} ) xline(0, lpattern(.) lcolor(red) lwidth(0.5)) xtitle("Effect of family foster care" "with 95% CI", size(large) ) xscale(range(-0.05 0.45)) xlabel(#10, labsize(large)) ylabel(, labsize(large))
graph export "Results/robust_iv.png", replace 



