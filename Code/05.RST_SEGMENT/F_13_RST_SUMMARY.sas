%let outpath=&dir_rpt.\92.RST;
%macro ST_SUM(tbl=, st=,var=);
	title "&st. - &var.";
	proc tabulate data=&tbl. missing order=formatted;	 
		class IND_BASEL_ASSET_CLASS IND_RST_UNIT;
		var	&var.;
		tables 
			IND_BASEL_ASSET_CLASS="",
			IND_RST_UNIT=""*&var.=" "*(sum=""*f=comma30.2) 
		/rts=20 row=float box="CONSOLD &st.";

		format IND_BASEL_ASSET_CLASS $portcd. ;
		where &where_cond.;
	run;
%mend;
title;
ods html body ="&outpath.\RWA_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=ACT,				var=RISK_WEIGHTED_AMT_HKE);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MED_RWA_PL,		var=RWA_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MED_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE_RWA_NPL,	var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MED_IA,			var=IA_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE_IA,			var=IA_ST3);
ods html close;

ods html body ="&outpath.\RWA_S_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=ACT,				var=RISK_WEIGHTED_AMT_HKE);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDI_RWA_PL,		var=RWA_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDI_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVE_RWA_NPL,		var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDI_IA,			var=IA_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVE_IA,			var=IA_ST3);
ods html close;

ods html body ="&outpath.\CRM_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=ACT,				var=APPL_CRM_AMT_HKE);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=CRM_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD_CRM_PL,		var=CRM_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MED_CRM_PL,		var=CRM_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE_CRM_PL,		var=CRM_ST3);
ods html close;

ods html body ="&outpath.\EAD_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=ACT,				var=EAD);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=EAD_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD,				var=EAD_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_ST3);


	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=EAD_NPL_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD,				var=EAD_NPL_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_NPL_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_NPL_ST3);
ods html close;

ods html body ="&outpath.\EAD_S_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=ACT,				var=EAD);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=EAD_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD,				var=EAD_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_ST3);


	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=BASE,				var=EAD_NPL_ST0);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MILD,				var=EAD_NPL_ST1);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_NPL_ST2);
	%ST_SUM(tbl=MART.RST_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_NPL_ST3);
ods html close;


/* ************************************************************************************************** */
/* ************************************************************************************************** */
/* For ICAAP - NET INCREASE INCOME CALCULATION														  */
%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */

proc tabulate data=MART.RST_00_BASE_&st_Rptmth. missing order=formatted;	 
		class IND_BASEL_ASSET_CLASS;
		var	crm_npl_st1 crm_npl_st2 crm_npl_st3;
		tables 
			IND_BASEL_ASSET_CLASS="",
			crm_npl_st1*(sum=""*f=comma30.2) 
			crm_npl_st2*(sum=""*f=comma30.2) 
			crm_npl_st3*(sum=""*f=comma30.2) 
		/rts=20 row=float box="CONSOLD";
		format IND_BASEL_ASSET_CLASS $portcd. ;
		where &where_cond.;
run;

%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
proc tabulate data=MART.RST_00_BASE_&st_Rptmth. missing order=formatted;	 
		class IND_BASEL_ASSET_CLASS;
		var	crm_npl_st1 crm_npl_st2 crm_npl_st3;
		tables 
			IND_BASEL_ASSET_CLASS="",
			crm_npl_st1*(sum=""*f=comma30.2) 
			crm_npl_st2*(sum=""*f=comma30.2) 
			crm_npl_st3*(sum=""*f=comma30.2) 
		/rts=20 row=float box="SOLO";
		format IND_BASEL_ASSET_CLASS $portcd. ;
		where &where_cond.;
run;


