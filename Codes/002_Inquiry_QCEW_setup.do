********************************************************************************
** 	TITLE:		002_Inquiry_QCEW_setup.do
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Data set up for the QCEW
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$QCEWrawdata/QCEW_2005_2017.dta"
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
*A. References 
********************************************************************************
* http://proximityone.com/eee.htm
* http://scholar.harvard.edu/files/chodorow-reich/files/qcew-naics-sector-data-county.txt
* https://data.bls.gov/cew/doc/titles/ownership/ownership_titles.htm

********************************************************************************
*B. Import Raw data for Health Care and the Economy at 4 digit 
********************************************************************************
// Healthcare
use "$rawdataQCEW/QCEW_2005_2017.dta", clear // After appending QCEW raw data in these years
gen indcode2 = substr(industry_code,1,2)
preserve 
keep if inrange(indcode2, "62", "62") & inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_62_4dig.dta", replace
restore 

// US Economy
preserve 
keep if  inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_Overall_4dig.dta", replace
restore 

// Health Care Except Social Assitance
preserve 
use "$finaldata/QCEW_62_4dig.dta", clear
keep if inrange(indcode2, "62", "62") & (industry_code!= "6241" & industry_code!= "6242" & industry_code!= "6243" & industry_code~= "6244" )  /// 
& inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_62_woSA_4dig.dta", replace
restore

// Office of physicians 
preserve 
use "$finaldata/QCEW_62_4dig.dta", clear
keep if inrange(indcode2, "62", "62") & (industry_code== "6211" )  /// 
& inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_6211.dta", replace
restore

// Home Health Service
preserve 
use "$finaldata/QCEW_62_4dig.dta", clear
keep if inrange(indcode2, "62", "62") & (industry_code== "6216" )  /// 
& inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_6216.dta", replace
restore

// General Medical and Surgical Hospitals
preserve 
use "$finaldata/QCEW_62_4dig.dta", clear
keep if inrange(indcode2, "62", "62") & (industry_code== "6221" )  /// 
& inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_6221.dta", replace
restore

// Nursing Facilities
preserve 
use "$finaldata/QCEW_62_4dig.dta", clear
keep if inrange(indcode2, "62", "62") & (industry_code== "6231" )  /// 
& inrange(agglvl_code,76,76) & year>= 2005 & ///
size_code ==0 
save "$finaldata/QCEW_6231.dta", replace
restore

********************************************************************************
*C. Employment and Ownership 
********************************************************************************
local naics4 "62_4dig Overall_4dig 62_woSA_4dig 6231 6216 6211 6221"
	foreach naics in `naics4' {
	use "$finaldata/QCEW_`naics'.dta", clear
	
	qui gen quarterly = yq(year,qtr)
	qui format quarterly %tq
	keep if qtr ==4 
	rename month3_emplvl qtr_emp // Only taking december
	
	// Private Sector Only
	keep if own_code ==5
	
	// Collapsing at quarter county level
	bysort year area_fips qtr industry_code: assert _N==1
	collapse (sum) qtr_emp qtrly_estabs (mean) total_qtrly_wages avg_wkly_wage, by(year area_fips)
	bysort year area_fips : assert _N==1
	gen statefips = substr(area_fips,1,2)
	destring statefips, force replace
	gen countyfips = area_fips
	destring countyfips, force replace
	
	label var qtr_emp "Quartely Employment"
	label var qtrly_estabs "Quarterly # of Estabs"
	label var total_qtrly_wages "Quarterly Wages"
	label var avg_wkly_wage "Weekly Wages"	
	gen str indcode_str = "`naics'"
	
	bysort year countyfips statefips: assert _N==1 // Check level of data set
	save "$finaldata/QCEW_`naics'", replace
	}
********************************************************************************
*D. SEER Working Population data
********************************************************************************
use "$rawdata/seer_pop_9017_county_workingpop.dta", clear // Working Population Data 
gen area_fips = state_fips*10^3 + county
keep area_fip year pop
rename area_fips countyfips
rename pop workpop_cty
********************************************************************************
*E. Merge with Macro Variables (Poverty, Median Household Income and Unemployment Rates)
********************************************************************************
merge m:1 countyfips year using "$rawdata/macro2005_2018.dta"	// Macro Data of Unemployment Rate, Poverty and Median Household Income	
qui gen poptot_cty2005= poptot_cty if year==2005 
qui bysort countyfips (poptot_cty2005): replace poptot_cty2005=poptot_cty2005[1]
label var unemp_cty "County-level Unemployment Rate"
label var poptot_cty2005 "County Population in 2005"
keep if _merge ==3 
drop _merge 
save temp.dta, replace

********************************************************************************
*F. Share of Health Care Workers, and Merge with MAcro Data Sets
********************************************************************************
local l62_4dig "Health Care"
local Overall_4dig "US"
local 62_woSA_4dig "Health Care Except Social Assistance"
local l6211 "Offices of Physicians excl. Mental Health"
local l6221 "General Medical & Surgical Hospitals"
local l6216 "Home Health Care Services"
local l6231 "Nursing Care Facilities"

local naics4 "62_4dig 62_woSA_4dig 6231 6216 6211 6221"

	foreach naics in `naics4' {
	use "$finaldata/QCEW_`naics'.dta", clear
	gen sample = "`naics'" 
	append using "$finaldata/QCEW_Overall_4dig.dta"
	replace sample ="Overall" if missing(sample)
	bysort year countyfips statefips sample: assert _N==1
	preserve
	collapse (mean) qtr_emp if sample =="`naics'", by(year countyfips statefips) 
	save "$finaldata/QCEW_cty_`naics'.dta", replace
	restore
	collapse (mean) qtr_emp , by(sample year countyfips statefips) 
	replace sample ="1" if sample == "`naics'" 
	replace sample ="2" if sample == "Overall"
	destring sample, force replace
	keep qtr_emp sample year countyfips statefips
	reshape wide qtr_emp, i(year countyfips statefips) j(sample)
	
	gen s_qtr_emp = qtr_emp1/qtr_emp2*100 // Share of Health Care in Overall
	merge 1:1 year countyfips statefips using "$finaldata/QCEW_cty_`naics'.dta"
	keep if _merge ==3
	drop _merge 
	gen sample = "`naics'" 
	
	merge m:1 countyfips year using temp.dta
	keep if _merge ==3
	drop _merge 	
	save "$finaldata/QCEW_cty_`naics'.dta", replace
	}

********************************************************************************
*G. Final Data Set 
********************************************************************************
local naics4 "62_4dig 62_woSA_4dig 6231 6216 6211 6221"

use "$finaldata/QCEW_cty_62_4dig.dta", clear
foreach naics in `naics4' { 
	append using "$finaldata/QCEW_cty_`naics'.dta"
}

// Labeling variables
label var statefips "State FIPS"
label var countyfips "County FIPS"
label var qtr_emp "Employment in December"
label var sample "Healthcare sector"
label var workpop_cty "Working population count"
label var unemp_cty "Unemployment rate"
label var state_abbrev "State abbreviation"
rename state_name county_name 
label var county_name "County name"
label var poverty_cty "Poverty rate"
label var medhh_inc_cty "Median household income"
label var poptot_cty "Population count"
label var poptot_cty2005 "Population count baseline in 2005"
rename qtr_emp2 total_qtr_emp
label var total_qtr_emp "Total employment in December"
label var s_qtr_emp "Share of health care employment in total employment (%)"
drop qtr_emp1
save "$finaldata/QCEW_unemp_final.dta", replace // Final Data set

********************************************************************************
*h. Erase Data  
********************************************************************************
local naics4 "62_4dig 62_woSA_4dig 6231 6216 6211 6221"

	foreach naics in `naics4' {
		capture erase "$finaldata/QCEW_cty_`naics'.dta"
		capture erase "$finaldata/QCEW_`naics'"
	}
capture erase "$finaldata/QCEW_62_4dig.dta"
capture erase  "$finaldata/QCEW_Overall_4dig.dta"
capture erase "$finaldata/QCEW_6211.dta"
capture erase "$finaldata/QCEW_6216.dta"
capture erase "$finaldata/QCEW_6221.dta"
capture erase "$finaldata/QCEW_6231.dta"

********************************************************************************
**********************************THE END***************************************
********************************************************************************
