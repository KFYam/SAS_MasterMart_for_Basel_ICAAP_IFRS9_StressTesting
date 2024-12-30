%macro offbal_tx(out);
	data stg.&out._&st_rptmth.;
		set &out.(rename=(
			UNDWN_COMMIT_AMT_HKE		=x_UNDWN_COMMIT_AMT_HKE
			ORIG_RISK_WEIGHT			=x_ORIG_RISK_WEIGHT
			APPL_CRM_AMT_HKE_ADJ		=x_APPL_CRM_AMT_HKE_ADJ
			RISK_WEIGHTED_AMT_HKE_ADJ	=x_RISK_WEIGHTED_AMT_HKE_ADJ
		));
		if not missing(ACCT_ID) and not missing(APPL_RISK_WEIGHT_ADJ);
		UNDWN_COMMIT_AMT_HKE			=input(x_UNDWN_COMMIT_AMT_HKE, comma32.);
		ORIG_RISK_WEIGHT				=input(x_ORIG_RISK_WEIGHT, comma32.);
		APPL_CRM_AMT_HKE_ADJ			=input(x_APPL_CRM_AMT_HKE_ADJ, comma32.);
		RISK_WEIGHTED_AMT_HKE_ADJ		=input(x_RISK_WEIGHTED_AMT_HKE_ADJ, comma32.);
		drop x_:;
	run;
%mend;
%macro offbalImport(file, out);
	PROC IMPORT OUT = &out.
			DATAFILE="&dir_xls.\FMD_&st_Rptmth.\&file." 
			DBMS=XLS REPLACE;
			GETNAMES=YES;  	
			SHEET="&st_Rptmth.";
	RUN;
	%offbal_tx(&out.);
%mend;
%offbalImport(Adjustment for DataCom Group_&st_Rptmth..xls, adj_offbal_datacom);
