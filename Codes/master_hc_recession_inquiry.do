********************************************************************************
** 	TITLE:		01_Inquiry_figure1
**
**	PROJECT: 	Revision and Resubmission for INQUIRY 
**
**	PURPOSE:  	Master dofile
**							
**	INPUTS:		in /N/slate/tgian/INQUIRY/Finaldata; file names: "$finaldata/QCEW_HealthAffairs.dta"; "$finaldata/QCEW_HealthAffairs.dta"
**
**	OUTPUTS:	
**			
**	AUTHOR:		Cong Gian
**	
**	CREATED:	9/15/2021
**
**	LAST MODIFIED:  9/15/2021
**
**	STATUS: 	Finished
**	NOTES:		
********************************************************************************
* A. Preambles
********************************************************************************
version 15
clear
set more off
capture log close
ssc install statastates, replace
ssc install reghdfe, replace
ssc install distinct, replace
ssc install synth, replace 
ssc install coefplot, replace
ssc install ivreghdfe
net from http://www.stata.com
net cd users
net cd vwiggins
net install grc1leg, replace
net inst brewscheme, from("https://wbuchanan.github.io/brewscheme/") replace
ssc install ivreg2, replace
ssc install ranktest, replace
set scheme s2color 
*****************************************************************************
* B. Paths
*****************************************************************************
global mybox "/N/slate/tgian"
global mydir "$mybox/INQUIRY"
*****************************************************************************

global rawdata "$mydir/Rawdata"
global finaldata "$mydir/Finaldata"
global output "$mydir/Output"
global Log "$mydir/Logs"
global rawdataIPEDS "$IPEDS/Raw Data"
global rawdataQCEW "$QCEW/Raw Data"
global scripts "$mydir/Scripts/Replication Package Inquiry"
*****************************************************************************
* C. Execution
*****************************************************************************
do "$scripts/001_Inquiry_IPEDS_setup.do" // IPEDS data setup
do "$scripts/002_Inquiry_QCEW_setup.do" // QCEW data setup
do "$scripts/01_Inquiry_figure1.do" // Figure 1
do "$scripts/02_Inquiry_figure2.do" // Figure 2
do "$scripts/03_Inquiry_figure3.do" // Figure 3
do "$scripts/04_Inquiry_appdx_figure1.do" // Appendix Figure 1 
do "$scripts/05_Inquiry_appdx_tableB1.do" // Appendix Table B1, B2
do "$scripts/06_Inquiry_appdx_figurB3.do" // Appendix Table B3, B4

********************************************************************************
**********************************THE END***************************************
********************************************************************************









