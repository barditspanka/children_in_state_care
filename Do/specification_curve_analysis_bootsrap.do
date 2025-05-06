cd "/homeKRTK/barditsa_prosp/children_in_state_care"

*bootstrap
*outcome index
use "Output_data/CISC_regdata.dta", clear

eststo clear

foreach reg_sample in "" "_just6" {

	foreach agesamp in  "18" "19" "20" {
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'.dta", clear
	disp "Output_data/CISC_regdata`reg_sample'_`agesamp'.dta"
		global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
		
		
			*calculate outcome index
			cap drop outcome_index
			cap drop z_*
			foreach x of varlist neet_6m ever_mental_problem ever_pregnant{
			cap drop `x'_neg
			gen `x'_neg=-`x' if !missing(foster)
			cap drop z_`x' 	
			egen z_`x' = std(`x'_neg)
			}

			foreach x of varlist secondary_finished_`agesamp' {
			cap drop `x'_fost
			gen `x'_fost=`x' if !missing(foster)
			cap drop z_`x' 	
			egen z_`x' = std(`x'_fost)
			}

			egen outcome_index=rmean(z_*)
			*calculate outcome index2
			cap drop z_*
			foreach x of varlist neet_6m ever_mental_problem {
			cap drop `x'_neg
			gen `x'_neg=-`x' if !missing(foster)
			cap drop z_`x' 	
			egen z_`x' = std(`x'_neg)
			}

			foreach x of varlist secondary_finished_`agesamp' {
			cap drop `x'_fost
			gen `x'_fost=`x' if !missing(foster)
			cap drop z_`x' 	
			egen z_`x' = std(`x'_fost)
			}

			egen outcome_index2=rmean(z_*)
			pca secondary_finished_`agesamp' ever_mental_problem neet_6m if !missing(foster)
			predict outcome_index3 if !missing(foster)
			replace outcome_index3 = -outcome_index3 
			
			gen fs=1
			gen sn=1 if sni==0
			*overlap sample
			probit foster $c2
			predict prob_foster if !missing(foster)
			sum prob_foster if foster==0, detail
			global p90_rc=r(p90)
			global p10_rc=r(p10)
			sum prob_foster if foster==1, detail
			global p90_f=r(p90)
			global p10_f=r(p10)
			gen ol=1 if prob_foster>=max(${p10_f}, ${p10_f}) & prob_foster<=min(${p90_f}, ${p90_f})
		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
				*generate 0 results
				cap drop outcome_index`subgroup'_0_`coefs' 
				reg outcome_index i.foster $`coefs' if `subgroup'==1 , robust
				gen outcome_index`subgroup'_0_`coefs'=outcome_index-_b[1.foster]*foster
				
				cap drop outcome_index2`subgroup'_0_`coefs' 
				reg outcome_index2 i.foster $`coefs' if `subgroup'==1 , robust
				gen outcome_index2`subgroup'_0_`coefs'=outcome_index2-_b[1.foster]*foster
				
				cap drop outcome_index3`subgroup'_0_`coefs' 
				reg outcome_index3 i.foster $`coefs' if `subgroup'==1 , robust
				gen outcome_index3`subgroup'_0_`coefs'=outcome_index2-_b[1.foster]*foster
				
				save "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", replace
			
				}
			}
	}
}


*estimate original specification on bootrapped
eststo clear
*repeat for 500 bootsrap samples
set seed 7876


forvalues i=1(1)500{
foreach reg_sample in "" "_just6" {
	foreach agesamp in  "18" "19" "20" {
		global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", clear
		keep if !missing(foster)
		
		bsample

		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
		eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o1: reg outcome_index`subgroup'_0_`coefs'  i.foster $`coefs' if `subgroup'==1 , robust
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o2: reg outcome_index2`subgroup'_0_`coefs'   i.foster $`coefs' if `subgroup'==1 , robust
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o3: reg outcome_index3`subgroup'_0_`coefs'   i.foster $`coefs' if `subgroup'==1 , robust
			
			
				}
			}
	}
}

*todo: store nosni
esttab model* using "Results/sca_reg_results_outcome_index_0_`i'.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace
}


************************************************************

*secodnary finshed
use "Output_data/CISC_regdata.dta", clear
*store predicted value of y under the null for every model
eststo clear

foreach reg_sample in "" "_just6" {

	foreach agesamp in  "18" "19" "20" {
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'.dta", clear
		global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
		
		
		gen fs=1
			gen sn=1 if sni==0
			*overlap sample
			probit foster $c2
			predict prob_foster if !missing(foster)
			sum prob_foster if foster==0, detail
			global p90_rc=r(p90)
			global p10_rc=r(p10)
			sum prob_foster if foster==1, detail
			global p90_f=r(p90)
			global p10_f=r(p10)
			gen ol=1 if prob_foster>=max(${p10_f}, ${p10_f}) & prob_foster<=min(${p90_f}, ${p90_f})
		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
				cap drop secondary_finished_`agesamp'`subgroup'_0r_`coefs' 
				reg secondary_finished_`agesamp' i.foster $`coefs' if `subgroup'==1 , robust
				gen secondary_finished_`agesamp'`subgroup'_0r_`coefs'=secondary_finished_`agesamp'-_b[1.foster]*foster
				* probit
				cap drop secondary_finished_`agesamp'`subgroup'_0p_`coefs' 
				cap drop xb_full
				cap drop xb_no_foster
				cap drop ystar_null
				cap probit secondary_finished_`agesamp' i.foster $`coefs' if `subgroup'==1 
				cap predict xb_full, xb
				cap gen xb_no_foster = xb_full - _b[1.foster]*foster
				set seed 422
				cap gen ystar_null = xb_no_foster + rnormal()

				* make it binary
				cap gen secondary_finished_`agesamp'`subgroup'_0p_`coefs' = (ystar_null > 0)
				
				save "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", replace
			
				}
			}
	}
}



*estimate a regression on the 0 data
*secodnary finshed
use "Output_data/CISC_regdata_19_0.dta", clear
*TODO sample: propensity score
eststo clear
*repeat for 500 bootsrap samples

set seed 7876
forvalues i=1(1)500{

foreach reg_sample in "" "_just6" {
	foreach agesamp in  "18" "19" "20" {
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", clear
		keep if !missing(foster)
		bsample
		global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
		
		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_lpm: reg secondary_finished_`agesamp'`subgroup'_0r_`coefs' i.foster $`coefs' if `subgroup'==1 , robust
				cap probit secondary_finished_`agesamp'`subgroup'_0p_`coefs'  1.foster $`coefs' if `subgroup'==1 
				cap eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_pr: margins, dydx(foster) post
			
				}
			}
	}
}

*todo: store nosni
esttab model* using "Results/sca_reg_results_secondary_finished_0_`i'.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace
}


use "Output_data/CISC_regdata.dta", clear
*store predicted value of y under the null for every model
eststo clear

*write every null outcome to null datatsets
foreach reg_sample in "" "_just6" {

	foreach agesamp in  "18" "19" "20" {
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'.dta", clear
	
	global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
		
		
		gen fs=1
			gen sn=1 if sni==0
			*overlap sample
			probit foster $c2
			predict prob_foster if !missing(foster)
			sum prob_foster if foster==0, detail
			global p90_rc=r(p90)
			global p10_rc=r(p10)
			sum prob_foster if foster==1, detail
			global p90_f=r(p90)
			global p10_f=r(p10)
			gen ol=1 if prob_foster>=max(${p10_f}, ${p10_f}) & prob_foster<=min(${p90_f}, ${p90_f})
	
	foreach outcome of varlist ever_mental_problem  ever_abort ever_birth neet_6m {
		
		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
				cap drop `outcome'_`subgroup'_0r_`coefs' 
				reg `outcome' i.foster $`coefs' if `subgroup'==1 , robust
				gen `outcome'_`subgroup'_0r_`coefs'=`outcome'-_b[1.foster]*foster
				* probit
				cap drop `outcome'_`subgroup'_0p_`coefs' 
				cap drop xb_full
				cap drop xb_no_foster
				cap drop ystar_null
				cap probit `outcome' i.foster $`coefs' if `subgroup'==1 
				cap predict xb_full, xb
				cap gen xb_no_foster = xb_full - _b[1.foster]*foster
				set seed 422
				cap gen ystar_null = xb_no_foster + rnormal()

				* make it binary
				cap gen `outcome'_`subgroup'_0p_`coefs' = (ystar_null > 0)
				
				save "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", replace
			
				}
			}
	}
}
}

*
*TODO: DO THIS TO ALL OTHERS
*

*estimate a regression on the 0 data
*secodnary finshed
use "Output_data/CISC_regdata_19_0.dta", clear
*TODO sample: propensity score
eststo clear
*repeat for 500 bootsrap samples
set seed 7876

forvalues i=1(1)500{
	
foreach outcome of varlist ever_mental_problem  ever_abort ever_birth neet_6m{
foreach reg_sample in "" "_just6" {
	foreach agesamp in  "18" "19" "20" {
		global c1 ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
		*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c2 ib(3).grade_behav ib(3).grade_effort  /*
		*/i.boy i.age_cat_6_grade i.year`agesamp' i.county_gr6 i.sni i.num_siblings

		global c3 ib(3).grade_behav ib(3).grade_effort  /*
		*/ i.age_cat_6_grade i.sni
	use "Output_data/CISC_regdata`reg_sample'_`agesamp'_0.dta", clear
		keep if !missing(foster)
		
		bsample

		
		foreach subgroup in fs sn ol{
			foreach coefs in "c1" "c2" "c3"{
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_lpm: reg `outcome'_`subgroup'_0r_`coefs' i.foster $`coefs' if `subgroup'==1 , robust
				cap probit `outcome'_`subgroup'_0p_`coefs'  1.foster $`coefs' if `subgroup'==1 
				cap eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_pr: margins, dydx(foster) post
			
				}
			}
	}
}

*
esttab model* using "Results/sca_reg_results_`outcome'_0_`i'.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace
}
}





