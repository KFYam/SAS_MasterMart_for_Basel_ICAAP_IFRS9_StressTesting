/* ***************************************************************************************** */
/* Step 1: Using stress testing FACT table (after CRM) to prepare pre-CRM FACT table		 */
/* ***************************************************************************************** */
data 	b4_crm_onbal
		b4_crm_offbal
		b4_crm_derv
		b4_crm_onbal_manual
		b4_crm_offbal_manual
		b4_crm_derv_manual
		b4_crm_onbal_ix
		b4_crm_offbal_ix
		b4_crm_derv_ix
		;
	set fact.st_crm_rwa_fact_&st_RptMth. (
		where=(FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=.)
	);

 	if substr(left(PORT_CD),1,1) ne "B" then do;
		if missing(AS_OF_DT) then 		output b4_crm_onbal_manual;
		/* Due to mortgage loan is by facility level for recording MIP/HOS portion. No need for de-duplicating the record. */
		else if ORIG_PORT_CD="IX" then 	output b4_crm_onbal_ix; 
		else							output b4_crm_onbal;
	end;
	else if PORT_CD in ('B1' 'B2' 'B3' 'B4' 'B5' 'B6' 'B7' 'B8' 'B9a' 'B9b' 'B9c' 'B9d') then do;
		if missing(AS_OF_DT) then 		output b4_crm_offbal_manual;
		else if ORIG_PORT_CD="IX" then 	output b4_crm_offbal_ix; 
		else 							output b4_crm_offbal;
	end;
	else do; 
		if missing(AS_OF_DT) then 		output b4_crm_derv_manual;
		else if ORIG_PORT_CD="IX" then 	output b4_crm_derv_ix; 
		else 							output b4_crm_derv;
	end;
run;
proc sort data=b4_crm_onbal	out=b4_crm_onbal_v1 	nodupkey; by ACCT_ID ORIG_PORT_CD; run; 
proc sort data=b4_crm_offbal	out=b4_crm_offbal_v1 	nodupkey; by ACCT_ID ORIG_PORT_CD; run; 
proc sort data=b4_crm_derv		out=b4_crm_derv_v1 		nodupkey; by ACCT_ID ORIG_PORT_CD; run; 

data stg.b4crm_onbal_&st_Rptmth.;
	length FLAGBIS $20;
	set b4_crm_onbal_v1 	(in=a1)
		b4_crm_onbal_manual (in=b1)
		b4_crm_onbal_ix		(in=c1)
		;
	if a1 then FLAGBIS="ON_SYSTEM";	
	if b1 then FLAGBIS="ON_MANUAL";
	if c1 then FLAGBIS="ON_IX";
run;
data stg.b4crm_offbal_&st_Rptmth.;
	length FLAGBIS $20;
	set b4_crm_offbal_v1 		(in=a2)
		b4_crm_offbal_manual 	(in=b2)
		b4_crm_offbal_ix		(in=c2)
		;
	if a2 then FLAGBIS="OFF_SYSTEM";	
	if b2 then FLAGBIS="OFF_MANUAL";
	if c2 then FLAGBIS="OFF_IX";
run;
data stg.b4crm_derv_&st_Rptmth.;
	length FLAGBIS $20;
	set b4_crm_derv_v1 			(in=a3)
		b4_crm_derv_manual 		(in=b3)
		b4_crm_derv_ix			(in=c3)
		;
	if a3 then FLAGBIS="DERV_SYSTEM";	
	if b3 then FLAGBIS="DERV_MANUAL";
	if c3 then FLAGBIS="DERV_IX";
run;

data stg.b4crm_overall_&st_Rptmth.;
	set stg.b4crm_onbal_&st_Rptmth.
		stg.b4crm_offbal_&st_Rptmth.
		stg.b4crm_derv_&st_Rptmth. 
	;
	if FLAGBIS in ("ON_SYSTEM" "ON_IX" "ON_MANUAL") 	then BIS_CRM_AMT_HKE=ORIG_CRM_AMT_HKE;
	if FLAGBIS in ("OFF_SYSTEM" "OFF_IX" "OFF_MANUAL")	then BIS_CRM_AMT_HKE=ORIG_CRM_AMT_HKE*CCF/100;
run;
proc sort data=stg.b4crm_overall_&st_Rptmth.; by ACCT_ID ORIG_PORT_CD; run;



/* ***************************************************************************************** */
/* Step 2: Get the corresponding Issue Date and Maturity Date from AC_EXP tables			 */
/* ***************************************************************************************** */
data ac_exp_consolid;
	set siw.vi_iambs_kw_ac_exp_&st_Rptmth.(rename=(ISSD_DT=ISSD_DTIME MAT_DT=MAT_DTIME))
		siw.vi_iambs_vc_ac_exp_&st_Rptmth.(rename=(ISSD_DT=ISSD_DTIME MAT_DT=MAT_DTIME))
		siw.vi_iambs_sz_ac_exp_&st_Rptmth.(rename=(					  MAT_DT=MAT_DTIME))
		siw.vi_iambs_cf_ac_exp_&st_Rptmth.(rename=(ISSD_DT=ISSD_DTIME MAT_DT=MAT_DTIME))
	;
	ISSD_DT=datepart(ISSD_DTIME);
	MAT_DT=datepart(MAT_DTIME);
	format ISSD_DT MAT_DT date9.;
	drop ISSD_DTIME MAT_DTIME;
run;
proc sort 
	data=ac_exp_consolid 
	out=ac_exp_consolid_v1(keep=ACCT_ID PORT_CD ISSD_DT MAT_DT CONT_TENOR RMN_TENOR rename=(PORT_CD=ORIG_PORT_CD)) 
	nodupkey; 
	by ACCT_ID PORT_CD;
run;



/* ***************************************************************************************** */
/* Step 3: Get the Maturity Date from Fac_Line table when abnormal maturity existed			 */
/* ***************************************************************************************** */

proc sort 
	data=siw.vi_iamkr_fac_line_&st_Rptmth. 
	out=fact_lin(keep=FAC_REF MAT_DT rename=(MAT_DT=FAC_MAT_DTIME) ) nodupkey; 
	by FAC_REF;
	where FAC_REF ne "##########" and not missing(MAT_DT) and year(datepart(MAT_DT)) ne 9999 and year(datepart(MAT_DT)) > 1960;
run;

/* ***************************************************************************************** */
/* Step 4: Get the Expiry Date from RBG base for CardLink Products							 */
/* ***************************************************************************************** */
proc sort 
	data=pbg.rbg_base_&st_RptYYMM. 
	out=rbg_base(keep=ACCT_ID MAT_DT rename=(ACCT_ID=PROD_SYS_REF MAT_DT=CARD_MAT_DT)) nodupkey; 
	by ACCT_ID ;
	where not missing(MAT_DT);
run;



/* ***************************************************************************************** */
/* Step 4: Combined all the information together											 */
/* ***************************************************************************************** */
proc sort data=stg.b4crm_overall_&st_Rptmth. out=b4crm_overall_v1(rename=(MAT_DT=SGP_MAT_DT)); by FAC_REF; run;
data stg.b4crm_overall_&st_Rptmth._v1;
	merge b4crm_overall_v1(in=a) fact_lin(in=b);
	by FAC_REF;
	if a;
	FAC_MAT_DT=datepart(FAC_MAT_DTIME);
	format FAC_MAT_DT date9.;
	drop FAC_MAT_DTIME;
run;

proc sort data=stg.b4crm_overall_&st_Rptmth._v1 out=b4crm_overall_v2; by PROD_SYS_REF; run;
data stg.b4crm_overall_&st_Rptmth._v2;
	merge b4crm_overall_v2(in=a) rbg_base(in=b);
	by PROD_SYS_REF;
	if a;
run;


proc format;
value $cq
"AAA","AA+","AA","AA-"	="IG" /* investment grade */
"A+","A","A-" 			="IG"
"BBB+","BBB"			="IG"
"BBB-"					="IG"
other					="HY & NR" /* High Yield and Non-Rated */
;
run;
proc format;
value resid
0-<1 		= "a. < 1 year"
1-<5 		= "b. >= 1 year to 5 years"
5-<10 		= "c. >= 5 years to 10 years"
10-<20 		= "d. >= 10 years to 20 years"
20-high 	= "e. >= 20 years"
;
run;


proc sort data=stg.b4crm_overall_&st_Rptmth._v2; by ACCT_ID ORIG_PORT_CD; run;
data fact.bis_b4crm_overall_&st_Rptmth.;

	length BIS_SECTOR_TYP BIS_CQ  $50; 

	merge 	stg.b4crm_overall_&st_Rptmth._v2(in=a)
			ac_exp_consolid_v1 (in=b);
	by ACCT_ID ORIG_PORT_CD;
	if a;

	FINAL_MAT_DT=max(MAT_DT, FAC_MAT_DT, SGP_MAT_DT, CARD_MAT_DT);
	if 		FINAL_MAT_DT= MAT_DT 		then FLAGMATDT=1;
	else if FINAL_MAT_DT= FAC_MAT_DT 	then FLAGMATDT=2;
	else if FINAL_MAT_DT= SGP_MAT_DT 	then FLAGMATDT=3;
	else if FINAL_MAT_DT= CARD_MAT_DT 	then FLAGMATDT=4;

	format FINAL_MAT_DT date9.;
	/* **************************************************************** */
	/* LOGIC: Apply for Credit Quality Mapping							*/
	/* **************************************************************** */
	BIS_CQ = put(ECAI_Rating, $cq.);

	/* **************************************************************** */
	/* LOGIC: Apply for Sector Mapping 									*/
	/* **************************************************************** */
	if ORIG_PORT_CD in ("Ia" "Ib" "Ic") and CUST_SUB_TYP_CD not in ("31" "32" "33") /* Central Bank*/ then do;
		BIS_SECTOR_TYP="1. SOVEREIGNS";
	end;
	else if ORIG_PORT_CD in ("IV" /*Bank*/ "V" /*FI*/)  or CUST_SUB_TYP_CD in ("31" "32" "33") then do;
		BIS_SECTOR_TYP="2. FINANCIALS (includes Central Banks)";
	end;
	else if not missing(FAC_USAGE_CD) then do;
		if 		FAC_USAGE_CD in ("1010" "1020") then BIS_SECTOR_TYP="3. Basic materials, energy industrials";
		else if FAC_USAGE_CD in ("1030") 		then BIS_SECTOR_TYP="4. Consumer";
		else if FAC_USAGE_CD in ("1040" "1050") then BIS_SECTOR_TYP="3. Basic materials, energy industrials";
		else if FAC_USAGE_CD in ("4011") 		then BIS_SECTOR_TYP="5. Technology, Telecom";
		else if FAC_USAGE_CD in ("1070") 		then BIS_SECTOR_TYP="3. Basic materials, energy industrials";
   		else if FAC_USAGE_CD in ("1080" "1090") then BIS_SECTOR_TYP="4. Consumer";
		else if FAC_USAGE_CD in ("1100", "1110", "1060") then BIS_SECTOR_TYP="3. Basic materials, energy industrials";

		else if FAC_USAGE_CD in ("5100") 		then BIS_SECTOR_TYP="3. Basic materials, energy industrials";	
		else if FAC_USAGE_CD in ("5110" "5120" "5130") then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("5000") 		then BIS_SECTOR_TYP="3. Basic materials, energy industrials";
		else if FAC_USAGE_CD in ("5010" "5020" "5030") then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("5010" "5020" "5030") then BIS_SECTOR_TYP="7. Other";

		else if FAC_USAGE_CD in ("5500") 		then BIS_SECTOR_TYP="6. Health care, UTIL, Local Gov, Gov-Backed Corp";
		else if FAC_USAGE_CD in ("4000" "4020") then BIS_SECTOR_TYP="6. Health care, UTIL, Local Gov, Gov-Backed Corp";

		else if FAC_USAGE_CD in ("4030") 		then BIS_SECTOR_TYP="4. Consumer";
		else if FAC_USAGE_CD in ("4010" "4012") then BIS_SECTOR_TYP="5. Technology, Telecom";
		else if 6010<= input(FAC_USAGE_CD,4.) <=6033 then BIS_SECTOR_TYP="7. Other";

		else if FAC_USAGE_CD in ("3000" "3012" "3010" "3011" "3020" "3030" "8552") then BIS_SECTOR_TYP="6. Health care, UTIL, Local Gov, Gov-Backed Corp";

		else if FAC_USAGE_CD in ("8010")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8020")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8021")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8022")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8023")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8030")		then BIS_SECTOR_TYP="7. Other";
 		else if FAC_USAGE_CD in ("8031")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8040")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8041")		then BIS_SECTOR_TYP="7. Other";
 		else if FAC_USAGE_CD in ("8510")		then BIS_SECTOR_TYP="7. Other";
 		else if FAC_USAGE_CD in ("8520" "8560")	then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8530")		then BIS_SECTOR_TYP="7. Other";
		else if FAC_USAGE_CD in ("8540")		then BIS_SECTOR_TYP="7. Other";
 		else if FAC_USAGE_CD in ("8550" "8551")	then BIS_SECTOR_TYP="7. Other";

		else if FAC_USAGE_CD in ("2010" "2020" "2030" "7000" "8710") then BIS_SECTOR_TYP="7. Other";
		else BIS_SECTOR_TYP="7. Other";
	end;
	else do;
		BIS_SECTOR_TYP="7. Other";
	end;	
	/* **************************************************************** */
	/* LOGIC: Apply for Residual Maturity								*/
	/* **************************************************************** */

	/* Step 1 - Nornmal Case (i.e. Maturity Date >= Reporting Date					 */
	/* ----------------------------------------------------------------------------- */
	
	if FINAL_MAT_DT >= &dt_Rptmth. then do; 
		BIS_RES_MAT_YEAR = sum(FINAL_MAT_DT, -&dt_Rptmth.)/365;
		FLAG_RESIDMAT=1.0;

		if substr(APPL_CD,1,6)="NOSTRO" or PROD_SYS_CD ="NOSTRO" or 
			FAC_TYP="NOSTRO" or left(trim(CUST_SEC_ID)) = "NOS CBI CHINA" then do;
				FLAG_RESIDMAT=2.1;
				BIS_RES_MAT_YEAR =0;
		end;
	end;

	/* Step 2 - Nornmal Case (i.e. Maturity Date < Reporting Date or Maturity Date=. */
	/* ----------------------------------------------------------------------------- */
	else do;
		/* 2.0) For the maturity date has same Month Year with Reporting Month, then residual maturity would be 0 */
		if put(FINAL_MAT_DT,yymmn4.) = "&st_Rptmth." then do;
			FLAG_RESIDMAT=2.0;
			BIS_RES_MAT_YEAR = 0;
		end;
		/* 2.1) For Nostro Case - should be within 1 year, assuming that most of the cases that short-term		*/
		if substr(APPL_CD,1,6)="NOSTRO" or PROD_SYS_CD ="NOSTRO" or 
			FAC_TYP="NOSTRO" or left(trim(CUST_SEC_ID)) = "NOS CBI CHINA" then do;
				FLAG_RESIDMAT=2.1;
				BIS_RES_MAT_YEAR =0;
		end;
		/* 2.2) For Odd Dollar - although maturity date exists (because line is granted) but 					*/
		/*      the amount would likely not be collected or aged and everlasting remained in system. Usually	*/ 
		/*		the remaining dollar is very small such as less than HKD50 based on Winston's opinion.			*/
/*		else if not missing(FINAL_MAT_DT) and BIS_CRM_AMT_HKE <=50 then do;*/
		else if not missing(FINAL_MAT_DT) and year(FINAL_MAT_DT) ne 1900 and 0<BIS_CRM_AMT_HKE <=50 then do;
			FLAG_RESIDMAT=2.2;
			BIS_RES_MAT_YEAR = 20; /* >= 20 years */
		end;
		/* 2.3) For Temp.OD - Missing maturity date in TOD is usually these accounts have no line. One of the 	*/
		/*      typical case is admin. fee for cheque rebounding, and the admin fee would likely not be higher  */
		/*		HKD500. Therefore, the residual maturity is set as <1 year and it is supposed the payment on 	*/
		/*		demand																							*/
		else if missing(FINAL_MAT_DT) and 0<BIS_CRM_AMT_HKE <=500 then do;
			FLAG_RESIDMAT=2.3;
			BIS_RES_MAT_YEAR = 0;
		end;
		 
		/* 2.4) For Original Port CD = X19d - Plant & equipment, other fixed assets for own use. We set the 	*/
		/*		residual maturity >=20. As Stella Wong said, Port Code of X19d of which the residual maturity 	*/
		/*		should be classified according to the depreication of the nature of the fixed assets. 			*/
		else if missing(FINAL_MAT_DT) and ORIG_PORT_CD = "X19d" then do;
			FLAG_RESIDMAT=2.4;
			BIS_RES_MAT_YEAR = 20;
		end;

		/* 2.5) For Others cases - it is assumed that payment on demand in this kind of the case 				*/
		/*      e.g.1)  As clarified by Emily Sio, from Financial Management & Treasury, L/C are but not loans, */
		/*				they actually have no maturity date, what we put here are only the maturity date of the */
		/*				L/C themselves.																			*/
		/*      e.g.2)  For the last item which is a bank guarantee, according to our Bills Dept, it is only 	*/
		/*				the internal maturity date, there is in fact no maturity date for this guarantee.		*/
		else do;
			FLAG_RESIDMAT=2.5;
			BIS_RES_MAT_YEAR = 0;
		end;
	end;
run;






