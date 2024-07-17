*Construct clean dataset for ananlyzing outcomes of people growing up in in state care
*Anna Bárdits
*2021.11.08

*clean NABC data
cd "/homeKRTK/barditsa_prosp/children_in_state_care"
use "/homeProspSSD/Admin3_H2_Kompetencia/admin3_komp_H2_v2.dta", clear


************************************
*clean nabc data


*CLEAN PLACE OF LIVING
***********************************************-
foreach x of varlist t21*{
replace `x'=. if `x'>=3
}

tab t20 t21a, m
*own parents
*kinship care
*foster care
*grouphome
*inconsistent answer
*insufficient info


gen home_type_clean=.
*inetresting cases
cap drop N
gen N=1 if ev>=2008 & ev<=2013 & evfolyam==6
tab N
*own parents
*if states own family with biol parents
gen own_parents=1 if t20==1 & (t21a==1 | t21b==1)
tab N if t20==1 & (t21a==1 | t21b==1)
*if states foster family with biol parents
replace own_parents=1 if t20==2 & (t21a==1 | t21b==1)
tab N if t20==2 & (t21a==1 | t21b==1)
*if no family type with biol parents
replace own_parents=1 if missing(t20) & (t21a==1 | t21b==1)
tab N if missing(t20) & (t21a==1 | t21b==1)
*
tab N if t20==3 & (t21a==1 | t21b==1)

*kisnhip care
gen kinship_care=.
*if states own family with relatives and no biological parents
replace kinship_care=1 if t20==1 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
tab N if t20==1 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
*if states foster family with relatives and no biological parents
replace kinship_care=1 if t20==2 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
tab N if t20==2 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
*if no family type with relatives and no biological parents
replace kinship_care=1 if missing(t20) & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
tab N if missing(t20) & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)


*foster care
gen foster_care=.
replace foster_care=1 if t20==2 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)
tab N if t20==2 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*grouphome
gen grouphome=.
replace grouphome=1 if t20==3 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)
*tab N if t20==3 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*missing incosnistent
gen miss_inconsistent=.
*tab N if (t21a==1|t21b==1) & t20==3
replace miss_inconsistent=1 if (t21a==1|t21b==1) & t20==3

*tab N if t20==3 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)
replace miss_inconsistent=1 if t20==3 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1) & (t21e==1 | t21f==1 | t21i==1)

*tab N if t20==1 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_inconsistent=1 if t20==1 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*tab N if t20==3 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_inconsistent=1 if t20==3 & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*missing insufficient
gen miss_insufficient=.
*tab N if missing(t20) & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_insufficient=1 if missing(t20) & t21c==1 & (t21a!=1 & t21b!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*tab N if t20==1 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_insufficient=1 if t20==1 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*tab N if t20==2 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_insufficient=1 if t20==2 & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)

*tab N if missing(t20) & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)
replace miss_insufficient=1 if missing(t20) & (t21a!=1 & t21b!=1 & t21c!=1 & t21d!=1 & t21e!=1 & t21f!=1 & t21i!=1)


replace home_type_clean=0 if own_parents==1
replace home_type_clean=1 if kinship_care==1
replace home_type_clean=2 if foster_care==1
replace home_type_clean=3 if grouphome==1
replace home_type_clean=8 if miss_inconsistent==1
replace home_type_clean=9 if miss_insufficient==1
*
replace home_type_clean=8 if missing(home_type_clean)
tab home_type_clean if N==1, m

rename home_type_clean home_type_clean_m
gen home_type_clean=home_type_clean_m
replace home_type_clean=. if home_type_clean>=8
tab home_type_clean if N==1, m

*missings

label define home_type_clean 0"own family with parents" 1"kisnship care" 2"foster family" 3"group home"
label values home_type_clean home_type_clean


********************************************************************************
*Clean and generate variables with English names
********************************************************************************


*get clean english parental education
gen mother_educ=t28
replace mother_educ=3 if mother_educ==4
replace mother_educ=4 if mother_educ==5
replace mother_educ=5 if mother_educ==6 | mother_educ==7

gen father_educ=t29
replace father_educ=3 if father_educ==4
replace father_educ=4 if father_educ==5
replace father_educ=5 if father_educ==6 | father_educ==7

gen highest_parent_educ=max(mother_educ, father_educ)
lab var mother_educ "Highest education of mother or foster mother"
lab var father_educ "Highest education of father or foster father"
lab var highest_parent_educ "Education of parent with the higher educational attainment"
label define english_educ 1"less than elementary" 2"elementary" 3"vocational" 4"secondary" 5"college" 
label values mother_educ english_educ
label values father_educ english_educ
label values highest_parent_educ english_educ

gen girl=sex
gen grade=evfolyam

gen grade_last_year=t14
lab var grade_last_year "Average grade from last year"

gen grade_math=t15a
lab var grade_math "Mathametics grade middle of this year"
gen grade_grammar=t15b
lab var grade_grammar "Grammar grade middle of this year"
gen grade_lit=t15c
lab var grade_lit "Literature grade middle of this year"
gen grade_behav=t15d
lab var grade_behav "Behaviour grade middle of this year"
gen grade_effort=t15e
lab var grade_effort "Effort grade middle of this year"


gen educ_plans=t17
label define educ_plans 1"elementary" 2"vocational training" 3"secondary" 4"technician ?" 5"uni BA" 6"uni MA" 7"phd"

*clean number of siblings
gen num_siblings=t23
lab var num_siblings "Number of siblings (regardless of living location of siblings)"

gen num_siblings_home=t24
lab var num_siblings_home "Number of siblings living in the same place"


*foster family features
gen household_size=t22
replace household_size=13 if household_size>=13 & !missing(household_size)
label define household_size 13"13 or larger"
label values household_size household_size
label var household_size "Number of people in household"

gen mother_age=t32
gen father_age=t33

rename t30a mother_job
rename t30b father_job

rename t34_b roomnumber_hh

rename t35a cellphonenum
rename t35b computernum
rename t35c carnum
rename t35d bathroomnum
rename t36 booknum
rename t37 internet
rename t38a own_books
rename t38b own_desk
rename t38c own_room
rename t38d own_computer

rename t40a family_hwhelp
rename t40b family_talkschool
rename t40c family_talkread
rename t40d family_housework
rename t40e family_gardening

*teacher parnet conference
rename t41 parent_teacher_conference

*has foster father -misisng 0 as well
gen has_foster_father=0
replace has_foster_father=1 if t21d==1
replace has_foster_father=0 if t21d==0
replace has_foster_father=1 if !missing(father_educ) & home_type_clean==2

*gen
gen person_per_room=household_size/roomnumber_hh

tab person_per_room if home_type_clean==2
* calculate foster parent quality 

cap drop mother_educ4
gen mother_educ4=1 if mother_educ==. | mother_educ==1 | mother_educ==2
replace mother_educ4=2 if mother_educ==3
replace mother_educ4=3 if mother_educ==4
replace mother_educ4=4 if mother_educ==5

cap drop father_educ4
gen father_educ4=1 if father_educ==. | father_educ==1 | father_educ==2
replace father_educ4=2 if father_educ==3
replace father_educ4=3 if father_educ==4
replace father_educ4=4 if father_educ==5


label define english_educ4 1"max elementary or missing"  2"vocational" 3"secondary" 4"college" 
label values mother_educ4 english_educ4 
label values father_educ4 english_educ4 

*foster family quality
gen car_pca=0
replace car_pca=1 if carnum>=2 & carnum<=4

gen computer_pca=0
replace computer_pca=1 if computernum>=2 & computernum<=4

gen cellphone_pca=0
replace cellphone_pca=1 if cellphonenum>=2 & cellphonenum<=4

gen booknum_pca=booknum
replace booknum_pca=1 if missing(booknum)

gen bathroomnum_pca=bathroomnum
replace bathroomnum_pca=1 if missing(bathroomnum)

gen internet_pca=internet
replace internet_pca=0 if missing(internet)

gen parent_teacher_conference_pca=parent_teacher_conference
replace parent_teacher_conference_pca=1 if missing(parent_teacher_conference)

gen own_books_pca=own_books
replace own_books_pca=0 if missing(own_books)

gen own_desk_pca=own_desk
replace own_desk_pca=0 if missing(own_desk)

gen family_talkschool_pca=family_talkschool
replace family_talkschool_pca=1 if family_talkschool==0 | family_talkschool==.

gen family_talkread_pca=family_talkread
replace family_talkread_pca=1 if family_talkread==0 | family_talkread==.

gen family_hwhelp_pca=family_hwhelp
replace family_hwhelp_pca=1 if family_hwhelp==0 | family_hwhelp==.

global fosterqualvars mother_educ4 father_educ4 /*
*/ family_talkschool_pca  own_desk_pca own_books_pca internet_pca booknum_pca bathroomnum_pca car_pca /*
*/ computer_pca cellphone_pca parent_teacher_conference_pca household_size person_per_room

*misstable patterns $fosterqualvars if home_type_clean==2 & grade==6 & ev<=2012

pwcorr mother_educ4 father_educ4 has_foster_father /*
*/ family_talkschool_pca family_talkread_pca family_hwhelp own_desk_pca own_books_pca internet_pca booknum_pca bathroomnum_pca car_pca /*
*/ computer_pca cellphone_pca parent_teacher_conference_pca household_size person_per_room if  home_type_clean==2 

pca mother_educ4 father_educ4 has_foster_father /*
*/ family_talkschool_pca family_talkread_pca family_hwhelp own_desk_pca own_books_pca internet_pca booknum_pca bathroomnum_pca car_pca /*
*/ computer_pca cellphone_pca parent_teacher_conference_pca household_size person_per_room if  home_type_clean==2 , components(3)

/*
screeplot
graph export "Results/pca_screeplot.png", replace
*/
cap drop fosterfam_quality
predict fosterfam_quality, score

*pwcorr fosterfam_quality $fosterqualvars

pca mother_educ4 father_educ4 own_desk_pca own_books_pca internet_pca booknum_pca bathroomnum_pca car_pca /*
*/ computer_pca cellphone_pca household_size person_per_room if  home_type_clean==2 , components(3)

/*
screeplot
graph export "Results/pca_screeplot_finqual.png", replace
*/

cap drop fosterfam_finquality
predict fosterfam_finquality, score



pca family_talkschool_pca family_talkread_pca family_hwhelp parent_teacher_conference_pca  if  home_type_clean==2 , components(3)

/*
screeplot
graph export "Results/pca_screeplot_emqual.png", replace
*/
cap drop fosterfam_emoquality
predict fosterfam_emoquality, score

pwcorr fosterfam_quality  fosterfam_finquality fosterfam_emoquality

*merge special needs
merge 1:1 anon t using "Input_data/anons_with_sni.dta"
replace sni=0 if missing(sni) & _merge==3
drop _merge

label define sni_eng 0"no special need" 1"severe mental disbility" 2"mild mental disability" 3"autism" 4"phisical disability" 5"speech impairment" 6"pscychological problems" 7"behavior or learning disability"

label values sni sni_eng

rename t4 first_grade_age
rename t3 years_in_kindergarden
rename t5a grade_rep_primary
rename t1_ev birth_year
rename t1_ho birth_month

keep anon t sex grade *educ home_type_clean m_zpsc o_zpsc m_szint o_szint/*
*/ csh_index grade_last_year educ_plans telephely_anonim omkod_anonim /*
*/grade_math grade_grammar grade_lit grade_behav grade_effort /*
*/ num_siblings num_siblings_home sni first_grade_age years_in_kindergarden grade_rep_primary/*
*/ household_size mother_age father_age mother_job father_job /*
*/ roomnumber_hh cellphonenum computernum carnum bathroomnum booknum /*
*/ internet own_books own_computer own_desk own_room /*
*/ family* has_foster_father parent_teacher_conference fosterfam_quality fosterfam_finquality fosterfam_emoquality birth_year birth_month

save "Output_data/NABC_clean.dta", replace

use "Output_data/NABC_clean.dta", clear

*merge admin for outcomes
merge 1:1 anon t using "/homeProspSSD/Admin3/admin3_alap.dta" 

bysort anon: gegen maxmerge=max(_merge)
keep if maxmerge==3

sort anon t
xtset anon t

cap drop emp
gen emp=0
replace emp=1 if fogvisz1~=.


gen w_no0=w
replace w_no0=. if w==0

gen w_with0=w
replace w_with0=0 if w==.

gen w_no0_adj=w_no0/40*wh1

gen in_school=0
replace in_school=1 if !missing(oh_jar)

gen neet=1
replace neet=0 if in_school==1 | emp==1

*clean with child transfers?
gen unemp=0
replace unemp=1 if regist15==1 | regist15==2
replace unemp=0 if emp==1

*clean age
bysort anon kor: gen korho=_n
gen monthly_age=kor+((korho-1)/12)
rename kor age

bysort anon: gegen maxage=max(age)
*
keep if maxage<=30


*birthmonth
gen birthmonth_s=ho if floor(monthly_age)==monthly_age
bysort anon: gegen birthmonth=max(birthmonth_s)
drop birthmonth_s

*genarate indicator of starting late
gen late_schoolstarter=.
replace late_schoolstarter=1 if first_grade_age>=7 & !missing(first_grade_age) & (birthmonth==9 | birthmonth==10 | birthmonth==11 | birthmonth==12 | birthmonth==1 | birthmonth==2)
replace late_schoolstarter=1 if first_grade_age>=8 & !missing(first_grade_age) 
replace late_schoolstarter=0 if first_grade_age==7 & (birthmonth>=3 & birthmonth<=8)
replace late_schoolstarter=0 if first_grade_age<7

*new variable for school strating age Timi
gen late_schoolstarter2=.
replace late_schoolstarter2=1 if first_grade_age>=7 & !missing(first_grade_age) & (birthmonth==9 | birthmonth==10 | birthmonth==11 | birthmonth==12 | birthmonth==1 | birthmonth==2 | birthmonth==3  | birthmonth==4 | birthmonth==5)
replace late_schoolstarter2=1 if first_grade_age>=8 & !missing(first_grade_age) 
replace late_schoolstarter2=0 if first_grade_age==7 & (birthmonth>=6 & birthmonth<=8)
replace late_schoolstarter2=0 if first_grade_age<7



*add health data
drop _merge
*merge abortion and delivery data
merge 1:1 anon t using "Input_data/ABBA_subsample_v5.dta", keep(master match)


sort anon t

*use CS_sex_abort2 instead of CS_sex_abort
drop CS_sex_abort
rename CS_sex_abort2 CS_sex_abort

replace CS_sex_abort=1 if CS_sex_abort==2
replace CS_sex_abort=0 if missing(CS_sex_abort) & ev>2008

*if abortion in two consequtive months, one is set to zero

gen future_abort=0
bysort anon: replace future_abort = 1 if CS_sex_abort[_n+1]+CS_sex_abort[_n]==2
replace CS_sex_abort=0 if future_abort==1
drop future_abort

************VAR****************************************************
*Incidence of delivery
*******************************************************************


replace CS_sex_deli=1 if CS_sex_deli==2
replace CS_sex_deli=0 if missing(CS_sex_deli) & ev>2008


gen future_deli=0

forvalues i=1(1)7{
bysort anon: replace future_deli = 1 if CS_sex_deli[_n+`i']+CS_sex_deli[_n]==2
}

*if delivery in past 7 months, only the latest counts
replace CS_sex_deli=0 if future_deli==1
drop future_deli

replace CS_sex_infect=1 if CS_sex_infect==2

replace CS_sex_abort=0 if missing(CS_sex_abort)
replace CS_sex_deli=0 if missing(CS_sex_deli)
replace CS_sex_infect=0 if missing(CS_sex_infect)

drop _merge

gen boy_s=1-sex
drop sex
bysort anon: gegen boy=max(boy_s)
drop boy_s

bysort anon: gegen ferfi_s=max(ferfi)

replace boy=ferfi_s if missing(boy)
drop if ferfi_s!=boy


rename ev year

save temp, replace

*merge prescription drugs
use anon t N05_ft N06_ft using "/homeProspSSD/Admin3_H2_NEAK_veny/admin3_eu_veny_H2_v2.dta" if (!missing(N05_ft) | !missing(N06_ft))
merge 1:1 anon t using temp, keep(using match) nogen

gen drug_tranquil=0
replace drug_tranquil=1 if N05_ft>=0 & !missing(N05_ft)
lab var drug_tranquil "Buying any prescription psycholeptic (including tranquilizers) in given month"
gen drug_antidep=0
replace drug_antidep=1 if N06_ft>=0 & !missing(N06_ft)
lab var drug_antidep "Buying any prescription psychoanaleptic (including) in given month"

order anon t
sort anon t

bysort anon: gegen max_home=max(home_type_clean)
gen home_change_s=1 if max_home!=home_type_clean & !missing(home_type)

bysort anon: gegen home_change=max(home_change_s)
drop home_change_s
lab var home_change "1 if student changes home type at least once (missings are not changes)"


rename kozmunkas public_works
lab var public_works "Works in the public works program"
compress

save temp, replace

*merge education data

use "/homeProspSSD/Admin3/admin3_iskvegz.dta", clear

*calculate t of finishing 

merge 1:m anon using temp, gen(merge2) keep(using match)

cap drop finished_educ_2017
gen finished_educ_2017=0 if iskvegz==1 
replace finished_educ_2017=1 if iskvegz>=2 & iskvegz<=4
replace finished_educ_2017=2 if iskvegz==5
replace finished_educ_2017=3 if iskvegz==6
replace finished_educ_2017=4 if iskvegz==7
label define finished_educ_2017 0"less than elementary" 1"elementary" 2"vocational training degree" 3"secondary degree" 4"college" 



label values finished_educ_2017 finished_educ_2017
sort anon t
gen erettsegi_t=0
replace erettsegi_t=1 if t==12*(floor(erettsegi_ev/100)-2003)+(erettsegi_ev-100*floor(erettsegi_ev/100))

gen szakma_t=0
replace szakma_t=1 if t==12*(floor(szakma1_ev/100)-2003)+(szakma1_ev-100*floor(szakma1_ev/100))

gen altalanos_t=0
replace altalanos_t=1 if t==12*(floor(altalanos_ev/100)-2003)+(altalanos_ev-100*floor(altalanos_ev/100))



*add county
gen megye = .
label val megye megye
label var megye "Megyekod"

* 1 - Budapest
replace megye = 1 if jaras_al <= 23
label def megye 1 "Budapest"

* 2 - Baranya
replace megye = 2 if jaras_al >= 24 & jaras_al <= 33 
label def megye 2 "Baranya", add

* 3 - Bcs-Kiskun
replace megye = 3 if jaras_al >=34 & jaras_al <= 44
label def megye 3 "Bacs-Kiskun", add

* 4 - Bks
replace megye = 4 if jaras_al >= 45 & jaras_al <= 53
label def megye 4 "Bekes", add

* 5 - Borsod-Abaj-Zempln 
replace megye = 5 if jaras_al >= 54 & jaras_al <= 69
label def megye 5 "Borsod-Abaj-Zemplen", add

* 6 - Csongrd
replace megye = 6 if jaras_al >=70 & jaras_al <= 76
label def megye 6 "Csongrad", add

* 7 - Fejr
replace megye = 7 if jaras_al >=77 & jaras_al <=85
label def megye 7 "Fejer", add

* 8 - Gyr-Moson-Sopron
replace megye = 8 if jaras_al >= 86 & jaras_al <= 92
label def megye 8 "Gyor-Moson-Sopron", add

* 9 - Hajd-Bihar
replace megye = 9 if jaras_al >= 93 & jaras_al <= 102
label def megye 9 "Hajdu-Bihar", add

* 10 - Heves
replace megye = 10 if jaras_al >= 103 & jaras_al <= 109
label def megye 10 "Heves", add

* 11 - Komrom-Esztergom
replace megye = 11 if jaras_al >= 110 & jaras_al <= 115
label def megye 11 "Komarom-Esztergom", add

* 12 - Ngrd
replace megye = 12 if jaras_al >=116 & jaras_al <= 121
label def megye 12 "Nograd", add

* 13 - Pest
replace megye = 13 if jaras_al >=122 & jaras_al<=139
label def megye 13 "Pest", add

* 14 - Somogy
replace megye = 14 if jaras_al >=140 & jaras_al <= 147
label def megye 14 "Somogy", add

* 15 - Szabolcs-Szatmr-Bereg
replace megye = 15 if jaras_al >= 148 & jaras_al <= 160
label def megye 15 "Szabolcs-Szatmar-Bereg", add

* 16 - Jsz-Nagykun-Szolnok
replace megye = 16 if jaras_al >= 161 & jaras_al <= 169
label def megye 16 "Jasz-Nagykun-Szolnok", add

* 17 - Tolna
replace megye = 17 if jaras_al >= 170 & jaras_al <= 175
label def megye 17 "Tolna", add

* 18 - Vas
replace megye = 18 if jaras_al >= 176 & jaras_al <= 182
label def megye 18 "Vas", add

* 19 - Veszprm
replace megye = 19 if jaras_al >= 183 & jaras_al <= 192
label def megye 19 "Veszprem", add

* 20 - Zala 
replace megye = 20 if jaras_al >= 193 & jaras_al <= 198
label def megye 20 "Zala", add

* 99 - Nem ismert
replace megye = 99 if jaras_al == 999
label def megye 99 "Nem ismert", add

replace megye = 99 if missing(megye)

rename megye county


cap drop change_district
sort anon t
bysort anon: gen change_district=1 if jaras_al!=jaras_al[_n-1]

replace change_district=0 if t==1

*number of district changes before 6 grade
cap drop sum_district_change
sort anon t
bysort anon: gen sum_district_change=sum(change_district)


order anon t change_district sum_district_change jaras_al


gen cdistrict_by6_s=sum_district_change if grade==6

bysort anon: gegen cdistrict_by6 = max(cdistrict_by6_s)


gen tgrade6_s=t if grade==6
bysort anon: gegen t_grade6=min(tgrade6_s)
gen age_firstpre6_move_s=kor if t<=t_grade6 & change_district==1

bysort anon: gegen age_firstpre6_move=min(age_firstpre6_move_s)
bysort anon: gegen last_firstpre6_move=max(age_firstpre6_move_s)

compress
sort anon t
order anon t home_type_clean year age

save "Output_data/CISC_clean.dta", replace

********************************************************************************
*create county and district level databases by year
********************************************************************************
*0. district, county, number of women 18-64, number of men 18-64, wage, employment, unemployment
use anon t ev ho ferfi jaras fogvisz1 w kor regist15 using "/homeProspSSD/Admin3/admin3_alap.dta", clear

*if kor>=18 & kor<=64 & ho==5
*1. by district, number of foster mothers
gen megye = .
label val megye megye
label var megye "Megyekod"

* 1 - Budapest
replace megye = 1 if jaras_al <= 23
label def megye 1 "Budapest"

* 2 - Baranya
replace megye = 2 if jaras_al >= 24 & jaras_al <= 33 
label def megye 2 "Baranya", add

* 3 - Bcs-Kiskun
replace megye = 3 if jaras_al >=34 & jaras_al <= 44
label def megye 3 "Bacs-Kiskun", add

* 4 - Bks
replace megye = 4 if jaras_al >= 45 & jaras_al <= 53
label def megye 4 "Bekes", add

* 5 - Borsod-Abaj-Zempln 
replace megye = 5 if jaras_al >= 54 & jaras_al <= 69
label def megye 5 "Borsod-Abaj-Zemplen", add

* 6 - Csongrd
replace megye = 6 if jaras_al >=70 & jaras_al <= 76
label def megye 6 "Csongrad", add

* 7 - Fejr
replace megye = 7 if jaras_al >=77 & jaras_al <=85
label def megye 7 "Fejer", add

* 8 - Gyr-Moson-Sopron
replace megye = 8 if jaras_al >= 86 & jaras_al <= 92
label def megye 8 "Gyor-Moson-Sopron", add

* 9 - Hajd-Bihar
replace megye = 9 if jaras_al >= 93 & jaras_al <= 102
label def megye 9 "Hajdu-Bihar", add

* 10 - Heves
replace megye = 10 if jaras_al >= 103 & jaras_al <= 109
label def megye 10 "Heves", add

* 11 - Komrom-Esztergom
replace megye = 11 if jaras_al >= 110 & jaras_al <= 115
label def megye 11 "Komarom-Esztergom", add

* 12 - Ngrd
replace megye = 12 if jaras_al >=116 & jaras_al <= 121
label def megye 12 "Nograd", add

* 13 - Pest
replace megye = 13 if jaras_al >=122 & jaras_al<=139
label def megye 13 "Pest", add

* 14 - Somogy
replace megye = 14 if jaras_al >=140 & jaras_al <= 147
label def megye 14 "Somogy", add

* 15 - Szabolcs-Szatmr-Bereg
replace megye = 15 if jaras_al >= 148 & jaras_al <= 160
label def megye 15 "Szabolcs-Szatmar-Bereg", add

* 16 - Jsz-Nagykun-Szolnok
replace megye = 16 if jaras_al >= 161 & jaras_al <= 169
label def megye 16 "Jasz-Nagykun-Szolnok", add

* 17 - Tolna
replace megye = 17 if jaras_al >= 170 & jaras_al <= 175
label def megye 17 "Tolna", add

* 18 - Vas
replace megye = 18 if jaras_al >= 176 & jaras_al <= 182
label def megye 18 "Vas", add

* 19 - Veszprm
replace megye = 19 if jaras_al >= 183 & jaras_al <= 192
label def megye 19 "Veszprem", add

* 20 - Zala 
replace megye = 20 if jaras_al >= 193 & jaras_al <= 198
label def megye 20 "Zala", add

* 99 - Nem ismert
replace megye = 99 if jaras_al == 999
label def megye 99 "Nem ismert", add

replace megye = 99 if missing(megye)

rename megye county

*missing is 0
gen wage_with_0=0
replace wage_with_0=w if w>0 & !missing(w)
lab var wage_with_0 "Wage from all sources, 0 if no wage"

*0 is missing (wage of only those who work)
gen wage_no_0=.
replace wage_no_0=. if w==0 
replace wage_no_0=w if w>0 & !missing(w)
lab var wage_no_0 "Wage from all sources, missing if no wage"

*
gen employed=0 if missing(fogvisz1)
replace employed=1 if fogvisz1>=0 & !missing(fogvisz1)

*unemployed
gen unemployed=0
replace unemployed=1 if regist15==1
*lezáratlan?

*merge complex score of district development
rename jaras_al jaras_kod
merge m:1 jaras_kod using "/homeKRTK/egeszseg_tarsadalom/2012_rehab_reform/jaras_komplex.dta", keep(master match)
drop _merge
rename jaras_kod jaras_al


*merge foster ratio
merge 1:1 anon t using "/homeProspSSD/Admin3/admin3_feor.dta", keep(master match)
drop _merge


gen foster_mother=1 if (feor1_2003_4==3314 | feor1_2008_4==3512 | feor2_2003_4==3314 | feor2_2008_4==3512) & ferfi==0

gen foster_father=1 if (feor1_2003_4==3314 | feor1_2008_4==3512 | feor2_2003_4==3314 | feor2_2008_4==3512) & ferfi==1


*merge births and abortions
merge 1:1 anon t using "Input_data/ABBA_subsample_v5.dta", keep(master match)
drop _merge

sort anon t

*use CS_sex_abort2 instead of CS_sex_abort
drop CS_sex_abort
rename CS_sex_abort2 CS_sex_abort

replace CS_sex_abort=1 if CS_sex_abort==2
replace CS_sex_abort=0 if missing(CS_sex_abort) & ev>2008

*ha van olyan hónap, amikor 1 hónappal elõtte is volt abortusz, akkor a korábbi idõpont az nem abortusz, 0-ra állítom
gen future_abort=0
bysort anon: replace future_abort = 1 if CS_sex_abort[_n+1]+CS_sex_abort[_n]==2
replace CS_sex_abort=0 if future_abort==1
drop future_abort

*births
replace CS_sex_deli=1 if CS_sex_deli==2
replace CS_sex_deli=0 if missing(CS_sex_deli) & ev>2008


gen future_deli=0

forvalues i=1(1)7{
bysort anon: replace future_deli = 1 if CS_sex_deli[_n+`i']+CS_sex_deli[_n]==2
}

*ha van olyan hónap, amikor 1-7 hónappal elõtte is volt delivery, akkor a korábbi idõpont az nem delivery, 0-ra állítom
replace CS_sex_deli=0 if future_deli==1
drop future_deli

replace CS_sex_abort=0 if missing(CS_sex_abort)
replace CS_sex_deli=0 if missing(CS_sex_deli)

save temp, replace

*merge prescription drugs
use anon t N05_ft N06_ft using "/homeProspSSD/Admin3_H2_NEAK_veny/admin3_eu_veny_H2_v2.dta" if (!missing(N05_ft) | !missing(N06_ft)), clear
merge 1:1 anon t using temp, keep(using match) nogen

sort anon t
gen drug_tranquil=0
replace drug_tranquil=1 if N05_ft>=0 & !missing(N05_ft)
lab var drug_tranquil "Buying any prescription psycholeptic (including tranquilizers) in given month"
gen drug_antidep=0
replace drug_antidep=1 if N06_ft>=0 & !missing(N06_ft)
lab var drug_antidep "Buying any prescription psychoanaleptic (including) in given month"


gen teen_birth=0
replace teen_birth=1 if kor<=19 & kor>=11 & CS_sex_deli==1

gen teen_abort=0
replace teen_abort=1 if kor<=19 & kor>=11 & CS_sex_abort==1

gen age18_64=1 if kor>=18 & kor<=64
gen age18_64_women=1 if kor>=18 & kor<=64 & ferfi==0
gen fertile_women=1 if kor>=15 & kor<=49 & ferfi==0

gen teenage_girls=1 if kor<=19 & kor>=11 & ferfi==0






*keep May as a representative month
keep if ho==5



*labor market only for working age pop
replace wage_no_0=. if kor<=17 | kor>=65
replace wage_with_0=. if kor<=17 | kor>=65
replace employed=. if kor<=17 | kor>=65
replace unemployed=. if kor<=17 | kor>=65

gen N=1

save temp, replace

collapse (max) county komplex (sum) N ferfi unemployed employed foster_mother foster_father CS_sex_abort CS_sex_deli teen_birth teen_abort teenage_girls age18_64 age18_64_women fertile_women drug_tranquil drug_antidep (mean) mean_wageno0=wage_no_0 mean_wagewith0=wage_with_0 (median) med_wageno0=wage_no_0 med_wagewith0=wage_with_0, by(jaras_al ev)


gen foster_mother_rate=foster_mother/age18_64_women
lab var foster_mother_rate "Number of foster mothers per women aged 18-64"

gen teen_birth_rate=teen_birth/teenage_girls
lab var teen_birth_rate "Number of (monthly) teenage births per girls aged 11-19"

gen birth_rate=CS_sex_deli/fertile_women
lab var teen_birth_rate "Number of (monthly) births per fertile women popultaion"

gen teen_abort_rate=teen_abort/teenage_girls
lab var teen_abort_rate "Number of (monthly) teenage abortions per girls aged 11-19"

gen abort_rate=CS_sex_abort/fertile_women
lab var abort_rate "Number of (monthly) abortions per fertile women popultaion"

gen employment=employed/age18_64
lab var employment "Number employed per all aged 18-64"

gen unemployment=unemployed/age18_64
lab var unemployment "Number unemployed per all aged 18-64"

gen antidep_rate=drug_antidep/N
lab var antidep_rate "Number buying antidepressants (rep month) per all popultaion"

gen tranq_rate=drug_tranquil/N
lab var tranq_rate "Number buying tranquillizers (rep month) per all popultaion"

save temp2, replace
*merge foster ratio
use "Output_data/CISC_clean.dta", clear
keep if grade==6
keep if !missing(home_type_clean)
tab home_type_clean, gen(home_type_d)
gen N=1

collapse (sum) home_type_d* N, by(jaras_al)
gen state_care_rate=(home_type_d3+home_type_d4)/N
gen foster_care_rate=(home_type_d3)/(home_type_d3+home_type_d4)



merge 1:m jaras_al using temp2, nogen
sort jaras_al ev
compress
save "Output_data/district_data.dta", replace

*COUNTY LEVEL
use temp, clear

collapse (sum) N ferfi unemployed employed foster_mother foster_father CS_sex_abort CS_sex_deli teen_birth teen_abort teenage_girls age18_64 age18_64_women fertile_women drug_tranquil drug_antidep (mean) komplex mean_wageno0=wage_no_0 mean_wagewith0=wage_with_0, by(county ev)

lab var komplex "Mean of komplex district development indicator weighted by population of district"

gen foster_mother_rate=foster_mother/age18_64_women
lab var foster_mother_rate "Number of foster mothers per women aged 18-64"

gen teen_birth_rate=teen_birth/teenage_girls
lab var teen_birth_rate "Number of (monthly) teenage births per girls aged 11-19"

gen birth_rate=CS_sex_deli/fertile_women
lab var teen_birth_rate "Number of (monthly) births per fertile women popultaion"

gen teen_abort_rate=teen_abort/teenage_girls
lab var teen_abort_rate "Number of (monthly) teenage abortions per girls aged 11-19"

gen abort_rate=CS_sex_abort/fertile_women
lab var abort_rate "Number of (monthly) abortions per fertile women popultaion"

gen employment=employed/age18_64
lab var employment "Number employed per all aged 18-64"

gen unemployment=unemployed/age18_64
lab var unemployment "Number unemployed per all aged 18-64"

gen antidep_rate=drug_antidep/N
lab var antidep_rate "Number buying antidepressants (rep month) per all popultaion"

gen tranq_rate=drug_tranquil/N
lab var tranq_rate "Number buying tranquillizers (rep month) per all popultaion"

save temp2, replace
*merge foster ratio
use "Output_data/CISC_clean.dta", clear
keep if grade==6
keep if !missing(home_type_clean)
tab home_type_clean, gen(home_type_d)
gen N=1

collapse (sum) home_type_d* N, by(county)
gen state_care_rate=(home_type_d3+home_type_d4)/N
gen foster_care_rate=(home_type_d3)/(home_type_d3+home_type_d4)


merge 1:m county using temp2, nogen
sort county ev

compress

*for 2008 use 2009 for birth and unemployment
sort county ev
xtset county ev
replace unemployment=unemployment[_n+1] if ev==2008
replace birth_rate=birth_rate[_n+1] if ev==2008
replace abort_rate=abort_rate[_n+1] if ev==2008

save temp, replace
*add taxdata

use "Input_data/taxdata_2008_2017.dta", clear
rename county_code county
rename year ev
save temp2, replace

use temp, clear
merge 1:1 county ev using temp2
drop county_name _merge
order county ev 
sort county ev

compress
save "Output_data/county_data.dta", replace

