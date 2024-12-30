data PBG(rename=(CUSTOMER_NAME=CUST_NAME));
	set stg.ru_pbg_exp_&st_RptMth.(keep=
		ACCT_ID 
		CUST_SEC_ID
		CUSTOMER_NAME
		BU_GROUP
		IAS_PROD
		BUS_UNIT
		LOAN_CLASS_CD
		PRIN_HKE
		CR_RT
		DAYS_PASTDUE
		DELQ_BUCKET
		CA_AMT_HKE
		DSR
		DAYS_PASTDUE
		DELQ_BUCKET
		FLAG:
	);
	FLAG_SRC="PBG";
run;

data NONPBG;
	set stg.ru_nonpbg_exp_&st_RptMth.(keep=
		ACCT_ID 
		CUST_SEC_ID
		CUST_NAME
		BU_GROUP
		BU_NPL
		BU_RU
		LOAN_CLASS_CD
		PRIN_HKE
	);
	FLAG_SRC="NONPBG";
run;
data RU_NONBANK_EXP;
	length CUST_NAME $100 LOAN_CLASS_CD $100 FLAG_SRC $10;
	set PBG(in=pbg) NONPBG(in=nonpbg);
run;
proc sort data=RU_NONBANK_EXP nodupkey; by ACCT_ID; run;

data FACT.RU_NONBANK_EXP_&st_Rptmth.;
	merge RU_NONBANK_EXP (in=a) stg.vi_iambs_alc_dtl_sum_&st_RptMth.(in=b);
	by ACCT_ID;
	if a ;
	if missing(trim(LOAN_CLASS_CD)) then LOAN_CLASS_CD="PA";
	if LOAN_CLASS_CD in ('SS','LS','DF','LL') then CLASSIFIED=1; else CLASSIFIED=0;
run;

/*
data check1;
	set RU_NONBANK_EXP_with_TD;
	if FLAG_ALC=1 and FLAG_RU ne 1;
run;

proc sort data=RBG nodupkey; by ACCT_ID; run;
proc sort data=NONPBG nodupkey; by ACCT_ID;run;
*/
