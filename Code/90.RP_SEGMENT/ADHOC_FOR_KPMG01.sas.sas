%let outpath=&dir_rpt.\92.RP;

/* For KPMG */
proc sql;
create table BREAKDOWN as 
	select 
		IND_RP_UNIT, 
		sum(ORIG_CRM_AMT_HKE_TRN) as ORIG_CRM_AMT_HKE format comma30.2
	from MART.RP_00_BASE_&st_Rptmth.
	where 
	IND_RP_UNIT in ("01. RML" "02. PRTY INV & DEV" "05. NBMCE" "07. OTHER") and
	FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.
	group by IND_RP_UNIT
	order by IND_RP_UNIT
	;
quit;
PROC EXPORT DATA= WORK.Breakdown OUTFILE= "&outpath.\RP_ORG_CRM_C_&st_Rptmth..xls" 
            DBMS=EXCEL5 REPLACE;
RUN;
