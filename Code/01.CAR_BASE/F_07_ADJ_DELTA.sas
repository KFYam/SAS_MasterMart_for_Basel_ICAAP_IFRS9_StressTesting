%ErrAdj(err_tbl=siw.XLS_ST_MANUAL_MASTER_&st_rptmth.,tbl=KW_VC,mode=I);

/* Adj 3b - [NY RW adj_yyyymmdd_RMG.xls]								*/
/* WBG: NY& LA reclass. Dummy Port CD									*/
/* -------------------------------------------------------------------- */
/* Refer to [Adj_Data] of Basel worksheet for RWA - remark:(MPA deduction (Securitization)) */
data stg.adj_delta_3_&st_rptmth.;
	%include EA3_1 /source2; *<----- Error Adjustment 3.1;
	FLAG_ADJ=3.1;
	if APPL_CRM_AMT_HKE = . then delete;
run;


/* **************************************************************************** */
/* Adj. 5 - Credit Card: Reclass. In Cr. balance */
/* Refer to [Adj_Data] of Basel worksheet for RWA */
data stg.adj_delta_5_&st_rptmth.;
	ENTITY				="CNCBI";
	APPL_CD				="CREDIT CARD";
	ORIG_PORT_CD		="VIIIa";
	PORT_CD				="VIIIa";
	PROD_SYS_CD			="MANUAL ADJ";
	FLAG_ADJ=5.1;
	%include EA5_1 /source2; *<----- Error Adjustment 5.1;
	if APPL_CRM_AMT_HKE = . then delete;
run;

/* **************************************************************************** */
/* Adj. 6 - MPA deduction (Securitization) */
/* Refer to [Adj_Data] of Basel worksheet for RWA */
data stg.adj_delta_6_&st_Rptmth.;
	length ORIG_PORT_CD PORT_CD $10;
	ENTITY				="CNCBI";
	APPL_CD				="ALS";
	PROD_SYS_CD			="MANUAL ADJ";
	FLAG_ADJ=6.1;
	%include EA6_1 /source2; *<----- Error Adjustment 5.1;
	if APPL_CRM_AMT_HKE = . then delete;
run;

/* **************************************************************************** */
/* Adj. other -  */
data stg.adj_delta_other_&st_Rptmth.;
	length ORIG_PORT_CD PORT_CD $10;
	ENTITY				="CNCBI";
	PROD_SYS_CD			="MANUAL ADJ";
	%include EA999 /source2; 
	if APPL_CRM_AMT_HKE = . then delete;
run;

/* **************************************************************************** */
/* Adj. 14 - SpGS and SfGS Adjustment */
%macro adj14();
	proc sort data=stg.car_iw_adj_&st_Rptmth. out=adj_14 nodupkey; 
		by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT;
		where FLAG_DELETE=14;
	run;
	proc sql noprint;
		select count(ACCT_ID) into :cnt_adj14 from adj_14;
	quit;
	%if &cnt_adj14. eq 0  %then %do;
		data stg.adj_delta_14_&st_Rptmth.;
			set adj_14(keep=ACCT_ID);
		run;
	%end;
	%else %do;
		proc sort data=stg.x_sgps_all_&st_Rptmth. out=sgps_all; 
			by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT SEQ;
			where FLAG_SRC ne "SPFGS_BOFF_RBG1";
		run;
		data stg.adj_delta_14_&st_Rptmth.;
			merge 
				adj_14(in=a drop=PORT_CD CCF APPL_RISK_WEIGHT APPL_CRM_AMT_HKE RISK_WEIGHTED_AMT_HKE) 
				sgps_all(in=b) ;
			by ACCT_ID ORIG_PORT_CD ORIG_RISK_WEIGHT;
			if a ;
			FLAG_ADJ=14.1;
			FLAG_DELETE=.;
			RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
			drop KEY SEQ FLAG_SRC;
		run;
	%end;
%mend;
/*%adj14; Obsolete - due to System Automation */


/* **************************************************************************** */
/* **************************************************************************** */
/* Off Balance Adjustment DataCom 												*/
%macro adj101();
	proc sort data=stg.car_iw_adj_&st_Rptmth. out=adj_101 nodupkey; 
		by ACCT_ID PORT_CD ORIG_RISK_WEIGHT APPL_RISK_WEIGHT;
		where FLAG_DELETE=101;
	run;
	proc sort data=stg.adj_offbal_datacom_&st_Rptmth. out=datcom; 
		by ACCT_ID PORT_CD ORIG_RISK_WEIGHT APPL_RISK_WEIGHT;
	run;
	proc sql noprint;
		select count(ACCT_ID) into :cnt1 from adj_101;
		select count(ACCT_ID) into :cnt2 from datcom;
	%if &cnt1. eq 0 or &cnt2. eq 0 %then %do;
		data stg.adj_delta_101_&st_Rptmth.;
			ACCT_ID=""; FLAG_ADJ=101.1;
			if ACCT_ID="" then delete;
		run;
	%end;
	%else %do;
		data stg.adj_delta_101_&st_Rptmth.;
			merge 
				adj_101(in=a) 
				datcom(in=b keep=ACCT_ID PORT_CD ORIG_RISK_WEIGHT APPL_RISK_WEIGHT APPL_CRM_AMT_HKE_ADJ APPL_RISK_WEIGHT_ADJ);
			by ACCT_ID PORT_CD ORIG_RISK_WEIGHT APPL_RISK_WEIGHT;
			if a;
			FLAG_ADJ=101.1;
			FLAG_DELETE=.;
			APPL_CRM_AMT_HKE=APPL_CRM_AMT_HKE_ADJ;
			if not missing(APPL_RISK_WEIGHT_ADJ) then APPL_RISK_WEIGHT=APPL_RISK_WEIGHT_ADJ;

			RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT*CCF/(100*100);
			drop APPL_RISK_WEIGHT_ADJ APPL_CRM_AMT_HKE_ADJ;
		run;
	%end;
%mend;
/*%adj101; Obsolete - due to System Automation */

/* **************************************************************************** */
/* SPGS Bill Off Balance Adjustment												*/
%macro adj102();

	data adj_102;
		set stg.car_iw_adj_&st_Rptmth.;
		where FLAG_DELETE=102;
		tmp=compress(substr(ACCT_ID,1,length(ACCT_ID)-13)," ");
		KEY=cats(tmp,compress(EXP_REF," "),CURR_CD,ORIG_PORT_CD,ORIG_RISK_WEIGHT);
		drop 
			PORT_CD CCF APPL_RISK_WEIGHT APPL_CRM_AMT_HKE tmp
			COLL_ACCT_ID COLL_REC_NBR COLL_CHG_PRI_NBR CRM_COV_IND
			;
	run;
	proc sql noprint;
		select count(ACCT_ID) into :cnt_adj102 from adj_102;
	quit;
	%if &cnt_adj102. eq 0  %then %do;
		data stg.adj_delta_102_&st_Rptmth.;
			set adj_102(keep=ACCT_ID);
		run;
	%end;
	%else %do;
		data adj_102_spgs;
			set stg.x_sgps_all_&st_Rptmth.;
			where FLAG_SRC="SPFGS_BOFF_RBG1";
			keep KEY PORT_CD CCF APPL_RISK_WEIGHT APPL_CRM_AMT_HKE;
		run;
		proc sort data=adj_102 nodupkey; by KEY; run; 
		proc sort data=adj_102_spgs; by KEY; run; 

		data stg.adj_delta_102_&st_Rptmth.;
			merge 
				adj_102(in=a) 
				adj_102_spgs(in=b)
			;
			by KEY;
			if b ;
			FLAG_ADJ=102.1;
			FLAG_DELETE=.;
			RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*(CCF*APPL_RISK_WEIGHT)/(100*100);
			drop KEY;
		;
		run;
	%end;
%mend;
/*%adj102; Obsolete - due to System Automation */
