/* "IW" is KW + VC only; it base on the sheet [Adj_Data] of BASEL worksheet for RWA Report_yyyymmdd.xls */
/* where adjustment numbers are also based on the number mentioned in [Adj_Data] 						*/
/* ==================================================================================================== */ 

%ErrAdj(err_tbl=siw.XLS_ST_MANUAL_MASTER_&st_rptmth.,tbl=KW_VC,mode=U);

data stg.car_iw_adj_&st_Rptmth.;
	set 
	stg.vi_iambs_kw_car_&st_RptMth.
	stg.vi_iambs_vc_car_&st_RptMth.
	;
	length FILE_SRC $30; 
	FILE_SRC					="CNCBI_VC";
	FLAG_ELIM_CONSOL			=.;
	FLAG_ELIM_COMBIN			=.;

	ORIG_PORT_CD_IW				=ORIG_PORT_CD;
	PORT_CD_IW					=PORT_CD;
	SHORT_TERM_CLAIM_IND_IW		=SHORT_TERM_CLAIM_IND;
	APPL_CRM_AMT_HKE_IW			=APPL_CRM_AMT_HKE;
	APPL_RISK_WEIGHT_IW			=APPL_RISK_WEIGHT;
	ORIG_RISK_WEIGHT_IW			=ORIG_RISK_WEIGHT;
	RISK_WEIGHTED_AMT_HKE_IW	=RISK_WEIGHTED_AMT_HKE;
	/* -------------------------------------------------------------------- */
	/* Added on 21 Jul 2014 												*/
	/* Adj 3.0001 - SHORT_TERM_CLAIM_IND = Y for PORT_CD=VI					*/
	/* -------------------------------------------------------------------- */
	if APPL_CD in("NY LOAN" "LA LOAN" "MC LOAN") and PORT_CD in ("DUMMY" "VI") then do;
		if trim(upcase(SHORT_TERM_CLAIM_IND)) = "Y" then do;
			SHORT_TERM_CLAIM_IND="N";
			FLAG_ADJ=3.0001;	
		end;
	end;
	/* -------------------------------------------------------------------- */
	/* Adj 3a - [NY RW adj_yyyymmdd_RMG.xls]								*/
	/* WBG: NY& LA reclass. Dummy Port CD									*/
	/* -------------------------------------------------------------------- */
	if APPL_CD in("NY LOAN" "LA LOAN" "MC LOAN") and ORIG_PORT_CD="DUMMY" then do;
		ORIG_PORT_CD='VI';
		PORT_CD='VI';
		FLAG_ADJ=3;
	end;
	if PROD_SYS_CD = "USER UPLOAD" then do;
		%include EA3_0 /source2; *<----- Error Adjustment 3;
	end;	
	/* -------------------------------------------------------------------- */
	/* Adj 5 - [No Source File]												*/
	/* Credit Card: Reclass. Dummy Port CD									*/
	/* -------------------------------------------------------------------- */
	if PORT_CD in ("DUMMY") and APPL_CD in ("CREDIT CARD") then do;
		ORIG_PORT_CD = 'VIIIa';
		PORT_CD = 'VIIIa';
		ORIG_RISK_WEIGHT=75.00;
		APPL_RISK_WEIGHT=75.00;
		RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		FLAG_ADJ=5;
	end;
	/* -------------------------------------------------------------------- */
	/* Adj 6 - [No Source File]												*/
	/* Reclass. MPA from VIIIa to IX										*/		
	/* -------------------------------------------------------------------- */
	if PORT_CD in ("VIIIa") and APPL_RISK_WEIGHT=75 and ACCT_PROD in ("MPA") then do;
  		ORIG_PORT_CD = 'IX';
		PORT_CD = 'IX';
  		ORIG_RISK_WEIGHT=35.00;
		APPL_RISK_WEIGHT=35.00;
  		RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		FLAG_ADJ=6;
	end;
	/* -------------------------------------------------------------------- */
	/* Adj 8 - [Port_CD IV adj_20130331 with summary.xls] 					*/
	/* Reallocation of short term bank exposure								*/	
	/* -------------------------------------------------------------------- */
	if PORT_CD in ("IV") and SHORT_TERM_CLAIM_IND="Y" then do;
		/* first part, cater banking customer */ 
		if ORIG_PORT_CD in ("IV") then do;
			
			if APPL_RISK_WEIGHT=50 			then Adjusted_RW=20;
			else if APPL_RISK_WEIGHT=100 	then Adjusted_RW=50;
			else Adjusted_RW = APPL_RISK_WEIGHT;

			%include EA8_0 /source2; *<----- Error Adjustment 8;

		 	ORIG_RISK_WEIGHT			=Adjusted_RW;
			APPL_RISK_WEIGHT			=Adjusted_RW;
			RISK_WEIGHTED_AMT_HKE		=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		end;
		else if ORIG_PORT_CD ne ("IV") then do;
			if APPL_RISK_WEIGHT=50 			then Adjusted_RW=20;
			else if APPL_RISK_WEIGHT=100 	then Adjusted_RW=50;
			else Adjusted_RW = APPL_RISK_WEIGHT;

			APPL_RISK_WEIGHT			=Adjusted_RW;
			RISK_WEIGHTED_AMT_HKE		=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		end;
		FLAG_ADJ=8;
		drop Adjusted_RW;
	end;
	/* -------------------------------------------------------------------- */
	/* Adj 14 - [SpGS and SfGS adjustment]								 	*/
	/* Obsolete since Dec 2013												*/
	/* -------------------------------------------------------------------- */
	/*	
	if substr(put(cats(ACCT_ID,ORIG_PORT_CD,ORIG_RISK_WEIGHT),$SPFGS.),1,5)="SPFGS" then do;
		FLAG_ADJ=14;
		FLAG_DELETE=14;
	end;
	*/
	/* for SPGS Bill Off Balance */
	/*
	if not missing(EXP_REF) and substr(PORT_CD,1,1) ="B" and length(ACCT_ID) > 13 then do;
		tmp=compress(substr(ACCT_ID,1,length(ACCT_ID)-13)," ");
		KEY_SPFGS_BOFF_RBG1=cats(tmp,compress(EXP_REF," "),CURR_CD,ORIG_PORT_CD,ORIG_RISK_WEIGHT);
		if put(KEY_SPFGS_BOFF_RBG1,$SPFGS.)="SPFGS_BOFF_RBG1" then do;
			FLAG_ADJ=102;
			FLAG_DELETE=102;
		end;
		drop tmp KEY_SPFGS_BOFF_RBG1;
	end;
	*/

	/* ********************************************************************* */
	/* ********************************************************************* */
	/* Combined Interco-elimination (IW) Handling 							 */
	/* Refer : iambs_kw_car_elim_20130331.xls								 */
	/* ********************************************************************* */
	if ENTITY="CNCBI" and PORT_CD = "VI" and (
			find(CUST_NAME,"CHINA CITIC BANK INTERNATIONAL") or 
			find(CUST_NAME,"CITIC KA WAH BANK")
		) then FLAG_ELIM_COMBIN=1;

	/* ********************************************************************* */
	/* ********************************************************************* */
	/* Consolidated Interco-elimination (IW) Handling 						 */
	/* Refer : iambs_kw_car_elim_20130331.xls								 */
	/* ********************************************************************* */
	if ENTITY="CNCBI" and substr(PORT_CD,1,2) = "IV" and (
			find(CUST_NAME,"CITIC BANK INTERNATIONAL (CHINA)") or 
			find(CUST_NAME,"HKCB FINANCE")
		) then FLAG_ELIM_CONSOL=1;

	/* -------------------------------------------------------------------- */
	/* Off Balance Adj. - DataComm for Port CD B2 B3						*/
	/* Obsolete since Dec 2013												*/
	/* -------------------------------------------------------------------- */
	/*
	if substr(put(cats(ACCT_ID,PORT_CD,CCF,ORIG_RISK_WEIGHT,APPL_RISK_WEIGHT),$DATCOM.),1,5)="@@@@@" then do;
		FLAG_ADJ=101;
		FLAG_DELETE=101;
	end;
	*/
	%include EA8_1 /source2; *<----- Error Adjustment 8.1;
	%include EA104 /source2; *<----- Error Adjustment 104;
	%include EA202 /source2; *<----- Error Adjustment 202;
	%include EA203 /source2; *<----- Error Adjustment 203;
run;


/* 
*Sense Checking for Combined Interco-elimination (IW) Handling;
proc sql;
select port_cd, sum(APPL_CRM_AMT_HKE) format comma32. 
from stg.car_iw_adj_&st_Rptmth. where FLAG_ELIM_COMBIN=1;
group by port_cd;
quit;
proc freq data=aa;
	table FLag_: /missing;
run;
*/
