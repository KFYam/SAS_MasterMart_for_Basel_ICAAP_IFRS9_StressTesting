proc format;
value $BU_NEW
	'1.CPB'			= 'WBG'
	'2.CHI_CORP'	= 'WBG'
	'3.FI&PS'		= 'WBG'	
	'4.OTHER'		= 'WBG'
	'5.REF'			= 'WBG_REF'
	'6.IBG'			= 'IBG'
	'7.IBG_SGP'		= 'IBG'	
/*	'7.IBG_SGP'		= 'IBG_SGP'*/
	'8.CBIC'		= 'CBIC'
;
run;
/* According to internal dicussion with Jose and David on 11 Feb 2014, as per their concern 
that SGP is the major segment of IBG, IBG without SGP segment would not be meaningful.Therefore, 
same NPL would apply for IBG(w/o SGP) and SGP).
On the other hand, in order to fulfil the requirement from MAS, a seperated SGP segment for stressing
are required.
*/



proc format;
value $BU_OLD
	'1.CPB'			= 'WBG'
	'2.CHI_CORP'	= 'WBG'
	'3.FI&PS'		= 'WBG'	
	'4.OTHER'		= 'WBG'
	'5.REF'			= 'WBG'
	'6.IBG'			= 'IBG'
	'7.IBG_SGP'		= 'IBG'
	'8.CBIC'		= 'CBIC'
;
run;
%macro NONBank();
data v_RU_NONBANK/view=v_RU_NONBANK;
	length SEG_BU $30;
	set FACT.RU_NONBANK_EXP_&st_Rptmth.;
	%if &flag_npl_bu. = OLD %then %do;
		SEG_BU		=put(BU_GROUP, $BU_OLD.);
	%end;
	%else %do;
		SEG_BU		=put(BU_GROUP, $BU_NEW.);
	%end;
run;
%mend;
%NONBank;

/*proc freq data=v_RU_NONBANK;table FLAG_SRC/missing;run;*/
%macro NPL_BU(type=, wls=);
	proc sql noprint;
		create table RU_&type._&st_RptMth. as
		select
		%if &type.=BB %then %do;
			'BB' as SEG_BU,
		%end;
		%else %if &type.=PBG %then %do;
			'PBG' as SEG_BU,
		%end;
		%else %if &type.=RML %then %do;
			'RML' as SEG_BU,
		%end;
		%else %if &type.=ALL %then %do;
			'ALL' as SEG_BU,
		%end;
		%else %do;
			SEG_BU,
		%end;
			sum(CLASSIFIED*PRIN_HKE) 				as NPL_AMT format comma30.2,
			sum(PRIN_HKE) 							as PRIN_HKE format comma30.2,
			sum(CLASSIFIED*PRIN_HKE)/sum(PRIN_HKE)	as NPL_RATIO_BY_BU format percent10.5
		from v_RU_NONBANK
		where FLAG_DELETE = . and &wls.
		;
	quit;
%mend;
%NPL_BU(type=WBG,		wls=%str(FLAG_SRC="NONPBG" group by SEG_BU));
%NPL_BU(type=BB,		wls=%str(FLAG_SRC="PBG" and BU_GROUP="PBG_3.BB"));
%NPL_BU(type=PBG,		wls=%str(FLAG_SRC="PBG"));
%NPL_BU(type=RML,		wls=%str(FLAG_SRC="PBG" and BU_GROUP="PBG_1.MORTGAGES"));
%NPL_BU(type=ALL,		wls=%str(FLAG_SRC in ("PBG" "NONPBG")));


data MART.NPL_BY_BU_&flag_npl_bu._&st_RptMth.;
	set 
		RU_WBG_&st_RptMth.
		RU_BB_&st_RptMth. 
		RU_PBG_&st_RptMth.
		RU_RML_&st_RptMth. 
		RU_ALL_&st_RptMth. 
	;
	length MACRO_NAME $20;
	MACRO_NAME=cats("NPL_BU_",SEG_BU);
/* Otherwise override the input from Manual Master File */
*	call symput(MACRO_NAME, NPL_RATIO_BY_BU);
*	if MACRO_NAME="NPL_BU_PBG" then call symput("NPL_BU_ORR", NPL_RATIO_BY_BU);
run;
data _null_;
	call symput("NPL_BU_CTU", 0); /* Because there is impaired loans for CTU, but only impaired asset */
run;	
