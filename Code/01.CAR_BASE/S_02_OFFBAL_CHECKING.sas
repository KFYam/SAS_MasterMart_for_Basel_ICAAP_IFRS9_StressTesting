%macro offbal_bk(key);
proc sql;
	create table SC_OFFBAL_BY_PORT_CD as 
	select 
		&key.,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from FACT.ST_CRM_RWA_FACT_&st_Rptmth.
	where 
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		PORT_CD in ('B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9a' 'B9b' 'B9c' 'B9d')
	group by &key.
	order PORT_CD, CCF
	;
quit;
proc sql;
	create table SC_OFFBAL_BY_PORT_CD_SOLO as 
	select 
		&key.,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from FACT.ST_CRM_RWA_FACT_&st_Rptmth.
	where 
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and 
		PORT_CD in ('B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9a' 'B9b' 'B9c' 'B9d')
	group by &key.
	order PORT_CD, CCF
	;
quit;
%mend;
/*%offbal_bk(%str(PORT_CD,CCF,FILE_SRC,FLAG_ADJ,FLAG_DELETE));*/
%offbal_bk(%str(PORT_CD,CCF,FLAG_DELETE));

proc sql noprint;
	create table SC_OFFBAL_ALL as 
	select 
		PORT_CD,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from FACT.ST_CRM_RWA_FACT_&st_Rptmth.
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		PORT_CD in ('B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9a' 'B9b' 'B9c' 'B9d')
	group by PORT_CD
	;
	create table SC_OFFBAL_ALL_SOLO as 
	select 
		PORT_CD,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from FACT.ST_CRM_RWA_FACT_&st_Rptmth.
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and 
		PORT_CD in ('B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9a' 'B9b' 'B9c' 'B9d')
	group by PORT_CD
	;
quit;

proc sql;
create table sc_off_all_sum as
select 
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from SC_OFFBAL_ALL 
;
quit;
