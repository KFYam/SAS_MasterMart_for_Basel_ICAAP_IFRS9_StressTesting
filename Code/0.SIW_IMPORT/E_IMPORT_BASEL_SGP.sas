%macro tx(type);
	proc contents 
		data=stg.xls_sgp_&type._os_&st_RptMth.
		out=columnvar(keep=name type varnum format) noprint;
	run;
	proc transpose 
		data=stg.xls_sgp_&type._os_&st_RptMth.(firstobs=1 obs=1)
		out=columnname(keep=_NAME_ COL1);
		var _ALL_;
	run;
	proc sql noprint;
		create table columnvar2 as
		select a.*, compress(b.COL1," 123456789/(%)&.") as TXTNAME
		from columnvar a left join columnname b on a.NAME=b._NAME_
		order by varnum;
	quit;
	data columnvar3;
		set columnvar2;
		if missing(TXTNAME) then delete;
		_X1=find(upcase(TXTNAME),'AMT');
		_X2=find(upcase(TXTNAME),'RISKWEIGHT');
		_X3=find(upcase(TXTNAME),'CCF');
		_X4=find(upcase(TXTNAME),'ACCUREDINT');
		_X5=find(upcase(TXTNAME),'RATE');
		_X6=find(upcase(TXTNAME),'EXPOSURE');
		_X7=find(upcase(TXTNAME),'DAYS');
		_X8=find(upcase(TXTNAME),'ACC_INT');
		_X9=find(upcase(TXTNAME),'AMOUNT');
		_X10=find(upcase(TXTNAME),'MTMPL');
		_X11=find(upcase(TXTNAME),'UPLHKE');
		_X12=find(upcase(TXTNAME),'EXPSOURE');
		_X13=find(upcase(TXTNAME),'TOTALHKD');
		FLAG_NUM=max(of _X:);
		drop _X:;
		/* when Mar 2013 the due_date is string but it become datevalue when Jun 2013 */
		if upcase(TXTNAME) in ("TDATE" "VDATE" "MDATE" "RVDATE" "RPT_DATE" 
			"STARTDATE" "ENDDATE" "VALUEDATE" "MAT_DATE" "MONTHSAFTERVALUEDATE" "DUE_DATE") then FLAG_DATE = 1;
		else if upcase(TXTNAME) in ("OS_DATE") then FLAG_DATE = 2;
	run;

	filename tmp temp;
	data _null_;
		file tmp lrecl=65535;
		set columnvar3 end=eof;
		if _n_=1 then do;
			put "data siw.xls_basel_sgp_&type._os_&st_RptMth.;";
			put "set stg.xls_sgp_&type._os_&st_RptMth. (firstobs=2);";
		end;
		if FLAG_NUM > 0 then do;
			put TXTNAME "=input(" NAME ",comma32.);";
		end;
		else if FLAG_DATE = 1 then do;
			put TXTNAME "=input(" NAME ",32.)-&dt_f_x2s.;";
			put "format " TXTNAME " date9.;"; 
		end;
		else if FLAG_DATE = 2 then do;
			put TXTNAME "=input(" NAME ",yymmdd10.);";
			put "format " TXTNAME " date9.;"; 
		end;
		else do;
			put TXTNAME "=" NAME ";";
		end;
		put "drop " NAME ";";
		put "keep " TXTNAME ";";
		if eof then do;
			%if &type. eq IMEX %then %do; 
				put "if not missing(CURR);"; 
				put "if substr(reverse(trim(left(CARItemCode))),1,1) ='Y' then SHORT_TERM_CLAIM_IND='Y'; else SHORT_TERM_CLAIM_IND=''; ";
			%end;
			%if &type. eq Loan %then %do; put "if not missing(CURRENCY);"; %end;
			%if &type. eq MM %then %do; put "if not missing(CCY);"; %end;
			%if &type. eq FX %then %do; put "if not missing(CC);"; %end;
			%if &type. eq Nostro %then %do; put "if not missing(Nature);"; %end;
		put "run;";
		end;
	run;
	%include tmp /source2; 
%mend;


%macro SGPImport(type, namerow, sheet);
	PROC IMPORT OUT = stg.xls_sgp_&type._os_&st_RptMth.
			DATAFILE="&dir_xlssiw.\SG_&type._OS_&st_RptYMD._Return.xls" 
/*			DBMS=EXCELCS REPLACE;*/
			DBMS=XLS REPLACE;
			GETNAMES=NO; DATAROW=&namerow.; 	
			%if &sheet. ne %then %do;
			SHEET="&sheet.";
			%end;
	RUN;
	%tx(&type.);
%mend;

%SGPImport(IMEX,5);			/* IMEX 	- Trade Bills information i.e. LCRP LCRF LCNR & NLRF */
%SGPImport(MM,12);			/* MM 		- Money Market information */
%SGPImport(Loan,4,Sheet1);	/* LOANS 	- Loans and Advance information i.e. Secured Fixed Loan */
%SGPImport(FX,6,Data);		/* FX 		- Off Bal. der. */
%SGPImport(Nostro,5,Sheet1);/* Nostro 	*/
