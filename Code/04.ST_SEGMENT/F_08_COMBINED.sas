/*%let ia_ca_ratio_wbg=0.1327;*/
/*%let ia_ca_ratio_rbg=0.0908;*/

%macro fillArray(src=,out=);
data &out.;
	set &src.;
	array a_crm			CRM_ST0			- CRM_ST3;
	array a_rw			RW_ST0			- RW_ST3;
	array a_rwa			RWA_ST0			- RWA_ST3;
	array a_ead			EAD_ST0			- EAD_ST3;

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;

	do i=1 to dim(a_crm);
		a_crm(i)	= APPL_CRM_AMT_HKE;
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_ead(i)	= EAD;
	end;
	drop i;
run;
%mend;
%fillArray(src=STG.STICAAP_01_SOV_PSE_MDB_&st_Rptmth., out=MART.STICAAP_01_SOV_PSE_MDB_&st_Rptmth.);
%fillArray(src=STG.STICAAP_03_PASTDUE_&st_Rptmth., 	out=MART.STICAAP_03_PASTDUE_&st_Rptmth.);


data MART.STICAAP_00_BASE_&st_Rptmth.;
	set 
	MART.STICAAP_01_SOV_PSE_MDB_&st_Rptmth.
	MART.STICAAP_02_CASH_&st_Rptmth.
	MART.STICAAP_03_PASTDUE_&st_Rptmth.
	MART.STICAAP_04_BANK_FI_&st_Rptmth.
	MART.STICAAP_05_RML_&st_Rptmth.
	MART.STICAAP_06_DERIVATIVE_&st_Rptmth.
	MART.STICAAP_07_NONRML_&st_Rptmth.
	STG.STICAAP_08_EXCEPT_&st_Rptmth.
	;
run;

/* **************************************************************************/
/* **************************************************************************/
/* Added on 6 June 2014 - Specific for MAS requirement for SGP Portfolio	*/
/* **************************************************************************/
data MART.STMAS_00_BASE_&st_Rptmth.;
	set 
		MART.STMAS_07_NONRML_&st_Rptmth.

		MART.STICAAP_01_SOV_PSE_MDB_&st_Rptmth.
		MART.STICAAP_02_CASH_&st_Rptmth.
		MART.STICAAP_03_PASTDUE_&st_Rptmth.
		MART.STICAAP_04_BANK_FI_&st_Rptmth.
		MART.STICAAP_05_RML_&st_Rptmth.
		MART.STICAAP_06_DERIVATIVE_&st_Rptmth.
		STG.STICAAP_08_EXCEPT_&st_Rptmth.
	;
	if put(IND_BUS_UNIT,$busunit.)= "3.1 IBG-SGP";
run;



