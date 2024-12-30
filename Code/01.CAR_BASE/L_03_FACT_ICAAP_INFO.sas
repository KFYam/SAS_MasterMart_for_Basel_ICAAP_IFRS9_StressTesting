
data ST_CRM_RWA_FACT1_&st_Rptmth.;
	set ST_CRM_RWA_FACT_&st_Rptmth.;
	SEQ = _N_;
	length IND_BASEL_ASSET_CLASS IND_BUS_UNIT $20;

	/* ************************************************************************************************ */
	/* Basel II Asset Class Allocation																	*/
	/* ************************************************************************************************ */
	if put(port_cd,$portcd.) ne "99. ###" then do;
		IND_BASEL_ASSET_CLASS=port_cd;
	end;
	if put(port_cd,$portcd.) eq "99. ###" then do;
		if 		ICAAP_COLL_TYP = "Bank Guarantee" 		then IND_BASEL_ASSET_CLASS="IV";
		else if ICAAP_COLL_TYP = "Cash" 				then IND_BASEL_ASSET_CLASS="VIII";
		else if ICAAP_COLL_TYP = "Government Guarantee" then IND_BASEL_ASSET_CLASS="Ia";
		else if ICAAP_CNTR_TYP = "Bank"					then IND_BASEL_ASSET_CLASS="IV";
		else if ICAAP_CNTR_TYP = "PSE"					then IND_BASEL_ASSET_CLASS="II4";
		else if ICAAP_CNTR_TYP = "Retail SB"			then IND_BASEL_ASSET_CLASS="VIIIb";
		else if ICAAP_CNTR_TYP = "Individual"			then IND_BASEL_ASSET_CLASS="VIIIa";
		else if ICAAP_CNTR_TYP = "Corporate"			then IND_BASEL_ASSET_CLASS="VI"; /*fine tune: if icaap_bus_unit="RBG" , reassign to Retail SB ; consider CCF*/
		else if ICAAP_CNTR_TYP = "Dummy" then do;
			if 		ICAAP_PROD_CD = "Global Line"			then IND_BASEL_ASSET_CLASS="X19e";
			else if ICAAP_PROD_CD = "Credit Card Undrawn"	then IND_BASEL_ASSET_CLASS="VIIIa";
			else if PROD_SYS_CD = "USER UPLOAD" and APPL_RISK_WEIGHT < 100	then IND_BASEL_ASSET_CLASS="VIIIb";
			else if PROD_SYS_CD = "USER UPLOAD" and APPL_RISK_WEIGHT = 100	then IND_BASEL_ASSET_CLASS="VI";
			else IND_BASEL_ASSET_CLASS="VI";
		end;
		else if ENTITY in ("CBI China" "SGP") then do;
			if 		APPL_RISK_WEIGHT < 100	then IND_BASEL_ASSET_CLASS="VIIIb";
			else if APPL_RISK_WEIGHT = 100	then IND_BASEL_ASSET_CLASS="VI";
		end;
		else if ICAAP_CNTR_TYP = "Stockbrokers"			then IND_BASEL_ASSET_CLASS="V";
		else if APPL_CD="CREDIT CARD" then IND_BASEL_ASSET_CLASS="VIIIa";
		else IND_BASEL_ASSET_CLASS="X19e";
	end;

	/* ************************************************************************************************ */
	/* Business Unit Allocation																			*/
	/* ************************************************************************************************ */
	if not missing (ICAAP_BUS_UNIT) then do;
		IND_BUS_UNIT = ICAAP_BUS_UNIT;
		if APPLIC_CD="OV"									then IND_BUS_UNIT = "IBG";
		if ICAAP_TEAM_DESC = "Business Banking"				then IND_BUS_UNIT = "RBG-BB";
		if put(port_cd,$portcd.) eq "99. ###" and 
			ICAAP_CNTR_TYP = "Retail SB"					then IND_BUS_UNIT = "RBG-BB";
		/* Added on Mar 2014 for finding the underlying BU of the pastdue accounts */
		if ICAAP_BUS_UNIT="RAM" then do;
			if ICAAP_CNTR_TYP="Corporate" 					then IND_BUS_UNIT = "CBG";
			if ICAAP_CNTR_TYP = "Retail SB"					then IND_BUS_UNIT = "RBG-BB";
		end;
	end;
	else if missing (ICAAP_BUS_UNIT) then do;
		if 		ENTITY = "CBI China"						then IND_BUS_UNIT = "CBIC";
		else if ENTITY = "SGP"								then IND_BUS_UNIT = "IBG-SGP";
		else if APPLIC_CD="OV"								then IND_BUS_UNIT = "IBG"; /* exclude SGP*/
		else if APPL_CD="CREDIT CARD" 						then IND_BUS_UNIT = "RBG";

		else if missing(PROD_SYS_CD) and missing(ACCT_ID) 	then IND_BUS_UNIT = "CONSOL ADJ";
		else if CUST_BK_GROUP = "1"							then IND_BUS_UNIT = "RBG";
		else IND_BUS_UNIT = "CBG"; /* need to further fine tuned*/
	end;	  
	/* Overriding Logic */
	if ENTITY="HKCBF"								then IND_BUS_UNIT = "SCBF";
	if put(port_cd,$portcd.) eq "14. Derivative" 	then IND_BUS_UNIT = "CTU";
	if IND_REF_FROM_BU=1 							then IND_BUS_UNIT = "WBG-REF";

run;

/* ************************************************************************************************ */
/* Added on Jan 2015																				*/
/* ************************************************************************************************ */
/* Due to RST calculation, Exposure before CRM need to be used as well, however, Exposure before 	*/
/* CRM is Orig Port Code Level that means it would be duplicated on some transactions. As this is	*/
/* not friendly when summing up, allocation would be applied on HK, VC, SGP, CBIC and HKCBF only.	*/
/* ************************************************************************************************ */

/* ACCT_ID cannot be the 1st item of the key because PBG is down to facility level and a pair of	*/
/* ACCT_ID with diff ORIG_PORT_CD exist, it would be common on Credit Card segment.					*/
/* so ORIG_PORT_CD should be the 1st item of the key.												*/
/* Besides, it is found RML case would be same Orig_PORT_CD with diff Port CD and different 		*/
/* Orig_CRM_AMT_HKE,  */
PROC SORT 
	DATA=ST_CRM_RWA_FACT1_&st_Rptmth. 
	out=CLEAN_FACT;
	where 
		(FILE_SRC in ("CNCBI_VC" "CBIC" "HKCBF") or substr(FILE_SRC,1,3)="SGP")and 
		FLAG_DELETE=. and 
		not missing(ACCT_ID)
		;
	by ORIG_PORT_CD ACCT_ID ORIG_CRM_AMT_HKE PORT_CD;
RUN;
/* Check out which are the duplicated records */
data CLEAN_FACT_KEY;
	set CLEAN_FACT;
	by ORIG_PORT_CD ACCT_ID ORIG_CRM_AMT_HKE ;
	if FIRST.ORIG_CRM_AMT_HKE*LAST.ORIG_CRM_AMT_HKE=0;
	keep ORIG_PORT_CD ACCT_ID ORIG_CRM_AMT_HKE PORT_CD APPL_CRM_AMT_HKE SEQ;
run;
/* Allocated the ORIG_CRM_AMT_HKE into every transactions */
proc sql noprint;
	create table CRM_ALLOCATE as 
	select
		ORIG_PORT_CD,
		ACCT_ID, 
		ORIG_CRM_AMT_HKE,
		count(PORT_CD) as CRM_CNT
	from CLEAN_FACT_KEY
	group by ORIG_PORT_CD, ACCT_ID, ORIG_CRM_AMT_HKE 
	order by ORIG_PORT_CD, ACCT_ID, ORIG_CRM_AMT_HKE;
quit;

/* Added Back the CRM_Allocation Count into FACT table */
PROC SORT DATA=ST_CRM_RWA_FACT1_&st_Rptmth.;
	by ORIG_PORT_CD ACCT_ID ORIG_CRM_AMT_HKE PORT_CD;
RUN;
data FACT.ST_CRM_RWA_FACT_&st_Rptmth.;
	merge ST_CRM_RWA_FACT1_&st_Rptmth.(in=a) CRM_ALLOCATE(in=b);
	by ORIG_PORT_CD ACCT_ID ORIG_CRM_AMT_HKE ;
	if a;
	if not missing(CRM_CNT) then do;
		ORIG_CRM_AMT_HKE_TRN=ORIG_CRM_AMT_HKE/CRM_CNT;
	end;
	else do;
		ORIG_CRM_AMT_HKE_TRN=ORIG_CRM_AMT_HKE;
	end;

	/* Added on 24 Jan 2015 - To Find out the Debt Securities */
	if FILE_SRC ne "CBIC" then do;
		if substr(ICAAP_PROD_CD,1,3) = "AFS" then IND_AFS=1;
	end;
	else do;
		if FAC_TYP="SECUR|FI" then IND_AFS=1; 
	end;

run;



/* For Checking only
proc format;   
   picture bigmoney (fuzz=0)
      low-high='000,000,009' (mult=.000001)
	;
run;

proc freq data=revised_fact order=formatted;
	table IND_BASEL_ASSET_CLASS*IND_BUS_UNIT  / FORMAT=bigmoney. missing ;
	format IND_BASEL_ASSET_CLASS $portcd. IND_BUS_UNIT $busunit. ;
	weight risk_weighted_amt_hke;  

	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = .
	;
run;

data check;
	set revised_fact;
	format IND_BASEL_ASSET_CLASS $portcd. IND_BUS_UNIT $busunit. ;
	where ind_bus_unit="WBG-REF";
run;
*/
