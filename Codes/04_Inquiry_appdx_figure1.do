********************************************************************************
** 	TITLE:		04_Inquiry_Appdx_Figure1
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Appendix Figure1: Impacts at State Level
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$finaldata/QCEW_unemp_final.dta"; "$finaldata/IPEDS_unemp_final.dta"
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
*A. QCEW
********************************************************************************

// Extra Regression at the State Level
use "$finaldata/QCEW_unemp_final.dta", clear
local control "poverty_cty medhh_inc_cty poptot_cty"
keep if sample  == "62_woSA_4dig"
egen s_poptot_cty2005 = sum(poptot_cty2005), by(statefips year)	
collapse (mean) unemp_cty s_qtr_emp poverty_cty medhh_inc_cty poptot_cty s_poptot_cty2005 (sum) qtr_emp total_qtr_emp [w=poptot_cty2005], ///
by(statefips year sample) 
rename s_poptot_cty2005 poptot_cty2005
gen s_qtr_emp_st = qtr_emp/total_qtr_emp*100 
local outcome "s_qtr_emp_st"
local control "poverty_cty medhh_inc_cty poptot_cty"
local wt1 "if sample =="62_woSA_4dig""
local wt2 "`control' if year!=. & sample =="62_woSA_4dig""
local wt3 "`control' if year<=2009 & sample =="62_woSA_4dig""
local wt4 "`control' if year>=2010 & sample =="62_woSA_4dig""
foreach var in `outcome' {
	forv i=1/4 {
		reghdfe `var' unemp_cty `wt`i'' [w=poptot_cty2005] , absorb(statefips year) cluster(statefips)
		gen ci_low_`var'`i' = _b[unemp_cty] - 1.96*_se[unemp_cty]
		gen ci_high_`var'`i'= _b[unemp_cty] + 1.96*_se[unemp_cty]
		gen coef_`var'`i' = _b[unemp_cty]
		estimate store `var'_`i'
		estadd local mean "`rmean'"
		estadd local cty_fixed "Yes", replace
		estadd local year_fixed "Yes", replace
		estadd local control "Yes", replace
		}		
	}
// PAnel A	
coefplot (s_qtr_emp_st_2, keep(unemp_cty)) ///
	 (s_qtr_emp_st_3, keep(unemp_cty)) ///
	 (s_qtr_emp_st_4,  keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:Employment}", size(med) position(12) color(sienna)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
ytitle("Coef. of Unemployment Rate", size(medlarge)) ylabel(,nogrid labsize(small))
graph save QCEW_temp_st.gph, replace

********************************************************************************
*B. IPEDS
********************************************************************************
use "$finaldata/IPEDS_unemp_final.dta", clear
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

keep if sample =="`cip1'" // Healthcare sector 

egen s_poptot_cty2005 = sum(poptot_cty2005), by(statefips year)	
collapse (mean) unemp_cty s_ctotalt poverty_cty medhh_inc_cty poptot_cty s_poptot_cty2005 (sum) ctotalt0 ctotalt1 [w=poptot_cty2005], ///
by(statefips year sample)
gen s_ctotalt_st = ctotalt1/ctotalt0 
rename s_poptot_cty2005 poptot_cty2005
	

local control "poverty_cty medhh_inc_cty poptot_cty"
local wt1 "if sample =="`cip1'""
local wt2 "`control' if year!=. & sample =="`cip1'""
local wt3 "`control' if year<=2009 & sample =="`cip1'""
local wt4 "`control' if year>=2010 & sample =="`cip1'""

local control "poverty_cty medhh_inc_cty poptot_cty"	
local outcome "s_ctotalt"

xtset statefips year
bysort statefips: gen l_unemp_cty  = l1.unemp_cty
label var l_unemp_cty "Unemployment Rate at t-1"
foreach var in `outcome' {
	forvalues i=1/4 {
		reghdfe `var' l_unemp_cty `wt`i'' [w=poptot_cty2005] , absorb(statefips year) cluster(statefips)
		gen ci_low_`var'`i' = _b[l_unemp_cty] - 1.96*_se[l_unemp_cty]
		gen ci_high_`var'`i'= _b[l_unemp_cty] + 1.96*_se[l_unemp_cty]
		gen coef_`var'`i' = _b[l_unemp_cty]
		estimate store `var'_`i'
		estadd local mean "`rmean'"
		estadd local cty_fixed "Yes", replace
		estadd local year_fixed "Yes", replace
		estadd local control "Yes", replace
		}
	}		
coefplot (s_ctotalt_2 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_3 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_4 , keep(l_unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(1) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:Number of Graduates}", size(med) position(12) color(sienna)) ///
ytitle("Coef. of Unemployment Rate{bf:{subscript:t-1}}", size(medlarge)) ylabel(,nogrid labsize(small)) 
graph save IPEDS_temp_st.gph, replace
grc1leg QCEW_temp_st.gph IPEDS_temp_st.gph, row(2) graphregion(color(white))

graph export "$output/AppendixFigure1.png", replace height(1000) width(1100)

********************************************************************************
**********************************THE END***************************************
********************************************************************************
