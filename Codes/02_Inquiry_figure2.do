********************************************************************************
** 	TITLE:		02_Inquiry_figure2
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Figure 2: Impacts for subindustries from the QCEW
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$finaldata/QCEW_unemp_final.dta"
**
**	OUTPUTS:	
**			
**	AUTHOR:		Cong Gian
**	
**	CREATED:	9/28/2021
**
**	LAST MODIFIED:  9/28/2021
**
**	STATUS: 	Finished
**
**	NOTES:		
********************************************************************************
*A. Regressions
********************************************************************************
use "$finaldata/QCEW_unemp_final.dta", clear

replace sample ="1" if sample =="62_4dig"
replace sample ="2" if sample =="62_woSA_4dig"
replace sample ="3" if sample =="6231"
replace sample ="4" if sample =="6216"
replace sample ="5" if sample == "6211"
replace sample ="6" if sample == "6221" 

// 4 subindustries: General Hospitals, Nursing Facilities, Home Care Services, and Office of Physicians 
forv i =3/6 {
local wt1`i' " if sample =="`i'""
local wt2`i' "`control' if year!=. & sample =="`i'""
local wt3`i' "`control' if year<=2009 & sample =="`i'"" 
local wt4`i' "`control' if year>=2010 & sample =="`i'"" 
}

local outcome "s_qtr_emp"	
local control "poverty_cty medhh_inc_cty poptot_cty"	

foreach var in `outcome' {
	forvalues i=1/4 {
		forvalues j=3/6 {
			sum `var' `wt`i'`j'' 
			local rmean = r(mean) // sample mean 
			
			reghdfe `var' unemp_cty `wt`i'`j'' [w=poptot_cty2005] , absorb(countyfips year) cluster(statefips) // Regressions
			
			gen ci_low_`var'`i'`j' = _b[unemp_cty] - 1.96*_se[unemp_cty]
			gen ci_high_`var'`i'`j'= _b[unemp_cty] + 1.96*_se[unemp_cty]
			gen coef_`var'`i'`j' = _b[unemp_cty]
			estimate store `var'_`i'`j'
			
			estadd local mean "`rmean'"
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			}
		}
}	
********************************************************************************
*B. Figures
********************************************************************************
local l6211 "Offices of Physicians excl. Mental Health"
local l6221 "General Medical & Surgical Hospitals"
local l6216 "Home Health Care Services"
local l6231 "Nursing Care Facilities"

* Nursing Care Facilities
coefplot (s_qtr_emp_23 , label("With Controls") keep(unemp_cty)) ///
	 (s_qtr_emp_33 , label("Recession") keep(unemp_cty)) ///
	 (s_qtr_emp_43 , label("Recovery") keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:A. Nursing Care Facilities}", size(med) position(11) color(sienna)) ///
ytitle("Coef. of Unemployment Rate", size(medium)) ylabel(,nogrid labsize(small)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) 

graph save QCEW_temp_6231.gph, replace

* Home Health Care Services
coefplot  (s_qtr_emp_24 , label("All Time Periods") keep(unemp_cty)) ///
	 (s_qtr_emp_34 , label("Recession") keep(unemp_cty)) ///
	 (s_qtr_emp_44 , label("Recovery") keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf: B. Home Health Care Services}", size(med) position(11) color(sienna)) ///
ytitle("Coef. of Unemployment Rate", size(medium)) ylabel(,nogrid labsize(small)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) 

graph save QCEW_temp_6216.gph, replace

* Offices of Phys. excl. Mental Health
coefplot  (s_qtr_emp_25 , label("With Controls") keep(unemp_cty)) ///
	 (s_qtr_emp_35 , label("Recession") keep(unemp_cty)) ///
	 (s_qtr_emp_45 , label("Recovery") keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") ylabel(0(0.01)0.07) yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:C. Offices of Phys. excl. Mental Health}", size(med) position(11) color(sienna)) ///
ytitle("Coef. of Unemployment Rate", size(medium)) ylabel(,nogrid labsize(small)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) 

graph save QCEW_temp_6211.gph, replace

* General Med. & Surgical Hospitals
coefplot  (s_qtr_emp_26 , keep(unemp_cty)) ///
	 (s_qtr_emp_36 , keep(unemp_cty)) ///
	 (s_qtr_emp_46 , keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:D. General Med. & Surgical Hospitals}", size(med) position(11) color(sienna)) ///
ytitle("Coef. of Unemployment Rate", size(medlarge)) ylabel(,nogrid labsize(small)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) 

graph save QCEW_temp_6221.gph, replace

* Combined
grc1leg QCEW_temp_6231.gph QCEW_temp_6216.gph QCEW_temp_6211.gph QCEW_temp_6221.gph, row(2) col(2) /// 
graphregion(color(white)) 

* Save graph
graph export "$output/Figure2.png", replace height(1000) width(1100)
********************************************************************************
**********************************THE END***************************************
********************************************************************************


