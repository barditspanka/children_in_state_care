*fig foster share in HUngary

************************************************************************
*Appendix Figure A1
************************************************************************
use "Input_data/residential_ratio_hun.dta" ,clear
keep if year<=2020
gen foster_share=fosterfam_num/(residential_num+fosterfam_num)

gen upper=0.7
twoway bar upper y if inrange(y, 2008, 2010), bcolor(gs14) base(0.5) || connected foster_share year, xtitle(Year, size(large)) ytitle(Share in foster care, size(large)) ylabel(, labsize(large)) xlabel(, labsize(large)) legend(off) color(red)



graph export "Results\foster_share_by_year_hun.png", replace
