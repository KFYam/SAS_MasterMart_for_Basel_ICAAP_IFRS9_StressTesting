
data stg.adj_derv_delta_&st_Rptmth.(keep= 
	FLAG_ADJ PORT_CD EXP_REF ENTITY FILE_SRC CUST_NAME 
	CUR_BAL_OFF_HKE CUR_EXP_AMT_HKE POTENT_EXP_AMT_HKE 
	ORIG_CRM_AMT_HKE APPL_CRM_AMT_HKE  RISK_WEIGHTED_AMT_HKE FAC_TYP
	);
	length PORTCD_COMBINED PORTCD_CONSOLID PORT_CD FILE_SRC ENTITY CUST_NAME EXP_REF $30;
	retain PORTCD_COMBINED PORTCD_CONSOLID;
	set stg.x_deriv_&st_Rptmth. (firstobs=10);

	if not missing(A) then PORTCD_COMBINED=A; 
	if not missing(J) then PORTCD_CONSOLID=J;
	if missing(A) then A=PORTCD_COMBINED;
	if missing(J) then J=PORTCD_CONSOLID;

 	if substr(A,1,1) ne "B" then do;
		PORT_CD=cats("B",substr(A,1,2));
		if substr(A,3,1)="a" then EXP_REF="1 YEAR";
		if substr(A,3,1)="b" then EXP_REF="5 YEARS";
		if substr(A,3,1)="c" then EXP_REF="OVER 5YR";
	end;
	else do;
		PORT_CD=substr(A,1,3);
		EXP_REF=substr(A,5);
	end;
	FLAG_ADJ=300.1;
	ENTITY="OVERSEA";
	FILE_SRC="COMBINED-DERV";
	CUST_NAME=B;
	CUR_BAL_OFF_HKE=input(C,comma32.)*1000;
	CUR_EXP_AMT_HKE=input(D,comma32.)*1000;
	POTENT_EXP_AMT_HKE=input(E,comma32.)*1000;
	ORIG_PORT_CD=PORT_CD;
	ORIG_CRM_AMT_HKE=sum(CUR_EXP_AMT_HKE,POTENT_EXP_AMT_HKE);
	APPL_CRM_AMT_HKE=ORIG_CRM_AMT_HKE;
	RISK_WEIGHTED_AMT_HKE=input(F,comma32.)*1000;
	FAC_TYP=G;
	if EXP_REF ="5 YEAR" then EXP_REF="5 YEARS";
	/* cater B18 case */
	if PORT_CD="B18" then do;
		CUR_BAL_OFF_HKE=input(D,comma32.)*1000;
		CUR_EXP_AMT_HKE=0;
		POTENT_EXP_AMT_HKE=0;
		ORIG_CRM_AMT_HKE=input(E,comma32.)*1000;
		APPL_CRM_AMT_HKE=ORIG_CRM_AMT_HKE;
		RISK_WEIGHTED_AMT_HKE=input(F,comma32.)*1000;
	end;
	if not missing(CUST_NAME) then OUTPUT;


 	if substr(J,1,1) ne "B" then do;
		PORT_CD=cats("B",substr(J,1,2));
		if substr(J,3,1)="a" then EXP_REF="1 YEAR";
		if substr(J,3,1)="b" then EXP_REF="5 YEARS";
		if substr(J,3,1)="c" then EXP_REF="OVER 5YR";
	end;
	else do;
		PORT_CD=substr(J,1,3);
		EXP_REF=substr(J,5);
	end;
	FLAG_ADJ=300.2;
	ENTITY="CBIC";
	FILE_SRC="CONSOLID-DERV";
	CUST_NAME=K;
	CUR_BAL_OFF_HKE=input(L,comma32.)*1000;
	CUR_EXP_AMT_HKE=input(M,comma32.)*1000;
	POTENT_EXP_AMT_HKE=input(N,comma32.)*1000;
	ORIG_PORT_CD=PORT_CD;
	ORIG_CRM_AMT_HKE=sum(CUR_EXP_AMT_HKE,POTENT_EXP_AMT_HKE);
	APPL_CRM_AMT_HKE=ORIG_CRM_AMT_HKE;
	RISK_WEIGHTED_AMT_HKE=input(O,comma32.)*1000;
	FAC_TYP="";
	if EXP_REF ="5 YEAR" then EXP_REF="5 YEARS";
	/* cater B18 case */
	if PORT_CD="B18" then do;
		CUR_BAL_OFF_HKE=input(M,comma32.)*1000;
		CUR_EXP_AMT_HKE=0;
		POTENT_EXP_AMT_HKE=0;
		ORIG_CRM_AMT_HKE=input(N,comma32.)*1000;
		APPL_CRM_AMT_HKE=ORIG_CRM_AMT_HKE;
		RISK_WEIGHTED_AMT_HKE=input(O,comma32.)*1000;
	end;
	if not missing(CUST_NAME) then OUTPUT;
run;
proc sort data=stg.adj_derv_delta_&st_Rptmth.; 
	by FILE_SRC PORT_CD EXP_REF; 
run;

