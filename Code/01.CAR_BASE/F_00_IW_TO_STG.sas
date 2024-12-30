/* ************************************************************************************************* */
/* ************************************************************************************************* */
data stg.vi_iambs_ac_cov_&st_RptMth.;
	set 
		siw.vi_iambs_kw_ac_cov_&st_RptMth.(in=kw)
		siw.vi_iambs_vc_ac_cov_&st_RptMth.(in=vc)
		siw.vi_iambs_cf_ac_cov_&st_RptMth.(in=cf)
		siw.vi_iambs_sz_ac_cov_&st_RptMth.(in=sz)
	;
	if kw then FLAG_SRC="KW";
	if vc then FLAG_SRC="VC";
	if cf then FLAG_SRC="CF";
	if sz then FLAG_SRC="SZ";
run;
data stg.vi_iambs_ac_cov_&st_RptMth.;
	set 
		siw.vi_iambs_kw_ac_cov_&st_RptMth.(in=kw)
		siw.vi_iambs_vc_ac_cov_&st_RptMth.(in=vc)
		siw.vi_iambs_cf_ac_cov_&st_RptMth.(in=cf)
		siw.vi_iambs_sz_ac_cov_&st_RptMth.(in=sz)
	;
	if kw then FLAG_SRC="KW";
	if vc then FLAG_SRC="VC";
	if cf then FLAG_SRC="CF";
	if sz then FLAG_SRC="SZ";
run;

proc sql noprint;
	create table siw.vi_cmv_aclevel_&st_RptMth. as 
 	select 
		ACCT_ID,
 		sum(POS_AMT_HKE) 								as POS_AMT_HKE, 
 		sum(ALLOCATED_CMV_HKE) 							as ALLOCATED_CMV_HKE,
 		sum(RESIDUAL_CMV_HKE) 							as RESIDUAL_CMV_HKE,
 		sum(UNCOVER_AMT_HKE) 							as UNCOVER_AMT_HKE,
		sum(sum(ALLOCATED_CMV_HKE,RESIDUAL_CMV_HKE))	as CMV_HKE
 	from stg.vi_iambs_ac_cov_&st_RptMth.
	group by ACCT_ID
;
quit;

/* ************************************************************************************************* */
/* ************************************************************************************************* */
data stg.vi_iambs_alc_dtl_&st_RptMth.;
	set 
		siw.vi_iambs_kw_alc_dtl_&st_RptMth.(in=kw drop=COLL_REC_NBR COLL_CHG_PRI_NBR)
		siw.vi_iambs_vc_alc_dtl_&st_RptMth.(in=vc drop=COLL_REC_NBR COLL_CHG_PRI_NBR)
		siw.vi_iambs_cf_alc_dtl_&st_RptMth.(in=cf drop=COLL_REC_NBR COLL_CHG_PRI_NBR)
		siw.vi_iambs_sz_alc_dtl_&st_RptMth.(in=sz drop=COLL_REC_NBR COLL_CHG_PRI_NBR)
	;
	if kw then FLAG_SRC="KW";
	if vc then FLAG_SRC="VC";
	if cf then FLAG_SRC="CF";
	if sz then FLAG_SRC="SZ";

	if COLL_TYP="TD" 					then IND_COLL_TD=1;
	else if COLL_TYP="DP" 				then IND_COLL_DP=1;
	else if COLL_TYP in('PY','P004')	then IND_COLL_PY=1;
	else if COLL_TYP='G1'				then IND_COLL_G1=1;
	else if COLL_TYP='LC'				then IND_COLL_LC=1;

run;
proc sql noprint;
	create table stg.vi_iambs_alc_dtl_sum_&st_RptMth. as
	select
		ACCT_ID,
		/*POS_TYP,*/
		max(0,sum(ALLOCATED_CMV_HKE))						as ALLOCATED_CMV_HKE_ALL,
		max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_TD))			as ALLOCATED_CMV_HKE_TD,
		max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_DP))			as ALLOCATED_CMV_HKE_DP,
		max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_PY))			as ALLOCATED_CMV_HKE_PY,
		max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_G1))			as ALLOCATED_CMV_HKE_G1,
		max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_LC))			as ALLOCATED_CMV_HKE_LC,

		max(0,sum(RESIDUAL_CMV_HKE))						as RESIDUAL_CMV_HKE_ALL,
		max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_TD))			as RESIDUAL_CMV_HKE_TD,
		max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_DP))			as RESIDUAL_CMV_HKE_DP,
		max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_PY))			as RESIDUAL_CMV_HKE_PY,
		max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_G1))			as RESIDUAL_CMV_HKE_G1,
		max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_LC))			as RESIDUAL_CMV_HKE_LC,

		sum(max(0,sum(ALLOCATED_CMV_HKE)),max(0,sum(RESIDUAL_CMV_HKE))) 						as CMV_HKE_ALL,
		sum(max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_TD)),max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_TD)))	as CMV_HKE_TD,
		sum(max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_DP)),max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_DP)))	as CMV_HKE_DP,
		sum(max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_PY)),max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_PY)))	as CMV_HKE_PY,
		sum(max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_G1)),max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_G1)))	as CMV_HKE_G1,
		sum(max(0,sum(ALLOCATED_CMV_HKE*IND_COLL_LC)),max(0,sum(RESIDUAL_CMV_HKE*IND_COLL_LC)))	as CMV_HKE_LC

	from stg.vi_iambs_alc_dtl_&st_RptMth.
	group by ACCT_ID/*, POS_TYP*/
	order by ACCT_ID/*, POS_TYP*/;
quit;

/* Link ICAAP information to CAR tables */
%macro icaapSort(src=);
	proc sort data=siw.&src. ;
		by 
		ENTITY APPL_CD ACCT_ID ORIG_PORT_CD PORT_CD
		COLL_ACCT_ID COLL_REC_NBR COLL_CHG_PRI_NBR
		;
	run;
%mend;
%icaapSort(src=vi_iambs_kw_car_&st_RptMth.);
%icaapSort(src=vi_iambs_vc_car_&st_RptMth.);
%icaapSort(src=vi_iambs_cf_car_&st_RptMth.);
%icaapSort(src=vi_iambs_sz_car_&st_RptMth.);
%icaapSort(src=vi_iamic_cap_dtl_&st_RptMth.);

proc sort data=siw.vi_iamic_cap_dtl_&st_RptMth. out=stg.vi_iamic_cap_dtl_&st_RptMth. nodupkey;
	by ENTITY APPL_CD ACCT_ID ORIG_PORT_CD PORT_CD COLL_ACCT_ID COLL_REC_NBR COLL_CHG_PRI_NBR;
run;
%macro joinICAAP(src=);
	data stg.&src.;
		merge 
			siw.&src.(in=a) 
			stg.vi_iamic_cap_dtl_&st_RptMth.(keep=
				ENTITY 
				APPL_CD 
				ACCT_ID 
				ORIG_PORT_CD 
				PORT_CD
				COLL_ACCT_ID 
				COLL_REC_NBR 
				COLL_CHG_PRI_NBR

				ICAAP_BUS_UNIT
				ICAAP_CCF_TENOR
				ICAAP_COLL_TYP
				ICAAP_COLL_TYP_DESC
				ICAAP_CNTR_TYP
				ICAAP_CNTR_TYP_DESC
				ICAAP_CUST_SEC_ID
				ICAAP_PROD_CD
				ICAAP_RC_TEAM_CD
				ICAAP_TEAM_CD
				ICAAP_TEAM_DESC

				BAL_OGL_ACCT
				OGL_PROD_CD
				ALCO_PROD_CD
				ON_OFF_IND
				RC_CD
				ELIM_LVL
				SEC_CD

			in=b);
		by 
			ENTITY APPL_CD ACCT_ID ORIG_PORT_CD PORT_CD
			COLL_ACCT_ID COLL_REC_NBR COLL_CHG_PRI_NBR
		;
		if a;
		if b then FLAG_ICAAP=1;
	run;
%mend;
%joinICAAP(src=vi_iambs_kw_car_&st_RptMth.);
%joinICAAP(src=vi_iambs_cf_car_&st_RptMth.);
%joinICAAP(src=vi_iambs_vc_car_&st_RptMth.);
%joinICAAP(src=vi_iambs_sz_car_&st_RptMth.);


data FMT_CBIC_CUST_ID (keep=FMTNAME TYPE START LABEL HLO);
	retain FMTNAME 'cbicid' TYPE "C";
	set siw.xls_cbic_bank_cust_id_&st_Rptmth. end=last;;

	START=trim(left(CUST_NAME));
	LABEL=ISSUE_BANK_CUST_SEC_ID;
	output;
	if last then do;
		START="**OTHER**";
		LABEL="@@@@";
		HLO='O';
		output;
	end;
run;
proc format cntlin=FMT_CBIC_CUST_ID; run;


%macro joinGuarn(src=,coll=);
	proc sql noprint;
		create table stg.&src. as
		select 
			a.*,
			%if &src.=vi_iambs_sz_car_&st_RptMth. %then %do;
				compress(put(a.CUST_NAME,$cbicid.),"@") as ISSUE_BANK_CUST_SEC_ID,
			%end;
			b.GUARTOR_CUST_SEC_ID,
			cat(trim(left(b.GUARTOR_NAME_1))," ",trim(left(b.GUARTOR_NAME_2))) as GUARTOR_NAME
			from stg.&src. a 
			left join  
			(	select distinct 
					ACCT_ID,REC_NBR,CHG_PRI_NBR,FAC_REF,
					GUARTOR_CUST_SEC_ID,GUARTOR_NAME_1,GUARTOR_NAME_2 
				from siw.&coll.
			) b
			on 
				a.COLL_ACCT_ID=b.ACCT_ID and 
				a.COLL_REC_NBR=b.REC_NBR and
				a.COLL_CHG_PRI_NBR=b.CHG_PRI_NBR and
				a.FAC_REF=b.FAC_REF
		;
	quit;
%mend;
%joinGuarn(src=vi_iambs_kw_car_&st_RptMth.,coll=vi_iambs_kw_coll_&st_RptMth.);
%joinGuarn(src=vi_iambs_cf_car_&st_RptMth.,coll=vi_iambs_cf_coll_&st_RptMth.);
%joinGuarn(src=vi_iambs_vc_car_&st_RptMth.,coll=vi_iambs_vc_coll_&st_RptMth.);
%joinGuarn(src=vi_iambs_sz_car_&st_RptMth.,coll=vi_iambs_sz_coll_&st_RptMth.);




/*
data stg.vi_iambs_ac_cov_&st_RptMth.;
	set 
		siw.vi_iambs_kw_ac_cov_&st_RptMth.(in=kw)
		siw.vi_iambs_vc_ac_cov_&st_RptMth.(in=vc)
		siw.vi_iambs_cf_ac_cov_&st_RptMth.(in=cf)
		siw.vi_iambs_sz_ac_cov_&st_RptMth.(in=sz)
	;
	if kw then FLAG_SRC="KW";
	if vc then FLAG_SRC="VC";
	if cf then FLAG_SRC="CF";
	if sz then FLAG_SRC="SZ";
run;
proc sort data=stg.vi_iambs_ac_cov_&st_RptMth.;	by ACCT_ID POS_TYP;run;

data stg.vi_iambs_ac_cov_wTD_&st_RptMth.;
	merge 
		stg.vi_iambs_ac_cov_&st_RptMth.(in=cov)
		stg.vi_iambs_alc_dtl_sum_&st_RptMth. (in=alc);
	by ACCT_ID ;
	if cov ;
	drop ALLOCATED_CMV_HKE_ALL RESIDUAL_CMV_HKE_ALL;
run;



data basel_cov_alc_&st_RptMth.;
	merge 
		stg.vi_iambs_ac_cov_&st_RptMth.(in=cov)
		stg.vi_iambs_alc_dtl_sum_&st_RptMth. (in=alc);
	by ACCT_ID POS_TYP;
	if cov then FLAG_COV=1;
	if alc then FLAG_ALC=1;
	keep ACCT_ID POS_TYP ALLOCATED_CMV: RESIDUAL_CMV: FLAG_:;
run;
data check1;
	set basel_cov_alc_&st_RptMth.;
	if FLAG_ALC=1 and FLAG_COV ne 1;
run;
data check2;
	set basel_cov_alc_&st_RptMth.;
	if FLAG_ALC=1;
	if ALLOCATED_CMV_HKE_ALL-ALLOCATED_CMV_HKE > 0.001;
run;
data check3;
	set basel_cov_alc_&st_RptMth.;
	if FLAG_ALC=1;
	if RESIDUAL_CMV_HKE_ALL-RESIDUAL_CMV_HKE > 0.001;
run;
*/
/*
data stg.vi_iambs_ac_exp_&st_RptMth.;
	set 
		siw.vi_iambs_kw_ac_exp_&st_RptMth.(in=kw)
		siw.vi_iambs_vc_ac_exp_&st_RptMth.(in=vc)
		siw.vi_iambs_cf_ac_exp_&st_RptMth.(in=cf)
		siw.vi_iambs_sz_ac_exp_&st_RptMth.(in=sz)
	;
	if kw then FLAG_SRC="KW";
	if vc then FLAG_SRC="VC";
	if cf then FLAG_SRC="CF";
	if sz then FLAG_SRC="SZ";
run;
proc sql noprint;
	create table ac_exp_undrawn_&st_RptMth. as
	select 
		ENTITY, 
		ACCT_ID, 
		LOAN_USAGE_COUNTRY_CD, 
		CUST_BK_GROUP,
		sum(UNPAID_INT_ACCR_HKE) as UNPAID_INT_ACCR_HKE, 
		sum(UNDWN_COMMIT_AMT_HKE) as UNDWN_COMMIT_AMT_HKE 
	from stg.vi_iambs_ac_exp_&st_RptMth.
	group by ENTITY, ACCT_ID, LOAN_USAGE_COUNTRY_CD, CUST_BK_GROUP
	;

	create table STG.PBG_BASE_&st_RptMth. as
	select 
		a.*, 
		b.UNPAID_INT_ACCR_HKE, 
		b.UNDWN_COMMIT_AMT_HKE, 
		b.LOAN_USAGE_COUNTRY_CD,
		b.ENTITY as ENTITY_AC_EXP,
		b.CUST_BK_GROUP
	from PBG_BASE a left join ac_exp_undrawn_&st_RptMth. b 
	on a.ACCT_ID = b.ACCT_ID
	order by a.ACCT_ID, a.ENTITY, b.ENTITY, b.CUST_BK_GROUP;
quit;
*/

