%let monyy = %SYSFUNC(putn(&dt_RptMth.,monyy7.));
%macro spgs_tx(out,type);
	proc contents 
		data=&out.
		out=columnvar(keep=name type varnum format) noprint;
	run;
	proc transpose 
		data=&out.(firstobs=1 obs=1)
		out=columnname(keep=_NAME_ COL1);
		var _ALL_;
	run;
	proc sql noprint;
		create table columnvar2 as
		select a.*, upcase(compress(b.COL1," +/(%)&."||"0D0A"x)) as TXTNAME
		from columnvar a left join columnname b on a.NAME=b._NAME_
		order by varnum;
	quit;
	data columnvar3;
		set columnvar2;
		if missing(TXTNAME) then delete;
		if missing(compress(substr(TXTNAME,1,1),"0123456789")) then TXTNAME = "A"||TXTNAME;
		if length(TXTNAME)>32 then TXTNAME=substr(TXTNAME,1,32); 
		if TXTNAME = "BR" then TXTNAME = "BR_NAME";
 		%if &type. eq A %then %do;
			_X1=find(upcase(TXTNAME),'ACCOUNT_NO');
			_X2=find(upcase(TXTNAME),'PORT_CD');
			_X3=find(upcase(TXTNAME),'SRC_CD');
			_X4=find(upcase(TXTNAME),'PRD_SYS');
			_X5=find(upcase(TXTNAME),'PROD_SUB');
			_X6=find(upcase(TXTNAME),'CUST_SEC_ID');
			_X7=find(upcase(TXTNAME),'NAT_CURR_CD');
			_X8=find(upcase(TXTNAME),'_IND');
			if sum(of _X:) > 0 then FLAG_NUM=0; else FLAG_NUM=1;
			drop _X:;
		%end;
		%if &type. eq B %then %do;
			_N1=find(upcase(TXTNAME),'_AMT');
			_N2=find(upcase(TXTNAME),'CCF');
			_N3=find(upcase(TXTNAME),'RISK_WEIGHT');
			_N3=find(upcase(TXTNAME),'RISK_WEIGHT');
			if sum(of _N:) > 0 then FLAG_NUM=1;
		%end;
		if find(upcase(TXTNAME),'_DT') then FLAG_DATE = 1;
	run;

	filename tmp temp;
	data _null_;
		file tmp lrecl=65535;
		set columnvar3 end=eof;
		if _n_=1 then do;
			put "data stg.&out._&st_rptmth.;";
			put "set &out.(firstobs=2);";
		end;

		if FLAG_NUM > 0 and FLAG_DATE = 1 then do;
			put TXTNAME "=input(" NAME ",32.)-&dt_f_x2s.;";
			put "format " TXTNAME " date9.;"; 
		end;
		else if FLAG_NUM > 0 then do;
			put TXTNAME "=input(" NAME ",comma32.);";
		end;
		else do;
			put TXTNAME "=" NAME ";";
		end;

		put "drop " NAME ";";
		put "keep " TXTNAME ";";
		if eof then do;
			put "if not missing(orig_port_cd); "; 
		%if &out. eq s_bill_guar_rbg1 %then %do;
			put "if orig_port_cd ne 'XI'; ";
			put "ACCT_ID=compress(substr(ACCOUNT_NO,13)||PROD_SUB_TYP_CD||NAT_CURR_CD,' ');";
		%end;
		%else %if &out. eq s_boff_guar_rbg1 %then %do;
			put "ACCT_ID=compress(substr(ACCOUNT_NO,13)||PROD_SUB_TYP_CD||NAT_CURR_CD,' ');";
		%end;
		%else %if &out. eq s_bill_guar_rbg2 %then %do;put "if orig_port_cd eq 'XI';"; %end;
		%else %if &out. eq s_loan_guar_rbg2 %then %do;put "if orig_port_cd eq 'XI';"; %end;
		%else %do;
			put "if orig_port_cd ne 'XI'; ";
			put "ACCT_ID=ACCOUNT_NO;";
		%end;
			put "keep ACCT_ID;";
			put "run;";
		end;
	run;
	%include tmp /source2; 
%mend;

%macro S_GSImport(file, out, namerow, sheet, type);
	%if %sysfunc(fileexist("&dir_xls.\FMD_&st_Rptmth.\&file.")) %then %do;
		PROC IMPORT OUT = &out.
				DATAFILE="&dir_xls.\FMD_&st_Rptmth.\&file." 
				DBMS=XLS REPLACE;
				GETNAMES=NO; DATAROW=&namerow.; 	
				%if &sheet. ne %then %do;
				SHEET="&sheet.";
				%end;
		RUN;
		%spgs_tx(&out.,&type.);
	%end;
%mend;

%S_GSImport(%str(SpGS & SFGS loan dd (for banking return adj) - &st_RptYMD..xls), s_loan_guar_rbg1, 1, ALSloan_final, A);
%S_GSImport(%str(SpGS & SFGS loan dd (for banking return adj) - &st_RptYMD..xls), s_bill_guar_rbg1, 1, BillsOn_final, A);
%S_GSImport(%str(SpGS & SFGS loan dd (for banking return adj) - &st_RptYMD..xls), s_boff_guar_rbg1, 1, BillsOff_final, A);
%S_GSImport(%str(SPGS_RBG_ADJ_&monyy..xls), s_loan_guar_rbg2, 1, ALS, B);
%S_GSImport(%str(SPGS_RBG_ADJ_&monyy..xls), s_bill_guar_rbg2, 1, Bills, B);
%S_GSImport(%str(SPGS_WBG_&st_Rptmth..xls), s_loan_guar_wbg1, 1, ALSloan_final, A);
%S_GSImport(%str(SFGS_WBG_&st_Rptmth..xls), s_loan_guar_wbg2, 1, ALSloan_final, A);


