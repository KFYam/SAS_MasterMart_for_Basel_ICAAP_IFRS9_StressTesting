%let outpath=&dir_rpt.\92.RP;
%macro ST_SUM(tbl=, st=,var=);
	title "&st. - &var.";
	proc tabulate data=&tbl. missing order=formatted;	 
		class IND_RP_UNIT IND_BUS_UNIT;
		var	&var.;
		tables 
			IND_RP_UNIT="",
			IND_BUS_UNIT=""*&var.=" "*(sum=""*f=comma30.2) 
		/rts=20 row=float box="CONSOLD &st.";
		format IND_BUS_UNIT $busunit.;
		where &where_cond.;
	run;
%mend;

ods html body ="&outpath.\RWA_BASE_&st_Rptmth..xls";
	%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.; /* Consolidation Level */
	%ST_SUM(tbl=MART.RP_00_BASE_&st_Rptmth., st=BASE,				var=RWA_ST0);
ods html close;
