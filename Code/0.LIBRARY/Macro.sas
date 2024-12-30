%macro ORA_Extract(input=, output=, date=, ind=);
	/* If ind = REPLACE then replace the existing dataset */
	%if NOT %sysfunc(exist(&output.)) or &ind.=REPLACE %then %do;
		%if &date. ne %then %do; %let dt=&date.; %end;%else %do; %let dt=&dt_RptMth.; %end;
		data &output.; 		
			set &input.; 
			where intnx("MONTH", datepart(as_of_dt), 0 , "END") = &dt.;
		run; 
	%end;
	%else %do;
		%put [Info: The file of &output. is already exist, please check!];
	%end;
%mend;

%Macro Auto_RptMth();
	%if &st_RptMth. =  %then %do;
		data _null_;
			a=intnx("MONTH", date(), -1, "END");
			b=put(a,yymmn6.);
			call symput("st_RptMth", b);
		run;
	%end;
%mend;

/* Error Fixing*/
%macro ErrAdj(err_tbl=,tbl=,mode=);
	proc sort data=&err_tbl. out=adj_no_key(keep=adj_no) nodupkey;
		where IW_Table = "&tbl." and Mode = "&mode.";
		by adj_no;
	run;
	proc sql noprint;
		select count(1) into :cnt from adj_no_key;
	quit;
	%do i=1 %to &cnt.;
		data _null_;
			set adj_no_key(firstobs=&i. obs=&i.);
			call symput("adjno",adj_no);
		run;
		filename EA&adjno. temp;
		data _null_;
			file EA&adjno. lrecl=65535;
			set &err_tbl.;
			if eff_from <= &dt_RptMth. <= eff_to;
			if IW_Table 		= "&tbl.";
			if Mode 			= "&mode.";
			if Adj_No			= "&adjno.";
			put Detail;
		run;
	%end;
%mend;
/*%ErrAdj(err_tbl=siw.XLS_ST_MANUAL_MASTER_&st_rptmth.,tbl=KW_VC,mode=U);*/
