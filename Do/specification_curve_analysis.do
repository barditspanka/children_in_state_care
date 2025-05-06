cd "/homeKRTK/barditsa_prosp/children_in_state_care"

*decision 1 sample. changes home type, broad def, no change, propensity restricted
*https://github.com/dcosme/specification-curves/

*decision 2: outcome measured at age 18, 19, 20

*DONE decision 3: set of controls to include behav, baseline+behav, baseline+behav+cognitive

*DONE deceision 4: model OLS or probit


*secondary_finished_19 


*OLS or probit

*create empty dataset

*secodnary finshed
use "Output_data/CISC_regdata.dta", clear
*TODO sample: propensity score
eststo clear
eststo model_baseline: reg secondary_finished_19 i.foster, robust
esttab model_baseline using "Results/sca_reg_results_secondary_finished.csv", cells(b se p ci_l ci_u) keep(1.foster) stats(N) mtitle(model_baseline) replace

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
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_lpm: reg secondary_finished_`agesamp' i.foster $`coefs' if `subgroup'==1 , robust
				probit secondary_finished_`agesamp' 1.foster $`coefs' if `subgroup'==1 
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_pr: margins, dydx(foster) post
			
				}
			}
	}
}

*todo: store nosni
esttab model* using "Results/sca_reg_results_secondary_finished.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace

*all other outcomes

foreach outcome of varlist ever_mental_problem  ever_abort ever_birth neet_6m {
use "Output_data/CISC_regdata.dta", clear
*TODO sample: propensity score
eststo clear
eststo model_baseline: reg `outcome' i.foster, robust
esttab model_baseline using "Results/sca_reg_results_`outcome'.csv", cells(b se p ci_l ci_u) keep(1.foster) stats(N) mtitle(model_baseline) replace

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
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_lpm: reg `outcome' i.foster $`coefs' if `subgroup'==1 , robust
				probit `outcome' 1.foster $`coefs' if `subgroup'==1 
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_pr: margins, dydx(foster) post
			
				}
			}
	}
}


*todo: store nosni
esttab model* using "Results/sca_reg_results_`outcome'.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace
}


*outcome index
use "Output_data/CISC_regdata.dta", clear

eststo clear
eststo model_baseline: reg secondary_finished_19 i.foster, robust
esttab model_baseline using "Results/sca_reg_results_outcome_index.csv", cells(b se p ci_l ci_u) keep(1.foster) stats(N) mtitle(model_baseline) replace

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
				
				
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o1: reg outcome_index i.foster $`coefs' if `subgroup'==1 , robust
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o2: reg outcome_index2  i.foster $`coefs' if `subgroup'==1 , robust
				eststo model`reg_sample'_`agesamp'_`coefs'_`subgroup'_o3: reg outcome_index3  i.foster $`coefs' if `subgroup'==1 , robust
			
				}
			}
	}
}

*
esttab model* using "Results/sca_reg_results_outcome_index.csv", cells(b se p ci_l ci_u) keep(1.foster) mtitles stats(N) replace



