proc format;
	value $pbg1_f
	'BAS','SME','M&E'					='@@##@@##!!'
	;
	value $pbg2_f
	'RMIL','SOIL-COM','SOIL-IND'		='PBG_1.MORTGAGES'
	'TAXI/PLB'							='PBG_2.TAXI'
	'@@##@@##!!'						='PBG_3.BB'
	'AQUA','CUP','CARD','PLOC','RCC'	='PBG_4.CREDITCARD'
	other								='PBG_5.OTHERS'
	;
run;

data tmp_cust_typ_cd;
	retain FMTNAME "$custyp";
	set siw.vi_iamrm_cust_noid_&st_Rptmth.;
	START=CUST_SEC_ID;
	LABEL=CUST_TYP_CD;
	where not missing(CUST_SEC_ID) and substr(CUST_SEC_ID,1,5) ne "*****";
	keep FMTNAME START LABEL;
run;
proc sort data=tmp_cust_typ_cd; by START; run;
proc format CNTLIN=tmp_cust_typ_cd;run;


data stg.ru_pbg_exp_&st_RptMth.;
	length ACCT_ID BU_GROUP $60;
	set fact.pbg_base_with_DSR_&st_RptMth.(rename=(ACCT_ID=ACCT_ID_OLD));
	
	if PROD_SYS_CD in ('ALS','AS400','IM CORE') 	then ACCT_ID=ACCT_ID_OLD;
	else if PROD_SYS_CD in ('IMEX') 				then ACCT_ID=(left(trimn(IMEX_CUST_ID)||trimn(DEAL_ID)||trimn(TRAN_ID)||(PROD_TYP)));
	else if PROD_SYS_CD in ('CARDLINK') 			then ACCT_ID=trimn(left('18010000000000'||ACCT_ID_OLD));
	else if PROD_SYS_CD in ('ELS') 					then ACCT_ID=trimn(left('01'||ACCT_ID_OLD));
	else ACCT_ID=ACCT_ID_OLD;

	if PROD_TYP in (
		'Inward Collection', 
		'OB Coll Under L/C',
		'OB Coll Without L/C',
		'OS Bill Under L/C'
	) then FLAG_DELETE = 1;
	if PRIN_HKE <= 0 					then FLAG_DELETE = 1.1;
	if ON_OFF_IND ne 'N' 				then FLAG_DELETE = 1.2;
	if IAS_PROD in ('SFM','BILLS-B') 	then FLAG_DELETE = 1.3;

	if put(BUS_UNIT,$pbg1_f.) ne BUS_UNIT then 
		BU_GROUP=put(put(BUS_UNIT,$pbg1_f.),$pbg2_f.);
	else 
		BU_GROUP=put(IAS_PROD,$pbg2_f.);

	/* Added on 3 April 2014 - HKMA Circular Personal Loan Portfolio (Unsecured) Part */
	/* 
		IAS_PROD=UOD 	stands for Unsecured Overdraft
		IAS_PROD=PLOC 	stands for Personal Line of Credit which is personal loan with revolving feature capable min. payment
		IAS_PROD=RCC 	stands for Revolving Cash Card
		IAS_PROD=REBOOK stands for Restructured Book Loan without revolving nature (or called as Rebooked SOA accounts)
		IAS_PROD=UOIL	stands for Unsecured other installment loan without revolving nature
	*/
	if (substr(IAS_PROD,1,5)='SMART' or IAS_PROD in ('UOD' 'PLOC' 'RCC' 'REBOOK' 'UOIL')) and 
		ON_OFF_IND = "N" and BUS_UNIT in ("CUCL" "WM") then do;
			FLAG_PUL=1;
			
			if 		substr(ACCT_ID_OLD,1,5)='99999'	then FLAG_DELETE_PUL=1; * which is Staff Pay-Roll A/C;
			else if substr(FAC_NO_CKWB,1,5)="#####"	then FLAG_DELETE_PUL=2; * which is Temp OD;
			else if put(CUST_SEC_ID,$custyp.)="C"	then FLAG_DELETE_PUL=3; * which is Companies;

			if IAS_PROD in ('UOD' 'UOIL' 'RCC' 'REBOOK') then FLAG_EXCLUDED_PUL=1; * which are the products that have been excluded from the policy team scope;

	end;
run;

/* Checking 
proc freq data=stg.ru_pbg_exp_&st_RptMth.;
	table IAS_PROD*BUS_UNIT /missing norow nocol nopct;
	where FLAG_HKMA_PIL_UNSEC=1;
run;

proc sort data=stg.ru_pbg_exp_&st_RptMth. out=check_1;
	by FLAG_DELETE ACCT_ID PROD_SUB_TYP_CD;
run;
data check_1a;
	set check_1;
	by FLAG_DELETE ACCT_ID PROD_SUB_TYP_CD;
	if first.ACCT_ID ne last.ACCT_ID;
run;
proc freq data=stg.ru_pbg_exp_&st_RptMth.;
table BU_GROUP bus_unit /missing;
where FLAG_DELETE = .;
run;
*/

/* Remark:
There are 2 kinds of tables related to collateral and that are iambs_kw_coll and iambs_kw_alc_dtl.
table:	iambs_kw_alc_dtl (collateral allocation detail)
key: 	appl_cd,acct_id,coll_acct_id,coll_rec_nbr,coll_chg_pri_nbr,pos_typ
note:	Sum of allocated_cmv_hke by acct_id and fac_ref = allocated_cmv_hke in iambs_kw_ac_cov.
		Allocated_cmv_hke is before applying haircut.
		If overcollatualization, the residual cmv amount would be saved in the field of residual_cmv_hke.

table:	iambs_kw_coll (collateral table after CRM)
key: 	acct_id,rec_nbr,chg_pri_nbr,fac_ref 
note:	Coll_amt_hke stands for the current market value with haircut applied.
		It need to be de-duplicated the records because duplicated records currently exist.
		The duplication exists because single collateral may support many facilites; if this is the case,
		duplicated records with unqiue facility reference.
		
For relation between eligible collateral type and security code
TD (Time deposit) 				in (ST01,ST02, T001,T002,T003)
SH (??) 						in (S001,S003,ST03)
PY (Properties)					in (P001)=residential, (P002,P003,P004)=commercial, industrial & others
OS (??)							in (DS01,DS04,ST03, T003)
LC (Standby LC issued by bank)	in (G006)
IS (Unit Trust/Mutual Funds) 	in (O007)
IG (Corporate Guarantees) 		in (G007)
G1 (Government Gurantees)		in (G001)
	
*/



