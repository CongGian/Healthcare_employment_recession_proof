********************************************************************************
** 	TITLE:		01_Inquiry_figure1
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Figure 1
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
**	NOTES:		
********************************************************************************
use "$finaldata/QCEW_unemp_final.dta", clear
********************************************************************************
*A. Sample selections 
********************************************************************************
replace sample ="1" if sample =="62_4dig"
replace sample ="2" if sample =="62_woSA_4dig"
replace sample ="3" if sample =="6231"
replace sample ="4" if sample =="6216"
replace sample ="5" if sample == "6211"
replace sample ="6" if sample == "6221" 

********************************************************************************
*B. County and year fixed effect regressions 
********************************************************************************
// QCEW 
local control "poverty_cty medhh_inc_cty poptot_cty"	


local outcome "s_qtr_emp"	

*(1) ALl periods; (2)Recession ; (3) Recovery

local wt1 "if sample =="2"" // All period with no controls
local wt2 "`control' if year!=. & sample =="2"" // All periods with controls
local wt3 "`control' if year<=2009 & sample =="2"" // Recession with controls
local wt4 "`control' if year>=2010 & sample =="2"" // Recovery with controls
foreach var in `outcome' {
	forvalues i=1/4 {
		sum `var' `wt`i'' 
		local rmean = r(mean) // Sample mean 
		
		reghdfe `var' unemp_cty `wt`i'' [w=poptot_cty2005] , absorb(countyfips year) cluster(statefips) // Regressions
		
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
	
// Panel A from QCEW 
	
coefplot (s_qtr_emp_2, keep(unemp_cty)) ///
	 (s_qtr_emp_3, keep(unemp_cty)) ///
	 (s_qtr_emp_4, keep(unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
ytitle("Coef. of Unemployment Rate", size(medlarge)) ylabel(,nogrid labsize(small)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
title("Employment", color(sienna)) 
graph save QCEW_temp.gph, replace 

*******************************************************************************
// IPEDS

use "$finaldata/IPEDS_unemp_final.dta", replace

local control "poverty_cty medhh_inc_cty poptot_cty"	

local outcome "s_ctotalt"
	
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

keep if sample =="`cip1'" // All health care 
	
local wt1 "if sample =="`cip1'"" //All periods with no controls
local wt2 "`control' if year!=. & sample =="`cip1'"" // All periods with controls
local wt3 "`control' if year<=2009 & sample =="`cip1'"" // Recession with controls
local wt4 "`control' if year>=2010 & sample =="`cip1'"" // Recovery with controls

xtset countyfips year
bysort countyfips: gen l_unemp_cty  = l1.unemp_cty // Lag of unermployment rate
label var l_unemp_cty "Unemployment Rate at t-1"
foreach var in `outcome' {
	forvalues i=1/4 {
		sum `var' `wt`i'' 
		local rmean = r(mean)
	
		reghdfe `var' l_unemp_cty `wt`i'' [w=poptot_cty2005] , absorb(countyfips year) cluster(statefips)
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
	
// Panel B from IPEDS	

coefplot (s_ctotalt_2, keep(l_unemp_cty)) ///
	 (s_ctotalt_3, keep(l_unemp_cty) ) ///
	 (s_ctotalt_4, keep(l_unemp_cty) ) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b) mlabsize(medium) mlabpos(2) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
ytitle("Coef. of Unemployment Rate{bf:{subscript:t-1}}", size(medlarge)) ylabel(,nogrid labsize(small))  ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
title("Number of Graduates", color(sienna)) 
graph save IPEDS_temp.gph, replace

// Combining two graphs

grc1leg QCEW_temp.gph IPEDS_temp.gph, row(2) graphregion(color(white)) 

// Saved as png
graph export "$output/Figure1.png", replace height(1000) width(1100)
********************************************************************************
**********************************THE END***************************************
********************************************************************************
