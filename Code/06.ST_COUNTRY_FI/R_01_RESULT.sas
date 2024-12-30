proc format;
	value unrate_f
	1="Unrated"
	.="Rated"
	;
run;


ods html file="&dir_rpt.\EL_&st_RptMth..xls";

%macro outreport(title=,class=, ind=);
	proc tabulate data = MART.BKFI_ST_BASE_&st_Rptmth. noseps missing formchar='|-' style=printer;
		class &class.;
		%if &class. = FLAG_UNRATED %then %do;
			format FLAG_UNRATED unrate_f.; 
		%end;
		%if &ind. eq VT %then %do;
			where CUST_SEC_ID in ('B*07086','B*06445','HKBL00011','HKBL00008','HKZFIG104');
		%end;
		var 
			APPL_CRM_AMT_HKE 
			RWA_ST0 
			EL_ST0
			RWA_ST1
			EL_ST1
			RWA_ST2
			EL_ST2
		;
		table &class.=""  all, 
			(APPL_CRM_AMT_HKE*sum)
			(RWA_ST0="RWA"*sum) 
			(EL_ST0="EL"*sum) 
			(RWA_ST1="RWA_ST"*sum) 
			(EL_ST1="EL_ST"*sum) 
			(RWA_ST2="RWA_ST2"*sum) 
			(EL_ST2="EL_ST2"*sum) 
			/rts=20 misstext="0";
		title "&title.";
	run; 
%mend;
%outreport(title=%str(Customer Name)	,class=GRP_NAM);
%outreport(title=%str(Unrated)			,class=FLAG_UNRATED);
%outreport(title=%str(Vietnam Banks)	,class=GRP_NAM, ind=VT);

ods html close;
