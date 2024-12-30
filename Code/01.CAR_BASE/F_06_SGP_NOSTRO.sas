/* Adj 9 - Singapore Nostro & TB										*/
/* Directly copy from [Adj_Data]										*/
/* -------------------------------------------------------------------- */
/* Refer to [Adj_Data] of Basel worksheet for RWA - remark:(Singapore - Nostro & Treasury Bill) */

data stg.adj_sgp_nostro_tb_&st_Rptmth.;
	set siw.xls_basel_sgp_nostro_os_&st_Rptmth.;
	FILE_SRC				="SGP_NOSTRO";
	FLAG_ADJ 				= 9.1;
	ENTITY					="SGP";
	APPL_CD					="NOSTRO SGP";
	FLAG_ELIM_CONSOL		=.; 

	if find(PortCDRW,"_RP_") > 0 then FLAG_ELIM_CONSOL=1; 	
	if find(PortCDRW,"_Y_") > 0 then SHORT_TERM_CLAIM_IND="Y";

	CUST_NAME				=NATURE;
	ACCT_ID					=OGLCODE;

	PortCDRW				=compress(tranwrd(tranwrd(tranwrd(PortCDRW, "_Securities", ""),"_Y",""),"_RP","")," ");
	tmp2					=find(PortCDRW,"_");
	ORIG_PORT_CD 			=substr(PortCDRW,1,tmp2-1);
	ORIG_RISK_WEIGHT		=input(substr(PortCDRW,tmp2+1,length(PortCDRW)-tmp2),30.);

	ORIG_CRM_AMT_HKE		=TOTALHKD;
	
	PORT_CD					=ORIG_PORT_CD;
	APPL_RISK_WEIGHT		=ORIG_RISK_WEIGHT;
	APPL_CRM_AMT_HKE		=ORIG_CRM_AMT_HKE;
	RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
	CURR_CD					=CCY;

	keep 
	FILE_SRC FLAG_ADJ ENTITY APPL_CD FLAG_ELIM_CONSOL SHORT_TERM_CLAIM_IND
	CUST_NAME ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT ORIG_CRM_AMT_HKE
	PORT_CD APPL_RISK_WEIGHT APPL_CRM_AMT_HKE RISK_WEIGHTED_AMT_HKE
	ISSUE_BANK_CUST_SEC_ID CURR_CD;
run;

