
data stg.adj_sgp_sec_fix_loan_&st_Rptmth.;
	set siw.xls_basel_sgp_loan_os_&st_Rptmth.;
	where not missing(PORTCDRW);

	FILE_SRC				="SGP_LOAN";
	ENTITY					="SGP";
	APPL_CD					="SEC FIXED LOAN";
	ACCT_ID					=put(_N_,z3.);

	TMP_URLINE				=find(PORTCDRW,"_");
	if TMP_URLINE > 0 then do;
		if upcase(substr(PORTCDRW,TMP_URLINE+1,1))="Y" then do;
			SHORT_TERM_CLAIM_IND	='Y';
			TMP_URLINE1				=find(PORTCDRW,"_",TMP_URLINE); 
			ORIG_PORT_CD 			=substr(PORTCDRW,1,TMP_URLINE1-1);
		end; 
		else do;
			ORIG_PORT_CD 			=substr(PORTCDRW,1,TMP_URLINE-1);
		end;
		TMP_RW=find(left(reverse(PORTCDRW)),"_");
		ORIG_RISK_WEIGHT=input(reverse(substr(left(reverse(PORTCDRW)),1,TMP_RW-1)),10.);
	end;

	PORT_CD					=ORIG_PORT_CD;
	CURR_CD					=CURRENCY;
	CUST_NAME				=CUSTOMERNAME;
	COUNTRY_CD				="SG";
	FAC_TYP					="SECURED FIXED LOAN";
	CUR_BAL_ON				=Prin_AmtSGDEquiv;
	UNPAID_INT_ACCR			=Acc_IntSGDEquiv;
	TOT_EXP_AMT_HKE			=TotalExposuresinHKDEqv;

	ORIG_CRM_AMT_HKE		=APPL_CRM_AMT_HKE;
	APPL_RISK_WEIGHT		=ORIG_RISK_WEIGHT;
	COLL_ACCT_ID			=Collateral_Type;
	FLAG_ADJ				=9.4;

	MAT_DT					= MAT_DATE;
	VALUE_DT				= VALUEDATE;

	if substr(PORT_CD,1,1)="B" then do;
		if CCF=. then CCF=1;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*CCF*APPL_RISK_WEIGHT/10000;
	end;
	else do;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
	end;

	if find(PORTCDRW,"_RP") then FLAG_ELIM_CONSOL=1;

	keep
	ENTITY
	APPL_CD
	ACCT_ID
	ORIG_PORT_CD
	PORT_CD
	
	MAT_DT
	VALUE_DT
	CURR_CD
	CUST_NAME
	COUNTRY_CD
	FAC_TYP
	CUR_BAL_ON
	UNPAID_INT_ACCR
	TOT_EXP_AMT_HKE

	APPL_RISK_WEIGHT
	ORIG_RISK_WEIGHT
	APPL_CRM_AMT_HKE
	ORIG_CRM_AMT_HKE
	RISK_WEIGHTED_AMT_HKE
	COLL_ACCT_ID
	FLAG_ADJ
	FLAG_ELIM_CONSOL
	FILE_SRC
	ISSUE_BANK_CUST_SEC_ID
	SHORT_TERM_CLAIM_IND
	;
run;

/* 
*Sense Checking;
proc sql;
	select port_cd, APPL_RISK_WEIGHT,flag_elim_consol, 
	sum(APPL_CRM_AMT_HKE) format comma30.2
	from stg.adj_sgp_sec_fix_loan_&st_Rptmth.
	group by port_cd, APPL_RISK_WEIGHT, flag_elim_consol;
quit;
proc sql;
	select orig_port_cd, orig_RISK_WEIGHT,
	sum(orig_CRM_AMT_HKE) format comma30.2
	from stg.adj_sgp_sec_fix_loan_&st_Rptmth.
	group by orig_port_cd, orig_RISK_WEIGHT;
quit;
*/
/* *********************************************************************** */
data stg.adj_sgp_mm_&st_Rptmth.;
	set siw.xls_basel_sgp_mm_os_&st_Rptmth.;
	where not missing(PORTCDRW);

	FILE_SRC				="SGP_MM";
	ENTITY					="SGP";
	APPL_CD					="MM";
	ACCT_ID					=DEALNO;
	ACCT_PROD				="MM";

	TRADE_DT				=TDATE;
	VALUE_DT				=VDATE;
	MAT_DT					=MDATE;
	
	TMP_URLINE				=find(PORTCDRW,"_");
	if TMP_URLINE > 0 then do;
		if upcase(substr(PORTCDRW,TMP_URLINE+1,1))="Y" then do;
			SHORT_TERM_CLAIM_IND	='Y';
			TMP_URLINE1				=find(PORTCDRW,"_",TMP_URLINE); 
			ORIG_PORT_CD 			=substr(PORTCDRW,1,TMP_URLINE1-1);
		end; 
		else do;
			ORIG_PORT_CD 			=substr(PORTCDRW,1,TMP_URLINE-1);
		end;
		TMP_RW=find(left(reverse(PORTCDRW)),"_");
		ORIG_RISK_WEIGHT=input(reverse(substr(left(reverse(PORTCDRW)),1,TMP_RW-1)),10.);
	end;
	if find(PORTCDRW,"_RP") then FLAG_ELIM_CONSOL=1;

	PORT_CD					=ORIG_PORT_CD;
	APPL_RISK_WEIGHT		=ORIG_RISK_WEIGHT;
	

	CURR_CD					=CCY;
	CUST_NAME				=CPNAME;
	COUNTRY_CD				="SG";
	FAC_TYP					="MONEY MARKET PLACING";
	CUR_BAL_ON				=PRINAMT;
	UNPAID_INT_ACCR			=ACCUREDINT;
	TOT_EXP_AMT_HKE			=TotalExpsouresinHKDEqv;
	ORIG_CRM_AMT_HKE		=TOT_EXP_AMT_HKE;
	APPL_CRM_AMT_HKE		=TOT_EXP_AMT_HKE;

	FLAG_ADJ				=9.3;

	if substr(PORT_CD,1,1)="B" then do;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*CCF*APPL_RISK_WEIGHT/10000;
	end;
	else do;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
	end;

	keep
	ENTITY
	APPL_CD
	ACCT_ID
	ACCT_PROD
	PORT_CD
	ORIG_PORT_CD
	APPL_RISK_WEIGHT
	ORIG_RISK_WEIGHT

	MAT_DT
	VALUE_DT
	TRADE_DT
	CURR_CD
	CUST_NAME
	COUNTRY_CD
	FAC_TYP
	CUR_BAL_ON
	UNPAID_INT_ACCR
	TOT_EXP_AMT_HKE
	ORIG_CRM_AMT_HKE
	APPL_CRM_AMT_HKE
	SHORT_TERM_CLAIM_IND
	RISK_WEIGHTED_AMT_HKE
	FLAG_ADJ
	FILE_SRC
	FLAG_ELIM_CONSOL
	ISSUE_BANK_CUST_SEC_ID
	;
run;
/*
proc sql;
	select port_cd, APPL_RISK_WEIGHT, 
	sum(APPL_CRM_AMT_HKE) format comma30.2
	from stg.adj_sgp_mm_&st_Rptmth.
	group by port_cd, APPL_RISK_WEIGHT;
quit;
*/
/* *********************************************************************** */
data stg.adj_sgp_imex_&st_Rptmth.;
	set siw.xls_basel_sgp_imex_os_&st_Rptmth.;
	where not missing(CARItemCode);

	FILE_SRC				="SGP_IMEX";
	ENTITY					="SGP";
	APPL_CD					="IMEX CORE";
	ACCT_ID					=DEAL_NO;
	ORIG_PORT_CD			=tranwrd(tranwrd(CARItemCode,"_RP",""),"_Y","");
	PORT_CD					=ORIG_PORT_CD;
	
	CURR_CD					=CURR;
	CUST_NAME				=CUSTOMER_NAME;
	COUNTRY_CD				=CUSTOMER_COUNTRY_CODE;
	FAC_TYP					="";
	CUR_BAL_ON				=OS_AMT_LOCAL_CCY;
	CUR_BAL_ON_HKE			=OS_AMT_HKE;
	UNPAID_INT_ACCR			=OS_INT_AMT_LOCAL_CCY;
	UNPAID_INT_ACCR_HKE		=OS_INT_AMT_LOCAL_HKE;
	TOT_EXP_AMT_HKE			=sum(CUR_BAL_ON_HKE,UNPAID_INT_ACCR_HKE);

	if missing(APPL_CRM_AMT_HKE) then APPL_CRM_AMT_HKE=TOT_EXP_AMT_HKE;
	ORIG_CRM_AMT_HKE		=APPL_CRM_AMT_HKE;
	ORIG_RISK_WEIGHT		=RISKWEIGHT;
	APPL_RISK_WEIGHT		=RISKWEIGHT;
	FLAG_ADJ				=9.2;
	if find(CARItemCode,"_RP") then FLAG_ELIM_CONSOL=1;

	if substr(PORT_CD,1,1)="B" then do;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*CCF*APPL_RISK_WEIGHT/10000;
	end;
	else do;
		RISK_WEIGHTED_AMT_HKE	=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
	end;

	ISSD_DT	= STARTDATE;
	MAT_DT 	= max(ENDDATE,DUE_DATE);

	keep
	CCF
	SHORT_TERM_CLAIM_IND
	ENTITY
	APPL_CD
	ACCT_ID
	ORIG_PORT_CD
	PORT_CD
	
	
	MAT_DT
	ISSD_DT
	CURR_CD
	CUST_NAME
	COUNTRY_CD
	FAC_TYP
	CUR_BAL_ON
	CUR_BAL_ON_HKE
	UNPAID_INT_ACCR
	UNPAID_INT_ACCR_HKE
	TOT_EXP_AMT_HKE

	APPL_RISK_WEIGHT
	ORIG_RISK_WEIGHT
	APPL_CRM_AMT_HKE
	ORIG_CRM_AMT_HKE
	RISK_WEIGHTED_AMT_HKE
	FLAG_ADJ
	FLAG_ELIM_CONSOL
	FILE_SRC
	ISSUE_BANK_CUST_SEC_ID
	;
run;

/* 
*Sense Checking;
proc sql;
	select port_cd, APPL_RISK_WEIGHT,flag_elim_consol, 
	sum(APPL_CRM_AMT_HKE) format comma30.2
	from stg.adj_sgp_imex_&st_Rptmth.
	group by port_cd, APPL_RISK_WEIGHT, flag_elim_consol;
quit;
proc sql;
	select orig_port_cd, orig_RISK_WEIGHT,flag_elim_consol, 
	sum(orig_CRM_AMT_HKE) format comma30.2
	from stg.adj_sgp_imex_&st_Rptmth.
	group by orig_port_cd, orig_RISK_WEIGHT, flag_elim_consol;
quit;
*/

