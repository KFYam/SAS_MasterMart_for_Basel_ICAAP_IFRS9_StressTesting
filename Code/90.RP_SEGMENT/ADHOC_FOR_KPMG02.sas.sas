%let outpath=&dir_rpt.\92.RP;

proc sql noprint;
	create table BANK_FI as
	select 
		NOTCH, SHORT_TERM_CLAIM_IND,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(EAD) as EAD format comma32.
	from 
		MART.RP_03_BANK_FI_&st_Rptmth.
	where FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.
	group by NOTCH, SHORT_TERM_CLAIM_IND
	order by NOTCH, SHORT_TERM_CLAIM_IND;
quit;

proc sort data=siw.XLS_MASTER_SCALE_PD out=s_and_p(keep=notch S_P) nodupkey;
by notch;
run;
data BANK_FI_&st_Rptmth.;
	merge  BANK_FI (in=a) s_and_p(in=b);
	by NOTCH;
	if a;
run;

PROC EXPORT DATA= BANK_FI_&st_Rptmth. OUTFILE= "&outpath.\RP_EXPOSURE_&st_Rptmth..xls" 
            DBMS=EXCEL5 REPLACE;
RUN;


