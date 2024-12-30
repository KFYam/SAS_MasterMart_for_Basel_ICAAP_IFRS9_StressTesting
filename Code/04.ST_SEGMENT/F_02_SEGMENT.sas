proc sort 
	data=FACT.RU_NONBANK_EXP_&st_Rptmth. nodupkey
	out=RU_NONBANK_EXP(keep=
		FLAG_SRC 
		FLAG_DELETE
		FLAG_DELETE_PUL
		FLAG_EXCLUDED_PUL
		FLAG_PUL
		ACCT_ID
		LOAN_CLASS_CD 
		BU_GROUP 
		BU_RU
		BU_NPL
		BUS_UNIT
		IAS_PROD
		DAYS_PASTDUE
		DELQ_BUCKET
		CA_AMT_HKE
		DSR
		DAYS_PASTDUE
		DELQ_BUCKET
		rename=(FLAG_SRC=FLAG_SRC_RU FLAG_DELETE=FLAG_DELETE_RU)
	);
	by ACCT_ID;
	where not missing(ACCT_ID);
run;
proc sort data=FACT.ST_CRM_RWA_FACT_&st_Rptmth. out=RWA_FACT; by ACCT_ID; run;

data STG.STICAAP_00_BASE_&st_Rptmth.;
	merge RWA_FACT(in=a) RU_NONBANK_EXP(in=b);
	by ACCT_ID;
	if a;
run;

data 
	STG.STICAAP_01_SOV_PSE_MDB_&st_Rptmth.
	STG.STICAAP_02_CASH_&st_Rptmth.
	STG.STICAAP_03_PASTDUE_&st_Rptmth.
	STG.STICAAP_04_BANK_FI_&st_Rptmth.
	STG.STICAAP_05_RML_&st_Rptmth.
	STG.STICAAP_06_DERIVATIVE_&st_Rptmth.
	STG.STICAAP_07_NONRML_&st_Rptmth.
	STG.STICAAP_08_EXCEPT_&st_Rptmth.
	;
	set STG.STICAAP_00_BASE_&st_Rptmth.;
	if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("01. Sovereign" "02. PSE" "03. MDB") then 	output STG.STICAAP_01_SOV_PSE_MDB_&st_Rptmth.;	/* Not Stress ;No Loan growth */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("08. Cash") then 						output STG.STICAAP_02_CASH_&st_Rptmth.;			/* Not Stress ; Have Loan growth */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("12. PastDue" "13. Other") then 		output STG.STICAAP_03_PASTDUE_&st_Rptmth.;		/* Not Stress ; No Loan growth */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("04. Bank" "05. Securities Firm") then 	output STG.STICAAP_04_BANK_FI_&st_Rptmth.; 		/* Need Stress ; No Loan growth */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("10. RML") then 						output STG.STICAAP_05_RML_&st_Rptmth.;			/* Need Stress ; Have Loan growth; calculated RWA for NPL and put in PASTDUE asset class in Excel */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("14. Derivative") then 					output STG.STICAAP_06_DERIVATIVE_&st_Rptmth.;	/* Need Stress ; No Loan growth; calculated RWA for NPL and put in DERIVATIVE asset class in Excel  */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in (
		"06. Corporate" "07. CIS" "09. Regulatory Retail" "11. Other (Not PastDue)") then 	output STG.STICAAP_07_NONRML_&st_Rptmth.;		/* Need Stress ; Have Loan growth */
	else output STG.STICAAP_08_EXCEPT_&st_Rptmth.;

run;

%macro seg_ICAAP();
	%if &ind_ICAAP. = ICAAP %then %do;
	%end;
	%else %do;
		data 
			STG.STHKMA_01_TAXI_&st_Rptmth.
			STG.STHKMA_02_PUL_&st_Rptmth.
			;
			set STG.STICAAP_00_BASE_&st_Rptmth.;
			if IAS_PROD = "TAXI/PLB"	then output STG.STHKMA_01_TAXI_&st_Rptmth.;
			if FLAG_PUL=1 				then output STG.STHKMA_02_PUL_&st_Rptmth.;
		run;
	%end;
%mend;
%seg_ICAAP;
