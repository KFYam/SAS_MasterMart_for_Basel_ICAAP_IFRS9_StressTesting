
data ST_CRM_RWA_FACT_&st_Rptmth.;
	set
		stg.car_iw_adj_&st_Rptmth. 				(in=a01)
		stg.adj_sgp_sec_fix_loan_&st_Rptmth.	(in=a02)
		stg.adj_sgp_mm_&st_Rptmth.				(in=a03)
		stg.adj_sgp_imex_&st_Rptmth.			(in=a04)
		stg.adj_sgp_nostro_tb_&st_Rptmth.		(in=a05)
		stg.adj_delta_3_&st_rptmth.				(in=a06)	
		stg.adj_delta_5_&st_rptmth.				(in=a07)
		stg.adj_delta_6_&st_Rptmth.				(in=a08)
		/*
		stg.adj_delta_14_&st_Rptmth.			(in=a09)
		stg.adj_delta_101_&st_Rptmth. 			(in=a10)	*Off-Balance Datacomm;
		stg.adj_delta_102_&st_Rptmth.		 	(in=a11)	* Off-Balance SPGS;
		*/
		stg.adj_delta_other_&st_Rptmth.			(in=xxx)	
		stg.adj_ns_combined_delta_&st_Rptmth.	(in=a12)	
		stg.adj_ns_subsidiaries_delta_&st_Rptmth.(in=a13)
		stg.car_hkcbf_adj_&st_Rptmth.			(in=a14)	
		stg.adj_ns_hkcbf_delta_&st_Rptmth.		(in=a15)	
		stg.car_sz_adj_&st_Rptmth.				(in=a16)	
		stg.adj_ns_consolid_crm_delta_&st_Rptmth.(in=a17)	
		stg.adj_derv_delta_&st_Rptmth.			(in=a18)	
	;
	if a01 then FLAG_SOLO=1.01; 
	if a02 then FLAG_SOLO=1.02; 
	if a03 then FLAG_SOLO=1.03; 
	if a04 then FLAG_SOLO=1.04; 
	if a05 then FLAG_SOLO=1.05; 
	if a06 then FLAG_SOLO=1.06; 
	if a07 then FLAG_SOLO=1.07; 
	if a08 then FLAG_SOLO=1.08; 
	/*
	if a09 then FLAG_SOLO=1.09; 
	if a10 then FLAG_SOLO=1.10; 
	if a11 then FLAG_SOLO=1.11; 
	*/
	if a12 then FLAG_SOLO=1.12; 
	if xxx then FLAG_SOLO=1.99; 
	if a18 and FILE_SRC="COMBINED-DERV" then FLAG_SOLO=1.18; 

	/* Merge the Rating into Master Table */	
	if substr(CURR_CD,1,2)= COUNTRY_CD then 
		CCY_GROUP='LOC'; 
	else 
		CCY_GROUP='FGN';

	NOTCH_BONDS	= input(put(trim(left(ACCT_ID)),$notch_bd.),3.);
	NOTCH		= input(put(trim(left(CUST_SEC_ID))||trim(left(CCY_GROUP)),$notch_cc. ),3.);

	/* Check the Guarantor's Rating */
	if missing(NOTCH) and not missing(GUARTOR_CUST_SEC_ID) then do;
		NOTCH	= input(put(trim(left(GUARTOR_CUST_SEC_ID))||trim(left(CCY_GROUP)),$notch_cc. ),3.);
	end;
	/* Check the Issuing Bank's Rating -> only for SGP and CBIC */
	if missing(NOTCH) and not missing(ISSUE_BANK_CUST_SEC_ID) then do;
		NOTCH	= input(put(trim(left(ISSUE_BANK_CUST_SEC_ID))||trim(left(CCY_GROUP)),$notch_cc. ),3.);
	end;

	*if missing(NOTCH) and not missing(NOTCH_BONDS) then NOTCH=NOTCH_BONDS;
	if not missing(NOTCH_BONDS) then NOTCH=NOTCH_BONDS;

	/* Fix the case when SHORT_TERM_CLAIM_IND="Y" and APPL_RISK_WEIGHT=20 but NOTCH > 4 for PORT CD in IV V*/
	if NOTCH > 4 and SHORT_TERM_CLAIM_IND ne "Y" and APPL_RISK_WEIGHT=20 and PORT_CD in ("IV" "V") then do;
		FLAG_ECAI_PROXY=NOTCH*.01+1;
		NOTCH = 4;
	end;

	/* Proxy NOTCH Handling for Banking and FI exposures based on existing non missing Notch with same as at Dec 2013 position */
	if missing(NOTCH) and PORT_CD in ("IV" "V") then do;

		FLAG_ECAI_PROXY=2;

		if SHORT_TERM_CLAIM_IND="Y" then do;
			if APPL_RISK_WEIGHT=20 then NOTCH=8;	/*where the est. notch = 7.446953 */	
			if APPL_RISK_WEIGHT=50 then NOTCH=12;  /*where the est. notch = 11.21212 */	
		end;
		else do;	
			if APPL_RISK_WEIGHT=20 then NOTCH=4; 	/*where the est. notch = 4 */	
			if APPL_RISK_WEIGHT=50 then NOTCH=8; 	/*where the est. notch = 7.660031 */	
			if APPL_RISK_WEIGHT=100 then NOTCH=12; /*where the est. notch = 11.22759 */	
		end;
	end;
	ECAI_RATING	= compress(put(NOTCH,sp_rate.)," .");
	* Identify Real Estate Financing (REF) facility Reference;
	if put(FAC_REF,ref_bu.)="#~#" then IND_REF_FROM_BU=1;
	

run;

/* ******************************************************************************************** */
/* ******************************************************************************************** */

/* 
For CONSOLIDATION LEVEL SELECTION: 
	where FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.;
For COMBINED LEVEL SELECTION: 		
	where FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .;
*/


