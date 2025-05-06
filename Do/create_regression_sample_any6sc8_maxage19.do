*Compile sample for robustness checks
*Data analysis for children in state care
use "Output_data/CISC_clean.dta", clear

*If somebody has multiple observations for grade, I use the first (in time)
sort anon t
bysort anon grade: gegen first_obs=min(t)

sort anon t
*Children have to be observed until last montn of maxage
global maxage=19

bysort anon: gegen maxage_month=max(monthly_age)
drop if missing(maxage_month)
drop if maxage_month<${maxage}+0.9
save temp, replace

bysort anon (t): gen num_tranquil=sum(drug_antidep)
bysort anon (t): gen num_antidep=sum(drug_tranquil)

*keep 6th grade observations
preserve 
	keep if grade==6 & first_obs==t
	gen antidep=0
	replace antidep=1 if num_antidep>0 & !missing(num_antidep)

	gen tranquil=0
	replace tranquil=1 if num_tranquil>0 & !missing(num_tranquil)

	keep anon t m_zpsc o_zpsc home_type_clean year grade grade_* m_szint o_szint /*
	*/boy num_siblings age monthly_age mother_educ father_educ telephely_anonim sni county jaras_al tranquil antidep csh_index mother_job father_job roomnumber_hh cellphonenum computernum carnum bathroomnum booknum internet own_books own_desk own_room own_computer family_hwhelp family_talkschool family_talkread family_housework family_gardening household_size mother_age educ_plans age_firstpre6_move sum_district_change late_schoolstarter late_schoolstarter2 /*
*/ parent_teacher_conference household_size fosterfam_quality fosterfam_finquality fosterfam_emoquality

	rename county county_gr6

	rename antidep antidep_gr6
	rename tranquil tranquil_gr6
	rename jaras_al jaras_al_gr6
	*save vars from 6th grade
	sort anon t
	save "Output_data/6th_grade_data_${maxage}.dta", replace
restore
preserve 
	keep if grade==8 & first_obs==t
	
	keep anon t m_zpsc o_zpsc m_szint o_szint home_type_clean 
	
	rename * *8
	rename anon8 anon
	save "Output_data/8th_grade_scores_${maxage}.dta", replace
restore

preserve 
	keep if grade==10 & first_obs==t
	
	keep anon t m_zpsc o_zpsc m_szint o_szint home_type_clean 
	
	rename * *10
	rename anon10 anon
	save "Output_data/10th_grade_scores_${maxage}.dta", replace
restore
	
*use 
use temp, clear
sort anon t


bysort anon (t): gen num_abortions=sum(CS_sex_abort)
bysort anon (t): gen num_birth=sum(CS_sex_deli)

bysort anon (t): gen num_tranquil=sum(drug_antidep)

bysort anon (t): gen num_antidep=sum(drug_tranquil)



*outcomes for age 19
*months spent neet, employed, public works, meanwgae, registered unemployed
bysort anon (t): gen sum_neet${maxage}=sum(neet) if age==$maxage

bysort anon (t): gen sum_unemp${maxage}=sum(unemp) if age==$maxage

bysort anon (t): gen sum_publicw${maxage}=sum(public_works) if age==$maxage

bysort anon (t): gen sum_altalanos=sum(altalanos_t)
bysort anon (t): gen sum_szakma=sum(szakma_t)
bysort anon (t): gen sum_erettsegi=sum(erettsegi_t)

*generate a variable indicating hometype in 8th grade*_nomiss

gen hometype6_s=home_type_clean if grade==6 & first_obs==t
bysort anon: gegen hometype6=max(hometype6_s)

gen hometype8_s=home_type_clean if grade==8 & first_obs==t
bysort anon: gegen hometype8=max(hometype8_s)

gen hometype10_s=home_type_clean if grade==10 & first_obs==t
bysort anon: gegen hometype10=max(hometype10_s)

*keep if hometype missing in 6th
keep if (hometype8==2 | hometype8==3)


keep if age==$maxage & korho==12
keep anon t jaras_al county num_abortions num_birth num_tranquil num_antidep sum_neet${maxage} /*
*/ sum_unemp${maxage} sum_publicw${maxage} sum_altalanos sum_szakma sum_erettsegi hometype8
rename t t${maxage}
rename county county_${maxage}
rename jaras_al jaras_al_${maxage}

*merge 1:1 anon using 
merge 1:1 anon using "Output_data/6th_grade_data_${maxage}.dta", nogen
merge 1:1 anon using "Output_data/8th_grade_scores_${maxage}.dta", nogen
merge 1:1 anon using "Output_data/10th_grade_scores_${maxage}.dta", nogen
sort anon

gen neet_all_year=0
replace neet_all_year=1 if sum_neet${maxage}==12

gen neet_6m=0
replace neet_6m=1 if sum_neet${maxage}>=6 & !missing(sum_neet${maxage})

gen finished_educ_${maxage}=0
*order of running matters here
replace finished_educ_${maxage}=1 if sum_altalanos==1
replace finished_educ_${maxage}=2 if sum_szakma==1
replace finished_educ_${maxage}=3 if sum_erettsegi==1

label define finished_educ_${maxage} 0"less than elementary" 1"elementary" 2"vocational training degree" 3"secondary degree" 
label values finished_educ_${maxage} finished_educ_${maxage}

lab var finished_educ_${maxage} "Highest finished education by age ${maxage}"

gen public_works_1m=0
replace public_works_1m=1 if sum_publicw${maxage}>0 & !missing(sum_publicw${maxage})

gen grouphome=.
replace grouphome=0 if hometype8==2
replace grouphome=1 if hometype8==3

gen fmother_sec_educ=.
replace fmother_sec_educ=0 if mother_educ<=3 & home_type_clean==2
replace fmother_sec_educ=1 if ((mother_educ==4 | mother_educ==5) & home_type_clean==2)

gen foster_by_educ=.
replace foster_by_educ=0 if home_type_clean==3
replace foster_by_educ=1 if fmother_sec_educ==0 
replace foster_by_educ=2 if fmother_sec_educ==1
label define foster_by_educ 0"grouphome" 1"low educ foster" 2"high educ foster"
lab values foster_by_educ foster_by_educ

gen foster_by_educ2=.
replace foster_by_educ2=0 if home_type_clean==3
replace foster_by_educ2=1 if mother_educ<=2 & home_type_clean==2 
replace foster_by_educ2=2 if ((mother_educ==3 | mother_educ==4 | mother_educ==5) & home_type_clean==2)
label define foster_by_educ2 0"grouphome" 1"low educ foster" 2"vocational foster"
lab values foster_by_educ2 foster_by_educ2

gen ever_tranquil=0
replace ever_tranquil=1 if num_tranquil>0 & !missing(num_tranquil)

gen ever_antidep=0
replace ever_antidep=1 if num_antidep>0 & !missing(num_antidep)

*no sni idnication
replace sni=0 if missing(sni)

replace num_siblings=5 if num_siblings>=5 &!missing(num_siblings)
label define num_siblings 5"5 or more"
label values num_siblings num_siblings
foreach x of varlist m_szint o_szint grade_math grade_grammar grade_lit /*
*/grade_behav grade_effort age num_siblings{
replace `x'=99 if missing(`x')
}

gen ever_abort=.
replace ever_abort=0 if boy==0
replace ever_abort=1 if num_abortions>0 & !missing(num_abortions)

gen ever_birth=.
replace ever_birth=0 if boy==0
replace ever_birth=1 if num_birth>0 & !missing(num_birth)

cap drop ever_pregnant
gen ever_pregnant=.
replace ever_pregnant=0 if boy==0
replace ever_pregnant=1 if (ever_birth==1 | ever_abort==1)


gen year${maxage}=floor((t${maxage}-1)/12)+2003


cap drop age_cat_6_grade
gen age_cat_6_grade=.
replace age_cat_6_grade=0 if age<=12
replace age_cat_6_grade=1 if age==13
replace age_cat_6_grade=2 if age==14
replace age_cat_6_grade=3 if age>=15 & !missing(age) & age<99

label define age_cat_6_grade 0"max 12 years" 1"13 years" 2"14 years" 3"min 15 years"
label values age_cat_6_grade age_cat_6_grade

gen elementary_finished_${maxage}=0
replace elementary_finished_${maxage}=1 if finished_educ_${maxage}>=1 & finished_educ_${maxage}<=3

gen secondary_finished_${maxage}=0
replace secondary_finished_${maxage}=1 if finished_educ_${maxage}>=2 & finished_educ_${maxage}<=3
gen high_school_grad_${maxage}=0
replace high_school_grad_${maxage}=1 if finished_educ_${maxage}==3

*lab var secondary_finished_2017 "Obtained vocational or high school degree by the end of 2017"
lab var high_school_grad_${maxage} "Finished elementary school by the end of age ${maxage}"
lab var secondary_finished_${maxage} "Obtained vocational or high school degree by the end of age ${maxage}"
lab var high_school_grad_${maxage} "Obtained vocational or high school degree by the end of age ${maxage}"

cap drop ever_mental_problem
gen ever_mental_problem=0
replace ever_mental_problem=1 if (ever_tranquil==1 | ever_antidep==1)
lab var ever_mental_problem "Ever bought tranquilezers or antidepressants"
*keep only 
keep if !missing(hometype8)
sort anon t
order anon t home_type_clean

cap drop foster       
gen foster=0 if hometype8==3
replace foster=1  if hometype8==2

compress
save "Output_data/CISC_regdata_any6sc8_temp.dta", replace

*add county data

use "Output_data/county_data.dta", clear

*use foster mothers in 2015
gen foster_mother_s=foster_mother if ev==2015
bysort county: gegen foster_mother_2015=max(foster_mother_s)


*number of children in statecare in 2015, KSH
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

*number of foster mothers in county per 100 children in statecare
gen fostermums_100kid=foster_mother_2015/num_statecare*100

*budapest+pest is one entity in this context
gen county_pest=county
replace county_pest=21 if county==1 | county==13
lab var county_pest "bp and pest togehther"

gen foster_mother_2015_pest=foster_mother_2015
replace foster_mother_2015_pest=67+283 if county_pest==21


gen num_statecare_pest=num_statecare
replace num_statecare_pest=2444+2313 if county_pest==21

gen fostermums_100kid_pest= foster_mother_2015_pest/num_statecare_pest*100

rename * *_c

rename county_c county_gr6


rename ev_c year

merge 1:m county_gr6 year using "Output_data/CISC_regdata_any6sc8_temp.dta", nogen keep(using match)

sort anon t



*data preparation for table

*control variables
global controls ib(3).m_szint ib(3).o_szint ib(3).grade_math ib(3).grade_grammar /*
*/ib(3).grade_lit ib(3).grade_behav ib(3).grade_effort  /*
*/i.boy i.age_cat_6_grade i.year${maxage} i.county_gr6 i.sni i.num_siblings


*generate variables for decsriptive tables
foreach x of varlist grade*{
gen `x'_nomiss=`x' if `x'!=99
}

tab sni, gen(snidummy)
gen numsiblings_nomiss=num_siblings if num_siblings!=99


*controls in descriptive table
global desccontrols m_zpsc o_zpsc grade*_nomiss numsiblings_nomiss boy age snidummy* late_schoolstarter


*Generate index of outcomes - positive value shows more favorable outcome
*calculate only for popultaion of children in state care
cap drop z_*
foreach x of varlist neet_6m ever_mental_problem ever_pregnant {
cap drop `x'_neg
gen `x'_neg=-`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_neg)
}

foreach x of varlist secondary_finished_$maxage {
cap drop `x'_fost
gen `x'_fost=`x' if !missing(foster)
cap drop z_`x' 	
egen z_`x' = std(`x'_fost)
}

cap drop outcome_index
egen outcome_index=rmean(z_*)

*Generate index of outcomes - positive value shows more favorable outcome
*calculate for whole population
cap drop z_*
foreach x of varlist neet_6m ever_mental_problem ever_pregnant {
cap drop `x'_neg
gen `x'_neg=-`x'
cap drop z_`x' 	
egen z_`x' = std(`x'_neg)
}

foreach x of varlist secondary_finished_$maxage {
cap drop `x'_fost
gen `x'_fost=`x'
cap drop z_`x' 	
egen z_`x' = std(`x'_fost)
}


cap drop outcome_index_all
egen outcome_index_all=rmean(z_*)

*outcome variables
global outcomes secondary_finished_${maxage} ever_mental_problem  ever_abort ever_birth neet_6m outcome_index


sort anon t
order anon t



compress
save "Output_data/CISC_regdata_any6sc8_${maxage}.dta", replace

rm "Output_data/CISC_regdata_any6sc8_temp.dta"

