********************************************************************************
** 	TITLE:		03_Inquiry_figure3
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Figure 3: Impacts for subindustries from IPEDS
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$finaldata/IPEDS_unemp_final.dta"
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

forv i=2/4 {	
	local wt1`i' "if sample =="`cip`i''""
	local wt2`i' "`control' if year!=. & sample =="`cip`i''""
	local wt3`i' "`control' if year<=2009 & sample =="`cip`i''""
	local wt4`i' "`control' if year>=2010 & sample =="`cip`i''""
	}
	
forv j =2/4 {
	preserve 
	keep if sample  =="`cip`j''"
	xtset countyfips year
	bysort countyfips: gen l_unemp_cty  = l1.unemp_cty
	label var l_unemp_cty "Unemployment Rate at t-1"
	foreach var in `outcome' {
		forvalues i=1/4 {
			sum `var' `wt`i'`j'' 
			local rmean = r(mean) // Sample mean 
			reghdfe `var' l_unemp_cty `wt`i'`j'' [w=poptot_cty2005] , absorb(countyfips year) cluster(statefips) // Regressions
			gen ci_low_`var'`i'`j' = _b[l_unemp_cty] - 1.96*_se[l_unemp_cty]
			gen ci_high_`var'`i'`j'= _b[l_unemp_cty] + 1.96*_se[l_unemp_cty]
			gen coef_`var'`i'`j' = _b[l_unemp_cty]
			estimate store `var'_`i'`j'
			estadd local mean "`rmean'"
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			}
		}		
	restore
	}
********************************************************************************
*B. Figures
********************************************************************************	
// Top 4 Professions	
coefplot (s_ctotalt_22 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_32 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_42 , keep(l_unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b)  mlabsize(medlarge) mlabpos(1) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:A. Top 4 Professions}", size(vlarge) position(11) color(sienna)) ///
ytitle("Coef. of Unemployment Rate{bf:{subscript:t-1}}", size(medlarge)) ylabel(,nogrid labsize(small)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) 
graph save IPEDS_temp_Top4.gph, replace

// Less than 1 Year Degree
coefplot (s_ctotalt_23 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_33 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_43 , keep(l_unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b)  mlabsize(medlarge)  mlabpos(1) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:B. Less than 1 Year Degree}", size(vlarge) position(11) color(sienna)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
ytitle("Coef. of Unemployment Rate{bf:{subscript:t-1}}", size(medlarge)) ylabel(,nogrid labsize(small)) 
graph save IPEDS_temp_LT1Y.gph, replace

// For-Profit Institutions
	
coefplot (s_ctotalt_24 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_34 , keep(l_unemp_cty)) /// 
	 (s_ctotalt_44 , keep(l_unemp_cty)) ///
, vertical recast(bar) barwidth(0.1) fcolor(*.5) ///
ciopts(recast(rcap) lwidth(*2 *2 *2)) citop format(%9.3f) ///
addplot(scatter @b @at, ms(i) mlabel(@b)  mlabsize(medlarge) mlabpos(1) mlabcolor(black)) ///
xlabel(none) xtitle("") yline(0, lcolor(red) lpattern(dash)) ///
title("{bf:C. For Profit Institution}", size(vlarge) position(11) color(sienna)) ///
legend(order(1 "All Time Periods" 3 "Recession" 5 "Recovery")  rows(1)) ///
graphregion(margin(vsmall) color(white)) plotregion(lcolor(none) ilcolor(none) style(none)) ///
ytitle("Coef. of Unemployment Rate{bf:{subscript:t-1}}", size(medlarge)) ylabel(,nogrid labsize(small)) 
graph save IPEDS_temp_4Profit.gph, replace

// Graph Combined
grc1leg IPEDS_temp_Top4.gph IPEDS_temp_LT1Y.gph IPEDS_temp_4Profit.gph, row(1) col(3) /// 
graphregion(color(white)) 

// Save Graph	
graph export "$output/Figure3.png", replace width(10000) height(4000)
********************************************************************************
**********************************THE END***************************************
********************************************************************************
