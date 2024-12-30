/* ---------------------------------------------------------------------------- */
/* HKCBF - Manual Adjustment 													*/
/* ---------------------------------------------------------------------------- */
%macro getNS_HKCBF(field);
	data stg.adj_ns_hkcbf_delta_&st_Rptmth.;
		set stg.ns_hkcbf_&st_Rptmth.;
		if not missing(PORT_CD) and not missing(&field.);
		FLAG_ELIM_CONSOL	=.;
		FLAG_ELIM_COMBIN	=.;
		SHORT_TERM_CLAIM_IND="N";

		FILE_SRC 			="NS_HKCBF"; 
		ENTITY 				="HKCBF";
		APPL_CD				="MANUAL ADJ";
		
		if PORT_CD="Ia_0" 		then RISKWEIGHT=0;			/* since the RW in excel = 20 but it actually = 0; so hardcode here */
		if PORT_CD="IV_Y_20"	then FLAG_ELIM_CONSOL=2.0;	/* MM Placing would be eliminated ; most likely = Nostro of CBIC and HKCBF */

		tmp1				=tranwrd(PORT_CD,trim(left(put(RISKWEIGHT,3.))),"");
		tmp2				=substr(tmp1,1,length(trim(tmp1))-1);
		/*test				=substr(left(reverse(tmp2)),1,2);*/
		if substr(left(reverse(tmp2)),1,2)="Y_" then do;
			SHORT_TERM_CLAIM_IND = "Y";
			tmp2 = tranwrd(tmp2,"_Y", "");
		end;

		ORIG_PORT_CD 		=tmp2;
		PORT_CD				=tmp2;
		ORIG_RISK_WEIGHT	=RISKWEIGHT;
		APPL_RISK_WEIGHT	=RISKWEIGHT;
		ORIG_CRM_AMT_HKE	=&field.;
		APPL_CRM_AMT_HKE	=&field.;
		RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;

		keep
		FILE_SRC
		ENTITY
		APPL_CD
		ORIG_PORT_CD
		PORT_CD
		ORIG_RISK_WEIGHT
		APPL_RISK_WEIGHT
		ORIG_CRM_AMT_HKE
		APPL_CRM_AMT_HKE
		RISK_WEIGHTED_AMT_HKE
		FLAG_ELIM_CONSOL
		FLAG_ELIM_COMBIN
		SHORT_TERM_CLAIM_IND
		;
	run;
%mend;
%getNS_HKCBF(TOTAL);

/* ---------------------------------------------------------------------------- */
/* HKCBF - IW table Adjustment 													*/
/* ---------------------------------------------------------------------------- */
data stg.car_hkcbf_adj_&st_Rptmth.;
	set stg.vi_iambs_cf_car_&st_RptMth.;
	FILE_SRC 					="HKCBF";
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
	if PORT_CD in ("IV") and SHORT_TERM_CLAIM_IND="Y" then do;
		if ORIG_RISK_WEIGHT=100 and missing (COLL_ACCT_ID) then Adjusted_RW=50;
		else Adjusted_RW=20;

	 	ORIG_PORT_CD='IV';
		PORT_CD='IV';
		FLAG_ADJ = 8.1;
	 	ORIG_RISK_WEIGHT=Adjusted_RW;
		APPL_RISK_WEIGHT=Adjusted_RW;
	 	RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		drop Adjusted_RW;
	end;
	if ORIG_PORT_CD="IX" and ORIG_RISK_WEIGHT=75 and ORIG_LTV_RATIO <=70 then do;
		ORIG_RISK_WEIGHT=35;
		APPL_RISK_WEIGHT=35;
	 	RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		FLAG_ADJ = 20;
	end;

	/* ********************************************************************* */
	/* ********************************************************************* */
	/* Consolidated Interco-elimination (IW) Handling 						 */
	/* ********************************************************************* */
	if substr(PORT_CD,1,2) = "IV" and find(CUST_NAME,"CITIC") then FLAG_ELIM_CONSOL=2.1;

run;

/* Sense Checking
data aa;
	set stg.car_hkcbf_adj_&st_Rptmth. stg.adj_ns_hkcbf_delta_&st_Rptmth.;
run;

proc sql;
select port_cd, appl_risk_weight,sum(APPL_CRM_AMT_HKE) as sum format comma32.
from aa
group by port_cd, appl_risk_weight;
quit;

proc sql;
select sum(APPL_CRM_AMT_HKE) as sum format comma32.
from aa;
quit;
*/
