********************************************************************************
** 	TITLE:		05_Inquiry_Appdx_TablesB1B2
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Generating Appendix Appendix Table1 - Regression Estimates from QCEW
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
*A1. First Two Columns: Weight and No Weight
********************************************************************************
use "$finaldata/QCEW_unemp_final.dta", clear
local Overall_4dig "US"
local l62_4dig "Health Care"
local 62_woSA_4dig "Health Care Except Social Assistance"
local l6211 "Offices of Physicians excl. Mental Health"
local l6221 "General Medical & Surgical Hospitals"
local l6216 "Home Health Care Services"
local l6231 "Nursing Care Facilities"
local naics4 "62_4dig 62_woSA_4dig 6231 6216 6211 6221"
local outcome "qtr_emp ihs_qtr_emp log_qtr_emp"	

replace sample ="1" if sample =="62_4dig"
replace sample ="2" if sample =="62_woSA_4dig"
replace sample ="3" if sample =="6231"
replace sample ="4" if sample =="6216"
replace sample ="5" if sample == "6211"
replace sample ="6" if sample == "6221" 

local outcome "s_qtr_emp"	
local wt1 ""
local wt2 "[w=poptot_cty2005]"
local weight1 "No"
local weight2 "Yes"
replace sample ="1" if sample =="62_4dig"
replace sample ="2" if sample =="62_woSA_4dig"
replace sample ="3" if sample =="6231"
replace sample ="4" if sample =="6216"
replace sample ="5" if sample == "6211"
replace sample ="6" if sample == "6221"
local control "poverty_cty medhh_inc_cty poptot_cty"
foreach var in `outcome' {
	forvalues i=1/2 {
		forvalue j=1/6 {
			dis "`j'"
			sum `var' if sample == "`j'" 
			local rmean = r(mean)
			reghdfe `var' unemp_cty `control' if sample == "`j'" `wt`i'' , absorb(countyfips year) cluster(statefips)
			gen ci_low_`var'`i'`j' = _b[unemp_cty] - 1.96*_se[unemp_cty]
			gen ci_high_`var'`i'`j'= _b[unemp_cty] + 1.96*_se[unemp_cty]
			gen coef_`var'`i'`j' = _b[unemp_cty]
			estimate store `var'_`i'_`j'
			estadd local mean "`rmean'"
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			estadd local weight "`weight`i''"
			}
		}
	}	
********************************************************************************
*A2. Export Tables
******************************************************************************	
local l62_4dig "Health Care and Social Assistant"
local 62_woSA_4dig "Health Care"

// Table B1
esttab s_qtr_emp_1_1 s_qtr_emp_2_1 ///
	using "$output/QCEW_HealthCare1.csv", label replace /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare & Social Assistance") ///
	mlabels("Unweighted" "Weighted") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_2 s_qtr_emp_2_2 ///
	using "$output/QCEW_HealthCare1.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
	
// Table B2
local l6231 "Nursing Care Facilities"
local l6216 "Home Health Care Services"
local l6211 "Offices of Physicians excl. Mental Health"
local l6221 "General Medical & Surgical Hospitals"

esttab s_qtr_emp_1_3 s_qtr_emp_2_3 ///
	using "$output/QCEW_HealthCare2.csv", label replace /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Nursing Care Facilities") ///
	mlabels("Unweighted" "Weighted") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_4 s_qtr_emp_2_4 ///
	using "$output/QCEW_HealthCare2.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Home Health Care Services") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_5 s_qtr_emp_2_5 ///
	using "$output/QCEW_HealthCare2.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Office of Physicians Excl. Mental Health") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_6 s_qtr_emp_2_6 ///
	using "$output/QCEW_HealthCare2.csv", label append ///
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("General Medical & Surgical Hospitals") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
	
********************************************************************************
*B1. Last Three Columns: No Controls, Recession and Recovery
********************************************************************************
use "$finaldata/QCEW_unemp_final.dta", clear
local outcome "s_qtr_emp"	
local control1 "No Controls"
local control2 "Before Recession"
local control3 "After Recession"
replace sample ="1" if sample =="62_4dig"
replace sample ="2" if sample =="62_woSA_4dig"
replace sample ="3" if sample =="6231"
replace sample ="4" if sample =="6216"
replace sample ="5" if sample == "6211"
replace sample ="6" if sample == "6221"
destring sample, force replace
local control "poverty_cty medhh_inc_cty poptot_cty"
foreach var in `outcome' {
	forvalues i=1/3 {
		forvalues j=1/6 {
			local wt1 "if sample  ==`j'" 
			local wt2 "if sample == `j' & year <=2009"
			local wt3 "if sample == `j' & year >=2010"	
			sum `var' `wt`i'' [w=poptot_cty2005]
			local rmean`i'`j' = r(mean)
			dis `rmean`i'`j''
			}
		}
	}	
foreach var in `outcome' {
	forvalues i=1/3 {
		forvalues j=1/6 {
			local wt1 "if sample  ==`j'" 
			local wt2 "`control' if sample == `j' & year <=2009"
			local wt3 "`control' if sample == `j' & year >=2010"		
			dis "`wt`i''"
			dis "`j'"
			reghdfe `var' unemp_cty `wt`i'' [w=poptot_cty2005] , absorb(countyfips year) cluster(statefips)
			gen ci_low_`var'`i'`j' = _b[unemp_cty] - 1.96*_se[unemp_cty]
			gen ci_high_`var'`i'`j'= _b[unemp_cty] + 1.96*_se[unemp_cty]
			gen coef_`var'`i'`j' = _b[unemp_cty]
			estimate store `var'_`i'_`j'
			estadd local mean `rmean`i'`j''
			estadd local cty_fixed "Yes", replace
			estadd local year_fixed "Yes", replace
			estadd local control "Yes", replace
			estadd local weight "`weight`i''"
			}
		}
	}

********************************************************************************
*B2. Export Tables
********************************************************************************
// Table B1
esttab s_qtr_emp_1_1 s_qtr_emp_2_1 s_qtr_emp_3_1 ///
	using "$output/QCEW_HealthCare1_Ext.csv", label replace /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare & Social Assistance") ///
	mlabels("No Control" "Recession" "Recovery") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_2 s_qtr_emp_2_2 s_qtr_emp_3_2 ///
	using "$output/QCEW_HealthCare1_Ext.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

// Table B2	
esttab s_qtr_emp_1_3 s_qtr_emp_2_3 s_qtr_emp_3_3 ///
using "$output/QCEW_HealthCare2_Ext.csv", label replace /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Nursing Care Facilities") ///
	mlabels("No Control" "Recession" "Recovery") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_4 s_qtr_emp_2_4 s_qtr_emp_3_4 ///
using "$output/QCEW_HealthCare2_Ext.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("Home Health Care Services ") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))
		
esttab s_qtr_emp_1_5 s_qtr_emp_2_5 s_qtr_emp_3_5 ///
using "$output/QCEW_HealthCare2_Ext.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))

esttab s_qtr_emp_1_6 s_qtr_emp_2_6 s_qtr_emp_3_6 ///
using "$output/QCEW_HealthCare2_Ext.csv", label append /// 
	keep(unemp_cty, relax) b(3) se(3)  star(* 0.10 ** 0.05 *** 0.01) ///
	coeflabels(unemp_cty "Unemployment Rate") ///
	title("HealthCare") ///
	nonote noobs nogap nomtitle nonumber ///
	stats(mean N, labels("Mean" "Number of Obs") fmt(0 0))	
********************************************************************************
**********************************THE END***************************************
********************************************************************************	
