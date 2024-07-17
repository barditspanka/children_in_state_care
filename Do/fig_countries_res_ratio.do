*create figure residential ratio
use "Input_data/unicef_datacare.dta", clear

gen foster_ratio=foster_care_rate/alternative_care_rate*100
lab var foster_ratio "Percent in foster care among children in alternative care"

gen residential_ratio=residential_care_rate/alternative_care_rate*100
lab var residential_ratio "Percent in residential care"


drop if country=="Malta"
drop if country=="Luxemburg"

insobs 1
replace country="USA" if missing(country)
replace residential_ratio=10.56 if country=="USA"
replace alternative_care_rate=0.57*1000 if country=="USA"
replace countrycode="US" if country=="USA"

gen hun=0
replace hun=1 if country=="Hungary"

sort residential_ratio


twoway (scatter residential_ratio alternative_care_rate if hun==0, xtitle("Rate of children in state care" "(per 100000)", size(large)) color("black") mlabel(countrycode) mlabposition(4)  mlabcolor("black") xlabel(0(500)2500, labsize(large)) ylabel(, labsize(large)) ytitle(,size(large))) (scatter residential_ratio alternative_care_rate if hun==1, mlabel(countrycode) mlabposition(6)  mlabcolor("red") legend(off) color("red")) 
graph export "Results/countries_residential_ratio_2019.png", replace
sort residential_ratio
