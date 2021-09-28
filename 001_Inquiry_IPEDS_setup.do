********************************************************************************
** 	TITLE:		001_Inquiry_IPEDS_setup.do
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Data setup for IPEDS
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$rawdataIPEDS/hd`yr'.dta" (yr = 2005-2018); "$rawdataIPEDS/c`yr'.dta" (yr = 2005-2018)
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
*A. Import Raw Data 
********************************************************************************

// university level data have no county code before 2009
forv yr = 2005/2008 {
	use "$rawdataIPEDS/hd`yr'.dta", clear
	gen zipcode = substr(zip,1,5)
	destring zipcode, force replace
	merge m:1 zipcode using "$rawdata/zcta_county.dta" // ZIP to County Crosswalk
	keep if _merge ==3
	drop _merge
	rename countyfips countycd
	save "$rawdataIPEDS/hd`yr'_temp.dta", replace
	}
	
// saving as temp file to delete later
forv yr = 2009/2018 {
	use "$rawdataIPEDS/hd`yr'.dta", clear
	save "$rawdataIPEDS/hd`yr'_temp.dta", replace
	}	
	
********************************************************************************
*B. Merging c_ file and hd_ file at University level 
********************************************************************************

foreach yr in 05 06 07 08 09 10 11 12 13 14 15 16 17 18 {
	import delimited "$rawdataIPEDS/c20`yr'_a.csv", encoding(ISO-8859-1)clear
	capture rename crace24 ctotalt
	merge m:1 unitid using "$rawdataIPEDS/hd20`yr'_temp.dta"
	gen cipcodestr = string(cipcode) 
	drop cipcode
	rename cipcodestr cipcode
	gen cipcode4= substr(cipcode,1,5) 
	gen cipcode2= substr(cipcode,1,2)
	collapse (sum) ctotalt, by(stabbr countycd cipcode2 cipcode4 cipcode awlevel sector unitid) 
	gen year=20`yr'
	save "$rawdataIPEDS/c20`yr'.dta", replace
	}
	
// Append over years 	
use "$rawdataIPEDS/c2005.dta", clear
forvalues i=2006(1)2018 {
	append using  "$rawdataIPEDS/c`i'.dta"
	}
	
// labeling variables

label var unitid "University ID"
label var stabbr "State Abrev"
label var cipcode "CIPCODE 6 digit"
label var cipcode "CIPCODE 4 digit"
label var ctotalt "Number of Graduates"	
label var cipcode "CIPCODE 6 digit"
label var cipcode2 "CIPCODE 2 digit"
label var cipcode4 "CIPCODE 4 digit"

// Public vs Private Sector

label var sector "sector"
label define sector 1"Public- 4 years or above" 2"Private Non-profit 4 years and above" 3 "Private for Profit - 4 years and above" ///
4 "Public 2years" 5"Private Non-profit -2 years" 6"Private for profit 2years" 7"Public Less than 2 years" ///
8" Private non-profit less than 2 years" 9" Private for-profit less than 2 years"
label values sector sector
gen pubpriv= 1 if sector ==1 | sector==4 | sector==7
replace pubpriv=2 if sector==2 | sector==5| sector ==8
replace pubpriv=3 if sector==3 | sector==6 | sector==9
label var pubpriv "Public, For Porfit vs Non-Profit"
label define pubpriv 1"Public" 2"Private For-Profit" 3"PRivate Non-Profit"
label values pubpriv pubpriv 

// Change CIPCode in before 2010

replace cipcode4 = "51.38" if year <=2009 & cipcode4 == "51.16"
save "$finaldata/IPEDS_cty_2005_18.dta", replace

********************************************************************************
*C. Merging with working population data  
********************************************************************************

use "$rawdata/seer_pop_9017_county_workingpop.dta", clear
gen area_fips = state_fips*10^3 + county
keep area_fip year pop
rename area_fips countyfips
rename pop workpop_cty
save temp.dta, replace
use "$finaldata/IPEDS_cty_2005_18.dta", clear
statastates, abbrev(stabbr)
keep if _merge ==3 
drop _merge
rename state_fips statefips
rename countycd countyfips

********************************************************************************
*D. Merhing with a macro data set for poverty, median household income
********************************************************************************

merge m:1 countyfips statefips year using "$rawdata/macro2005_2018.dta"	
keep if _merge ==3
drop _merge
qui gen poptot_cty2005= poptot_cty if year==2005 
qui bysort countyfips (poptot_cty2005): replace poptot_cty2005=poptot_cty2005[1]
merge m:1 countyfips year using temp.dta
keep if _merge ==3
drop _merge 

********************************************************************************
*E. Sub samples
********************************************************************************

local condition0 "cipcode!=".""
local condition1 "cipcode2 =="51"" // Health Care Sector 
local condition2 "cipcode4 =="51.38" | cipcode4 == "51.08" | cipcode4 == "51.07" | cipcode4 == "51.39"" // Top 4 professions
local condition3 "cipcode2 =="51" & awlevel==1" // Short Term Degree
local condition4 "cipcode2 =="51" & pubpriv==2" // Private University
local condition5 "cipcode4=="51.38" | cipcode4 == "51.39"" // Nursing
local condition6 "cipcode4=="51.08"" // Allied Health and Medical Assisting Services
local condition7 "cipcode4=="51.07"" // Health and Medical Administrative Services"
local cip0 "Whole Economy"
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"

forv i=0(1)7 {
	preserve 
	keep if `condition`i''
	qui collapse (sum) ctotalt (mean) poptot_cty unemp_cty medhh_inc_cty poverty_cty workpop_cty poptot_cty2005, by(countyfips statefips year)			
	count
	save "$finaldata/IPEDS_sample_`i'.dta", replace 
	tab year
	restore
	}
	
********************************************************************************
*F. Sub samples and Share in Overall Health Care 
********************************************************************************	
forv i =1/7 {
	use "$finaldata/IPEDS_sample_`i'.dta", clear
	gen sample = "`i'" 
	append using "$finaldata/IPEDS_sample_0.dta"
	replace sample ="0" if sample == ""
	replace sample ="1" if sample == "`i'"
	destring sample, force replace
	keep ctotalt sample year countyfips statefips
	reshape wide ctotalt, i(year countyfips statefips) j(sample)
	gen s_ctotalt = ctotalt1/ctotalt0*100
	keep year s_ctotalt ctotalt1 ctotalt0 year countyfips statefips 
	merge 1:1 year countyfips statefips using "$finaldata/IPEDS_sample_`i'.dta"
	keep if _merge ==3
	drop _merge 
	gen sample = "`i'" 
	save "$finaldata/IPEDS_cip`i'.dta", replace
	}

********************************************************************************
*G. Append
********************************************************************************	
use "$finaldata/IPEDS_cip1.dta", clear
forv i=2/7 {
	append using "$finaldata/IPEDS_cip`i'.dta"
	}

// Labeling variables	
label var statefips "State FIPS"
label var countyfips "County FIPS"
label var ctotalt0 "Total number of graduates"
label var ctotalt1 "Number of graduates in healthcare"	
label var s_ctotalt "Share of healthcare graduates"
label var poverty_cty "Poverty rate"
label var medhh_inc_cty "Median household income"
label var poptot_cty "Population count"
label var poptot_cty2005 "Population count baseline in 2005"
label var unemp_cty "Unemployment rate"
local cip1 "HealthCare"
local cip2 "Top 4 Professions"
local cip3 "HealthCare Degree < 1yr"
local cip4 "HealthCare Degree from for-profit"
local cip5 "Registered, Practical Nursing, Nursing Admin & Research"
local cip6 "Allied Health and Medical Assisting Services"
local cip7 "Health and Medical Administrative Services"
forv i=1/7 {
	replace sample ="`cip`i''" if sample =="`i'"
}
label var sample "Healthcare sector"
drop ctotalt
save "$finaldata/IPEDS_unemp_final.dta", replace // Final data set

********************************************************************************
*H. Erase Temp Data
********************************************************************************	
// erase data
forv i= 0/7 {
	capture erase "$finaldata/IPEDS_sample_`i'.dta"
	}
erase temp.dta
// erase temp files
forv yr = 2005-2018 {
	capture erase "$rawdataIPEDS/hd`yr'_temp.dta"
	capture erase "$rawdataIPEDS/c20`yr'.dta"
	capture erase "$rawdataIPEDS/hd`yr'.dta"
	}
********************************************************************************
**********************************THE END***************************************
********************************************************************************
	
