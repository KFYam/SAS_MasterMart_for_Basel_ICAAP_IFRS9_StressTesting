data x_datacom_key;
	set stg.adj_offbal_datacom_&st_Rptmth.;
	key=cats(ACCT_ID,PORT_CD,CCF,ORIG_RISK_WEIGHT,APPL_RISK_WEIGHT);
run;
proc sort data=x_datacom_key nodupkey; by key; run;



data x_datacom_key1;
	retain FMTNAME 'DATCOM' TYPE "C";
	set x_datacom_key;
	START=key;
	LABEL="@@@@@";
	keep FMTNAME TYPE START LABEL;
run;

data x_datacom_dummy;
	retain FMTNAME 'DATCOM' TYPE "C";
	START="$$$$$$$$$$$$$$";
	LABEL="@@@@@";
	keep FMTNAME TYPE START LABEL;
run;

%macro datafmt();
	proc sql noprint;
		select count(START) into :cnt from x_datacom_key1;
	quit;
	%if &cnt. eq 0 %then %do;
		proc format cntlin=x_datacom_dummy; run;
	%end;
	%else %do;
		proc format cntlin=x_datacom_key1; run;
	%end;
%mend;
%datafmt;
