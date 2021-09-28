********************************************************************************
** 	TITLE:		05_Inquiry_Appdx_TableB3B4
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Appendix Appendix TableB3 - Regression Estimates from IPEDS
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

********************************************************************************
*A1. First Two Columns: Weights and No Weights
********************************************************************************
use "$finaldata/IPEDS_unemp_final.dta", clear	

local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

local outcome "s_ctotalt"	
local wt1 ""
local wt2 "[w=poptot_cty]"
local weight1 "No"
local weight2 "Yes"
local control "poverty_cty medhh_inc_cty poptot_cty"	

foreach var in `outcome' {
	forvalues i=1/2 {
		forvalue j =1/7 {
			preserve
			keep if sample =="`cip`j''"
			dis "`j'"
			xtset countyfips year
			bysort countyfips: gen l_unemp_cty  = l1.unemp_cty
			label var l_unemp_cty "Unemployment Rate at t-1"
			sum `var' if sample == "`cip`j''" 
			local rmean = r(mean)
			reghdfe `var' l_unemp_cty `control' if sample == "`cip`j''" `wt`i'' , absorb(countyfips year) cluster(statefips)
			estimate store `var'_`i'_`j'
			estadd local mean "`rmean'", replace
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			estadd local weight "`weight`i''"
			restore
			}
		}
	}
********************************************************************************
*A2. Export Tables
********************************************************************************	
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
// Table B3
// Export Restults to Tables for Health Care 
esttab s_ctotalt_1_1 s_ctotalt_2_1 ///
	using "$output/IPEDS_HealthCare_1.csv", label replace keep(l_unemp_cty, relax) /// 
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	mlabels("Unweighted" "Weighted") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_2 s_ctotalt_2_2 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) /// 
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Top 4 Professions") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_3 s_ctotalt_2_3 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) /// 
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare Degree < 1yr") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_4 s_ctotalt_2_4 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) ///
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare Degree from for-profit") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
	
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

// Table B4

esttab s_ctotalt_1_5 s_ctotalt_2_5 ///
	using "$output/IPEDS_HealthCare_2.csv", label replace keep(l_unemp_cty, relax) /// 
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Registered, Clinical Nursing, Nursing Admin & Research") ///
	mlabels("Unweighted" "Weighted") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_6 s_ctotalt_2_6 ///
	using "$output/IPEDS_HealthCare_2.csv", label append keep(l_unemp_cty, relax) /// 
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Allied Health and Medical Assisting Services") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_7 s_ctotalt_2_7 ///
	using "$output/IPEDS_HealthCare_2.csv", label append keep(l_unemp_cty, relax) ///
	b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Health and Medical Administrative Services") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

********************************************************************************
*B1. First Two Columns: Weight and No Weight
********************************************************************************


*****************************************************************************
use "$finaldata/IPEDS_unemp_final.dta", clear	

local cip0 "Whole Economy"
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

local control1 "No Controls"
local control2 "Before Recession"
local control3 "After Recession"
local control "poverty_cty medhh_inc_cty poptot_cty"	
local outcome "s_ctotalt"

foreach var in `outcome' {
	forvalues i=1/3 {
		forvalues j=1/7 {
			local wt1 "if sample == "`cip`j''""
			local wt2 "if sample == "`cip`j''" & year <=2009"
			local wt3 "if sample == "`cip`j''" & year >=2010"
			sum `var' `wt`i'' 
			local rmean`i'`j' = r(mean)
			dis `rmean`i'`j''
			}
		}
	}	
foreach var in `outcome' {
	forvalues i=1/3 {
		forvalue j =1/7 {
		local wt1 "if sample  =="`cip`j''"" 
		local wt2 "`control' if sample == "`cip`j''" & year <=2009"
		local wt3 "`control' if sample == "`cip`j''" & year >=2010"
			dis `j'
			preserve
			keep if sample =="`cip`j''"
			xtset countyfips year
			* bysort countyfips: keep if _N==13
			count
			bysort countyfips: gen l_unemp_cty  = l1.unemp_cty
			label var l_unemp_cty "Unemployment Rate at t-1"
			reghdfe `var' l_unemp_cty `wt`i'' [w=poptot_cty2005], absorb(countyfips year) cluster(statefips)
			estimate store `var'_`i'_`j'
			estadd local mean "`rmean`i'`j''"
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			estadd local weight "`weight`i''"
			restore
			}
		}
	}	
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
********************************************************************************
*B2. Export Tables
********************************************************************************
// Table B3
esttab s_ctotalt_1_1 s_ctotalt_2_1 s_ctotalt_3_1 ///
	using "$output/IPEDS_HealthCare_1.csv", label replace keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	mlabels("No Control" "Recession" "Recovery") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_2 s_ctotalt_2_2 s_ctotalt_3_2 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Top 4 Professions") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_3 s_ctotalt_2_3 s_ctotalt_3_3 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare Degree < 1yr") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_4 s_ctotalt_2_4 s_ctotalt_3_4 ///
	using "$output/IPEDS_HealthCare_1.csv", label append keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare Degree from for-profit") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
	
// Table B4 
local cip5 "Registered, Clinical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"
local cip8 "Practical Nursing, Vocational Nursing & Nursing Assistants"


esttab s_ctotalt_1_5 s_ctotalt_2_5 s_ctotalt_3_5 ///
	using "$output/IPEDS_HealthCare_2.csv", label replace keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Registered, Clinical Nursing, Nursing Admin & Research") ///
	mlabels("No Control" "Recession" "Recovery") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_6 s_ctotalt_2_6 s_ctotalt_3_6 ///
	using "$output/IPEDS_HealthCare_2.csv", label append keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Allied Health and Medical Assisting Services") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_ctotalt_1_7 s_ctotalt_2_7 s_ctotalt_3_7 ///
	using "$output/IPEDS_HealthCare_2.csv", label append keep(l_unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Health and Medical Administrative Services") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
********************************************************************************
**********************************THE END***************************************
********************************************************************************

	
