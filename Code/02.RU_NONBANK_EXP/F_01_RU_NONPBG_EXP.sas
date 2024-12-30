proc format;
	value $BU_f
	"Corporate Banking (CPB)"	= "CPB"
	"Real Estate Finance"		= "REF"
	"China Corporates"			= "CHINA_CORP"
	"Macau Branch"				= "MC"
	;
run;
proc format;
	value $grp_f
	'CPB'						='1.CPB'
	'CHINA_CORP'				='2.CHI_CORP'
	'FI&PS'						='3.FI&PS'
	'RAM','T&M'					='4.OTHER'
	'REF'						='5.REF'
	'LA','NY','MC','SH'			='6.IBG'
	'SG'						='7.IBG_SGP'
	'CBI_CHINA'					='8.CBIC'
	;
run;

%macro NPLFormat(level=,value=);
	data npl_format;
		retain TYPE "C";
		set siw.xls_npl_&st_RptMth. end=last;

		FMTNAME="npl_&level._&value.";
		%if &level. = c %then %do;
		where not missing(CUST_SEC_ID) and /*trim(left(CUST_SEC_ID)) ne "na" and */ missing(ACCT_ID);
		START=CUST_SEC_ID;
		%end;
		%else %if &level. = a %then %do;
		*where not missing(CUST_SEC_ID) and not missing(ACCT_ID);
		where not missing(ACCT_ID);
		START=trim(left(ACCT_ID));
		%end;
		%if &value. = l %then %do;
		LABEL=LOAN_CLASS_CD;
		%end;
		%if &value. = b %then %do;
		LABEL=put(ORIG_BU_NEW,$BU_f.);
		%end;
		output;
		if last then do;
      		HLO='o';
      		LABEL=' ';
      		output;
   		end;
		keep FMTNAME TYPE START LABEL HLO;
	run;
	proc sql noprint;
		select count(1) into :cnt from npl_format;
	quit;
	%if &cnt. > 1 %then %do;
		proc format cntlin=npl_format; run;
	%end;
	%else %do;
		proc format; value $npl_&level._&value. "@@@@@@@"="@@@@@@@@@@@@@@@@" other =" "; run;
	%end;
%mend;
%NPLFormat(level=c,value=l);
%NPLFormat(level=c,value=b);
%NPLFormat(level=a,value=l);
%NPLFormat(level=a,value=b);


data stg.RU_NONPBG_EXP_&st_RptMth.;
	length CUST_NAME $100 ACCT_ID APPL_CD LOAN_CLASS_CD BU_RU BU_NPL BU_REVISED BU_GROUP $60;
	set 
		siw.xls_ru_nonbk_ibg_&st_RptMth.	(in=IBG		rename=(CUR_BAL_ON_HKE=PRIN_HKE))
		siw.xls_ru_nonbk_wbghk_&st_RptMth.	(in=WBGHK	rename=(CUR_BAL_ON_HKE=PRIN_HKE))
		siw.xls_ru_nonbk_wbgcbic_&st_RptMth.(in=WBGCBIC	rename=(CUR_BAL_ON_HKD=PRIN_HKE))
	;
	if IBG 		then BU_RU=substr(APPL_CD,1,2);
	if WBGHK	then BU_RU=put(UNIT_NEW,$BU_f.);
	if WBGCBIC	then BU_RU="CBI_CHINA";

	LOAN_CLASS_CD		= left(trim(put(CUST_SEC_ID,$npl_c_l.)));
	BU_NPL 				= left(trim(put(CUST_SEC_ID,$npl_c_b.)));
	if missing(LOAN_CLASS_CD) then do;
		LOAN_CLASS_CD	= left(trim(put(ACCT_ID,$npl_a_l.)));
		BU_NPL 			= left(trim(put(ACCT_ID,$npl_a_b.)));
	end;

	if not missing(BU_NPL) then 
		BU_REVISED		= BU_NPL; 
	else 
		BU_REVISED		= BU_RU; 
	BU_GROUP			= put(BU_REVISED, $grp_f.);
	/*	drop CUST_BK_GROUP UNIT_OLD UNIT_NEW;*/
run;
/* Checking purpose
proc freq data=stg.RU_NONPBG_EXP_&st_RptMth.;
table BU_GROUP /missing;
run;
*/
