%let outpath=&dir_rpt.\92.RP;
%macro ST_SUM(tbl=, st=,var=);
	title "&st. - &var.";
	proc tabulate data=&tbl. missing order=formatted;	 
		class IND_BASEL_ASSET_CLASS IND_RP_UNIT;
		var	&var.;
		tables 
			IND_BASEL_ASSET_CLASS="",
			IND_RP_UNIT=""*&var.=" "*(sum=""*f=comma30.2) 
		/rts=20 row=float box="CONSOLD &st.";

		format IND_BASEL_ASSET_CLASS $portcd. ;
		where &where_cond.;
	run;
%mend;

ods html body ="&outpath.\RWA_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MED_RWA_PL,			var=RWA_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MED_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVERE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVERE_RWA_NPL,		var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MED_IA,				var=IA_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVERE_IA,			var=IA_ST3);
ods html close;

ods html body ="&outpath.\RWA_S_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MEDI_RWA_PL,		var=RWA_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MEDI_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVE_RWA_NPL,		var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MEDI_IA,			var=IA_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVE_IA,			var=IA_ST3);
ods html close;

ods html body ="&outpath.\CRM_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=CRM_ST0);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD_CRM_PL,		var=CRM_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MED_CRM_PL,			var=CRM_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVERE_CRM_PL,		var=CRM_ST3);
ods html close;

ods html body ="&outpath.\EAD_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=EAD);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=EAD_ST0);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MILD,				var=EAD_ST1);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=MEDIUM,				var=EAD_ST2);
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=SEVERE,				var=EAD_ST3);
	proc sql;
		select 
			sum(EAD) as EAD,
			sum(EAD_NPL_ST1) as EAD_NPL_ST1,
			sum(EAD_NPL_ST2) as EAD_NPL_ST2,
			sum(EAD_NPL_ST3) as EAD_NPL_ST3
		from MART.RP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
	proc sql;
		select 
			sum(EAD_NPL_SECUR_ST0) as EAD_NPL_SECUR_ST0,
			sum(EAD_NPL_SECUR_ST1) as EAD_NPL_SECUR_ST1,
			sum(EAD_NPL_SECUR_ST2) as EAD_NPL_SECUR_ST2,
			sum(EAD_NPL_SECUR_ST3) as EAD_NPL_SECUR_ST3
		from MART.RP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
	proc sql;
		select 
			sum(EAD_NPL_CLEAN_ST0) as EAD_NPL_CLEAN_ST0,
			sum(EAD_NPL_CLEAN_ST1) as EAD_NPL_CLEAN_ST1,
			sum(EAD_NPL_CLEAN_ST2) as EAD_NPL_CLEAN_ST2,
			sum(EAD_NPL_CLEAN_ST3) as EAD_NPL_CLEAN_ST3
		from MART.RP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
ods html close;

