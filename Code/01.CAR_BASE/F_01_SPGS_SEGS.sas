%macro transInfo(file, out);
	%if %sysfunc(exist(&file.)) %then %do;
		proc sort data=&file.;by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT;run;
		%macro tx(file, field);
			proc transpose data=&file. out=tmp;
				by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT;
				var &field.:;
			run;
			data t_&field.(rename=(COL1=&field.));
				set tmp; 
				if find(_NAME_,"_ADJ") and not missing(COL1);
				SEQ=input(compress(_NAME_,"&field._ADJ"),3.);
				drop _NAME_;
			run;
			proc sort data=t_&field.; by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT SEQ; run;
		%mend;
		%tx(&file., PORT_CD);
		%tx(&file., CCF);
		%tx(&file., APPL_RISK_WEIGHT);
		%tx(&file., APPL_CRM_AMT_HKE);
		data x_&out.;
			merge t_PORT_CD t_CCF t_APPL_RISK_WEIGHT t_APPL_CRM_AMT_HKE;
			by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT SEQ;
			FLAG_SRC="&OUT.";
		run;
	%end;
%mend;
%transInfo(stg.s_loan_guar_rbg1_&st_Rptmth., SPFGS_LOAN_RBG1);
%transInfo(stg.s_loan_guar_rbg2_&st_Rptmth., SPFGS_LOAN_RBG2);
%transInfo(stg.s_bill_guar_rbg1_&st_Rptmth., SPFGS_BILL_RBG1);
%transInfo(stg.s_bill_guar_rbg2_&st_Rptmth., SPFGS_BILL_RBG2);
%transInfo(stg.s_loan_guar_wbg1_&st_Rptmth., SPFGS_LOAN_WBG1);
%transInfo(stg.s_loan_guar_wbg2_&st_Rptmth., SPFGS_LOAN_WBG2);
%transInfo(stg.s_boff_guar_rbg1_&st_Rptmth., SPFGS_BOFF_RBG1); /* Off-balance Bill AC ID */

%macro sgps_all();
	data x_sgps_dummy;
		length key $120;
		key=" ";
	run;
	data stg.x_sgps_all_&st_Rptmth.;
		length ACCT_ID $60 ORIG_PORT_CD $10 key $120; 
		set 
			x_sgps_dummy
			%if %sysfunc(exist(x_SPFGS_LOAN_RBG1)) %then %do; x_SPFGS_LOAN_RBG1 %end;
			%if %sysfunc(exist(x_SPFGS_BILL_RBG1)) %then %do; x_SPFGS_BILL_RBG1 %end;
			%if %sysfunc(exist(x_SPFGS_LOAN_WBG1)) %then %do; x_SPFGS_LOAN_WBG1 %end;
			%if %sysfunc(exist(x_SPFGS_LOAN_WBG2)) %then %do; x_SPFGS_LOAN_WBG2 %end;
			%if %sysfunc(exist(x_SPFGS_LOAN_RBG2)) %then %do; x_SPFGS_LOAN_RBG2 %end;
			%if %sysfunc(exist(x_SPFGS_BILL_RBG2)) %then %do; x_SPFGS_BILL_RBG2 %end;
			%if %sysfunc(exist(x_SPFGS_BOFF_RBG1)) %then %do; x_SPFGS_BOFF_RBG1 %end; 
		;
		key=cats(ACCT_ID,ORIG_PORT_CD,ORIG_RISK_WEIGHT);
		if not missing(key) and trim(key) ne ".";
	run;
%mend;
%sgps_all;

proc sort data=stg.x_sgps_all_&st_Rptmth. out=x_sgps_all_key nodupkey; by key; run;
data x_sgps_all_key1;
	retain FMTNAME 'SPFGS' TYPE "C";
	set x_sgps_all_key;
	START=key;
	LABEL=FLAG_SRC;
	keep FMTNAME TYPE START LABEL;
run;
proc format cntlin=x_sgps_all_key1; run;

%macro sgps_dummy();
	proc sql noprint;
		 select count(KEY) into :chk_cnt from x_sgps_all_key;
	quit;
	%if &chk_cnt. = 0 %then %do;
		proc format;
			value $SPFGS
			"##DUMMY###"="##DUMMY###1"
			;
		run;
	%end;
%mend;
%sgps_dummy;

