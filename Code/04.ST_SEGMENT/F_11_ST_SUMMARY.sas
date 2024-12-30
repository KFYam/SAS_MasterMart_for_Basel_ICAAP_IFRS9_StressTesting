%macro ST_SUM(tbl=, st=,var=);
	title "&st. - &var.";
	proc tabulate data=&tbl. missing order=formatted;	 
		class IND_BASEL_ASSET_CLASS IND_BUS_UNIT;
		var	&var.;
		tables 
			IND_BASEL_ASSET_CLASS="",
			IND_BUS_UNIT=""*&var.=" "*(sum=""*f=comma30.2) 
		/rts=20 row=float box="CONSOLD &st.";

		format IND_BASEL_ASSET_CLASS $portcd. IND_BUS_UNIT $busunit.;
		where &where_cond.;
	run;
%mend;

%macro genRpt();
	%if &ind_ICAAP.=ICAAP %then %do;
		%let outpath=&dir_rpt.\91.ICAAP;
	%end;
	%else %do;
		%let outpath=&dir_rpt.\04.ST_SEGMENT;
	%end;
	
	ods html body ="&outpath.\STRESS_RWA_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=ACT,				var=RISK_WEIGHTED_AMT_HKE);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MED_RWA_PL,		var=RWA_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MED_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE_RWA_NPL,	var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MED_IA,			var=IA_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE_IA,			var=IA_ST3);
	ods html close;

	ods html body ="&outpath.\STRESS_RWA_S_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=ACT,				var=RISK_WEIGHTED_AMT_HKE);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,		var=RWA_NPL_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDI_RWA_PL,		var=RWA_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDI_RWA_NPL,		var=RWA_NPL_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVE_RWA_PL,		var=RWA_ST3);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVE_RWA_NPL,		var=RWA_NPL_ST3);

	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDI_IA,			var=IA_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVE_IA,			var=IA_ST3);
	ods html close;

	ods html body ="&outpath.\STRESS_CRM_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=ACT,				var=APPL_CRM_AMT_HKE);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=CRM_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=CRM_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MED_RWA_PL,		var=CRM_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE_RWA_PL,		var=CRM_ST3);
	ods html close;

	ods html body ="&outpath.\STRESS_EAD_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=ACT,				var=EAD);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=EAD_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD,				var=EAD_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_ST3);

	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=EAD_NPL_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD,				var=EAD_NPL_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_NPL_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_NPL_ST3);
	ods html close;

	ods html body ="&outpath.\STRESS_EAD_S_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=ACT,				var=EAD);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=EAD_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD,				var=EAD_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_ST3);

	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=BASE,				var=EAD_NPL_ST0);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MILD,				var=EAD_NPL_ST1);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=MEDIUM,			var=EAD_NPL_ST2);
	%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=SEVERE,			var=EAD_NPL_ST3);
	ods html close;

	ods html body ="&outpath.\STRESS_EAD_NPLCLEAN_C_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	proc sql;
		select 
			sum(EAD_NPL_CLEAN_ST0) as EAD_NPL_CLEAN_ST0,
			sum(EAD_NPL_CLEAN_ST1) as EAD_NPL_CLEAN_ST1,
			sum(EAD_NPL_CLEAN_ST2) as EAD_NPL_CLEAN_ST2,
			sum(EAD_NPL_CLEAN_ST3) as EAD_NPL_CLEAN_ST3
		from MART.STICAAP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
	ods html close;
	/*
	proc sql;
		select 
			sum(EAD) as EAD,
			sum(EAD_NPL_ST1) as EAD_NPL_ST1,
			sum(EAD_NPL_ST2) as EAD_NPL_ST2,
			sum(EAD_NPL_ST3) as EAD_NPL_ST3
		from MART.STICAAP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
	proc sql;
		select 
			sum(EAD_NPL_SECUR_ST0) as EAD_NPL_SECUR_ST0,
			sum(EAD_NPL_SECUR_ST1) as EAD_NPL_SECUR_ST1,
			sum(EAD_NPL_SECUR_ST2) as EAD_NPL_SECUR_ST2,
			sum(EAD_NPL_SECUR_ST3) as EAD_NPL_SECUR_ST3
		from MART.STICAAP_00_BASE_&st_Rptmth. where &where_cond.;
	quit;
	*/

	%if &ind_ICAAP.=ICAAP %then %do;
	%end;
	%else %do;
		ods html body ="&outpath.\STRESS_PUL_&st_Rptmth..xls";
		%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=. and FLAG_DELETE_PUL=.; /* Consolidation Level */
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=BASE,			var=RWA_ST0);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=SEVERE_RWA_PL,	var=RWA_ST3);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=SEVERE_RWA_NPL,	var=RWA_NPL_ST3);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,st=SEVERE_CA,		var=CA_ST3);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,st=BASE_CA,			var=CA_AMT_HKE);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=BASE_CRM,		var=CRM_ST0);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=SEVERE_CRM,		var=CRM_ST3);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=BASE_EAD,		var=EAD_ST0);
		%ST_SUM(tbl=MART.STHKMA_02_PUL_&st_Rptmth.,	st=SEVERE_EAD,		var=EAD_ST3);
		ods html close;

		ods html body ="&outpath.\STRESS_TAXI_&st_Rptmth..xls";
		%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=. and FLAG_DELETE_PUL=.; /* Consolidation Level */
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=BASE,			var=RWA_ST0);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MILD_RWA,		var=RWA_ST1);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MEDI_RWA,		var=RWA_ST2);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=SEVE_RWA,		var=RWA_ST3);

		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MILD_IA,		var=IA_ST1);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MEDI_IA,		var=IA_ST2);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=SEVE_IA,		var=IA_ST3);

		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=BASE_CRM,		var=CRM_ST0);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MILD_CRM,		var=CRM_ST1);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=MEDI_CRM,		var=CRM_ST2);
		%ST_SUM(tbl=MART.STHKMA_01_TAXI_&st_Rptmth., st=SEVE_CRM,		var=CRM_ST3);
		ods html close;


		/* ************************************************************************************ */
		/* ************************************************************************************ */
		/* Specific HKMA Requirement for PBG Portfolio 											*/
		/* RML Portfolio (according to Basel II definition after CRM)							*/
		/* ************************************************************************************ */
		ods html body ="&outpath.\STRESS_RML_&st_Rptmth..xls";
		%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
		proc sql;
			select 
				sum(RWA_ST0)					as RWA_BASE 		format comma30.2,
				sum (sum(RWA_ST1,RWA_NPL_ST1))	as RWA_MILD			format comma30.2,
				sum (sum(RWA_ST2,RWA_NPL_ST2))	as RWA_MEDIUM		format comma30.2,
				sum (sum(RWA_ST3,RWA_NPL_ST3))	as RWA_SEVERE		format comma30.2,
				sum(EAD_ST0)					as EAD_BASE 		format comma30.2,
				sum(EAD_ST1)					as EAD_MILD 		format comma30.2,
				sum(EAD_ST2)					as EAD_MEDIUM 		format comma30.2,
				sum(EAD_ST3)					as EAD_SEVERE 		format comma30.2,
				sum (IA_ST1)					as IA_MILD			format comma30.2,
				sum (IA_ST2)					as IA_MEDIUM		format comma30.2,
				sum (IA_ST3)					as IA_SEVERE		format comma30.2,
				sum (CA_AMT_HKE)				as CA_AMT_HKE		format comma30.2	
			from MART.STICAAP_00_BASE_&st_Rptmth.
			where &where_cond. and IND_BASEL_ASSET_CLASS="IX";
		quit;
		ods html close;


		/* ************************************************************************************ */
		/* ************************************************************************************ */
		/* Specific MAS Requirement for SGP Portfolio 											*/
		/* ************************************************************************************ */
		ods html body ="&outpath.\STRESS_SGP_S_&st_Rptmth..xls";
		%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .; /* Solo Level */
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=BASE,			var=RWA_ST0);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MILD_RWA_PL,		var=RWA_ST1);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MILD_RWA_NPL,	var=RWA_NPL_ST1);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MEDI_RWA_PL,		var=RWA_ST2);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MEDI_RWA_NPL,	var=RWA_NPL_ST2);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=SEVE_RWA_PL,		var=RWA_ST3);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=SEVE_RWA_NPL,	var=RWA_NPL_ST3);

		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MILD_IA,			var=IA_ST1);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=MEDI_IA,			var=IA_ST2);
		%ST_SUM(tbl=MART.STMAS_00_BASE_&st_Rptmth., st=SEVE_IA,			var=IA_ST3);
		ods html close;
	%end;
%mend;
%genRpt;

%macro ICAAP_Adhoc();
	/* For ICAAP - NET INCREASE INCOME CALCULATION */
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	proc tabulate data=MART.STICAAP_00_BASE_&st_Rptmth. missing order=formatted;	 
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
	proc tabulate data=MART.STICAAP_00_BASE_&st_Rptmth. missing order=formatted;	 
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

	/* For HKMA Corporate Asset Class checking */
	%let outpath=&dir_rpt.\91.ICAAP;
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */

	ods html body ="&outpath.\STRESS_HKMA_C_&st_Rptmth..xls";
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_BASE_PL,		var=CRM_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_MILD_PL,		var=CRM_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_MEDI_PL,		var=CRM_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_SEVE_PL,		var=CRM_ST3);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_BASE_NPL,		var=CRM_NPL_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_MILD_NPL,		var=CRM_NPL_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_MEDI_NPL,		var=CRM_NPL_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=CRM_SEVE_NPL,		var=CRM_NPL_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_BASE_PL,		var=EAD_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MILD_PL,		var=EAD_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MEDI_PL,		var=EAD_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_SEVE_PL,		var=EAD_ST3);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_BASE_NPL,		var=EAD_NPL_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MILD_NPL,		var=EAD_NPL_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MEDI_NPL,		var=EAD_NPL_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_SEVE_NPL,		var=EAD_NPL_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_BASE_NPL_SEC,	var=EAD_NPL_SECUR_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MILD_NPL_SEC,	var=EAD_NPL_SECUR_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MEDI_NPL_SEC,	var=EAD_NPL_SECUR_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_SEVE_NPL_SEC,	var=EAD_NPL_SECUR_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_BASE_NPL_CLE,	var=EAD_NPL_CLEAN_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MILD_NPL_CLE,	var=EAD_NPL_CLEAN_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_MEDI_NPL_CLE,	var=EAD_NPL_CLEAN_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=EAD_SEVE_NPL_CLE,	var=EAD_NPL_CLEAN_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_BASE_PL,		var=RWA_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MILD_PL,		var=RWA_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MEDI_PL,		var=RWA_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_SEVE_PL,		var=RWA_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_BASE_NPL,		var=RWA_NPL_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MILD_NPL,		var=RWA_NPL_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MEDI_NPL,		var=RWA_NPL_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_SEVE_NPL,		var=RWA_NPL_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_BASE_NPL_SEC,	var=RWA_NPL_SECUR_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MILD_NPL_SEC,	var=RWA_NPL_SECUR_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MEDI_NPL_SEC,	var=RWA_NPL_SECUR_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_SEVE_NPL_SEC,	var=RWA_NPL_SECUR_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_BASE_NPL_CLE,	var=RWA_NPL_CLEAN_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MILD_NPL_CLE,	var=RWA_NPL_CLEAN_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_MEDI_NPL_CLE,	var=RWA_NPL_CLEAN_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=RWA_SEVE_NPL_CLE,	var=RWA_NPL_CLEAN_ST3);

		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=IA_BASE,			var=IA_ST0);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=IA_MILD,			var=IA_ST1);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=IA_MEDI,			var=IA_ST2);
		%ST_SUM(tbl=MART.STICAAP_00_BASE_&st_Rptmth., st=IA_SEVE,			var=IA_ST3);

	ods html close;

	/* */

	/* For HKMA Derivative Checking */
	data derivative;
		set mart.sticaap_06_derivative_201312;
		ead_n0=sum(crm_ST0,crm_NPL_st0);
		ead_n1=sum(crm_ST1,crm_NPL_st1);
		ead_n2=sum(crm_ST2,crm_NPL_st2);
		ead_n3=sum(crm_ST3,crm_NPL_st3);
	run;
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
		proc sql;
			select 
				sum(EAD) as EAD format comma30.2,
				sum(EAD_n0) as EAD_n0 format comma30.2,
				sum(EAD_n1) as EAD_n1 format comma30.2,
				sum(EAD_n2) as EAD_n2 format comma30.2,
				sum(EAD_n3) as EAD_n3 format comma30.2
			from derivative where &where_cond.;
		quit;
%mend;
