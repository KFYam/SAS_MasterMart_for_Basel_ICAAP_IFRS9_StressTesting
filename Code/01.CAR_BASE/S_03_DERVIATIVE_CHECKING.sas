data OFF_DERV ;
	set FACT.st_crm_rwa_fact_&st_Rptmth.;
	if PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" "B18");
	PORT_YR=cats(PORT_CD,"_",EXP_REF);
	if PORT_CD="B18" then PORT_YR=PORT_CD;
run;

proc sql noprint;
	create table SC_OFF_DERV as 
	select 
		PORT_YR,FILE_SRC,FLAG_ADJ,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from OFF_DERV 
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" "B18")
	group by PORT_YR,FILE_SRC,FLAG_ADJ;

	create table SC_OFF_DERV_SOLO as 
	select 
		PORT_YR,FILE_SRC,FLAG_ADJ,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from OFF_DERV 
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and 
		PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" "B18")
	group by PORT_YR,FILE_SRC,FLAG_ADJ;
quit;
proc sql noprint;
	create table SC_OFF_DERV_ALL as 
	select 
		PORT_YR,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from OFF_DERV 
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" "B18")
	group by PORT_YR;

	create table SC_OFF_DERV_ALL_SOLO as 
	select 
		PORT_YR,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from OFF_DERV 
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and 
		PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" "B18")
	group by PORT_YR;
quit;


proc sql;
create table sc_derv_all_sum as
select 
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from SC_OFF_DERV_ALL
;
quit;


proc sql;
	create table SC_RWA_ALL as 
	select 
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from FACT.ST_CRM_RWA_FACT_&st_Rptmth.
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = .
	;
quit;
