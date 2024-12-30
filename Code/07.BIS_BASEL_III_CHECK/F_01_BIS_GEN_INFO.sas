proc sort data=siw.vi_iambs_cva_ac_exp_&st_RptMth.	out=work.cva_ac_exp nodupkey;
	by ACCT_ID; 
run;
proc sort data=siw.vi_iambs_kw_ac_exp_&st_RptMth.	out=work.kw_ac_exp nodupkey; 
	by ACCT_ID ; 
	where PORT_CD in ("B10" "B11" "B12" "B13" "B14") and ACCT_PROD ne "FF";
run;
proc sort data=siw.vi_iambs_sz_ac_exp_&st_RptMth. 	out=work.sz_ac_exp nodupkey; 
	by ACCT_ID ; 
	where PORT_CD in ("B10" "B11" "B12" "B13" "B14") and ACCT_PROD ne "FF";
run;

data work.cva_sgp;
	set siw.vi_iambs_cva_adj_&st_RptMth.;
	if missing(CONSOL_RATING) then RATED_IND="N";
	else RATED_IND="Y";
	keep ACCT_ID RATED_IND;
run;
proc sort data=work.cva_sgp nodupkey; 
	by ACCT_ID;
run;

data cva_ac_exp_&st_RptMth.;
	merge 
		work.cva_ac_exp(in=a) 
		work.kw_ac_exp(in=b keep=ACCT_ID RATED_IND)
		work.sz_ac_exp(in=c keep=ACCT_ID RATED_IND)
		work.cva_sgp(in=d)
	;
	by ACCT_ID;
	if a;
run;
proc sort data=cva_ac_exp_&st_RptMth.; 
	by CVA_GROUPING_KEY; /* which is equal to RM CUST_SEC_ID */
run;
proc sort data=siw.vi_iacbs_cust_elim_upd_&st_Rptmth. out=elim_ind(rename=(CUST_SEC_ID=CVA_GROUPING_KEY));
	by CUST_SEC_ID;
run;
data stg.cva_ac_exp_&st_RptMth.;
	merge cva_ac_exp_&st_RptMth.(in=a) elim_ind(in=b keep=CVA_GROUPING_KEY ELIM_LVL);
	by CVA_GROUPING_KEY;
	if a;
run;

/* **************************************************************************************** */
/* For EAD Dislosure  																		*/
/* **************************************************************************************** */
proc summary data=stg.cva_ac_exp_&st_RptMth.;
	CLASS 	RATED_IND;
	VAR 	TOT_EXP_AMT_HKE;
	OUTPUT 	
		OUT=MART.BIS_III_EAD_AMT_&st_RptMth.(rename=(TOT_EXP_AMT_HKE=UNADJ_CONSOL_EAD_HKE)) 
		SUM=;
	WHERE missing(ELIM_LVL);
run;
/* **************************************************************************************** */
/* For Count of the Counterparties Dislosure 												*/
/* **************************************************************************************** */
proc sql ;
create table MART.BIS_III_EAD_CNT_&st_RptMth. as 
select 
	COUNT(1) as CNT_COUNTERPARTIES
	from ( 
		select distinct CVA_GROUPING_KEY 
		from siw.vi_iambs_cva_grp_exp_&st_Rptmth. 
		where not (ELIM_LVL<=2)
	);
quit;

/*
proc sql noprint;
	create table test as
	select 
		RATED_IND,
		sum(TOT_EXP_AMT_HKE) as UNADJ_CONSOL_EAD_HKE
	from stg.cva_ac_exp_&st_RptMth.
	where missing(ELIM_LVL)
	group by RATED_IND
	;
quit;
*/


/* Cross Checking to ensure the accuaracy */ 
data calc_result;
	set MART.BIS_III_EAD_AMT_&st_RptMth.;
	where missing(RATED_IND);
	keep UNADJ_CONSOL_EAD_HKE;
run;
data system_result;
	set siw.vi_iambs_cva_result_&st_RptMth.;
	where datepart(as_of_dt) = &dt_Rptmth.;
	keep UNADJ_HKMA_CONSOL_EAD_HKE;
run;
data result_comparison;
	set system_result;
	set calc_result;
	DIFF=round(UNADJ_HKMA_CONSOL_EAD_HKE-UNADJ_CONSOL_EAD_HKE, 0.00005);
run;
