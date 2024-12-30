%ErrAdj(err_tbl=siw.XLS_ST_MANUAL_MASTER_&st_rptmth.,tbl=CBIC,mode=U);

data stg.car_sz_adj_&st_Rptmth.;
	set stg.vi_iambs_sz_car_&st_RptMth.;

	FILE_SRC 					="CBIC";
	FLAG_ELIM_CONSOL			=.;
	FLAG_ELIM_COMBIN			=.;

	ORIG_PORT_CD_IW				=ORIG_PORT_CD;
	PORT_CD_IW					=PORT_CD;
	APPL_CRM_AMT_HKE_IW			=APPL_CRM_AMT_HKE;
	APPL_RISK_WEIGHT_IW			=APPL_RISK_WEIGHT;
	ORIG_RISK_WEIGHT_IW			=ORIG_RISK_WEIGHT;
	RISK_WEIGHTED_AMT_HKE_IW	=RISK_WEIGHTED_AMT_HKE;

	/* -------------------------------------------------------------------- */
	/* Adj 600.3 - Same manner with ADj 8 									*/
	/* Reallocation of short term bank exposure; due to limitation of system*/
	/* for handling Nostro 													*/	
	/* -------------------------------------------------------------------- */
	/* As after the health check the CBIC data when uploading to Basel Engine from May 2014, The fixing need 
	   not to be applied here again; the below logic is obsolete starting from May 2014 */
	/*
	if PORT_CD in ("IV") and SHORT_TERM_CLAIM_IND="Y" then do;
		if ORIG_RISK_WEIGHT=100 and missing (COLL_ACCT_ID) then Adjusted_RW=50;
		else Adjusted_RW=20;

	 	ORIG_PORT_CD='IV';
		PORT_CD='IV';
	 	ORIG_RISK_WEIGHT=Adjusted_RW;
		APPL_RISK_WEIGHT=Adjusted_RW;
	 	RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		FLAG_ADJ=8.2;
		drop Adjusted_RW;
	end;
	*/
	/* B18 - SFT case would not excluded */ 
	if PORT_CD in ("B10" "B11" "B12" "B13" "B14" "B15" "B16" "B17" /*"B18"*/) then FLAG_DELETE = 400; 

	%include EA201 /source2; *<----- Error Adjustment 201;
run;

/*
proc sql;
select 
port_cd, 
appl_risk_weight,
cats(port_cd,"_",appl_risk_weight),
sum(APPL_CRM_AMT_HKE) as sum format comma32.
from stg.car_sz_adj_&st_Rptmth.
group by port_cd, appl_risk_weight;
quit;
*/
