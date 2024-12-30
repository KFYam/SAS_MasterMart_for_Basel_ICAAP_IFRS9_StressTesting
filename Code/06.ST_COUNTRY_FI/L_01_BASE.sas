/* Stressed Parameters */
%let notch_unrated_20	=4;
%let notch_unrated_50	=10;
%let notch_unrated_100	=13;
%let notch_unrated_150	=17;

proc sort data=siw.vi_iacbs_cust_elim_upd_&st_Rptmth. out=cust_elim(keep=CUST_SEC_ID) nodupkey;
	by CUST_SEC_ID;
run;
data cust_elim1;
	retain FMTNAME 'c_elim' TYPE "C";
	set cust_elim;
	START=CUST_SEC_ID;
	LABEL="**ELIM**";
	keep FMTNAME TYPE START LABEL;
run;
proc format cntlin=cust_elim1; run;



data FACT.BKFI_ST_BASE_&st_Rptmth.;
	set siw.vi_iambs_kw_car_&st_Rptmth.;

	if ORIG_PORT_CD in ('IV','IV_Y')					then FLAG_BK_FI=1; /*Bank*/
	else if ORIG_PORT_CD in ('V')						then FLAG_BK_FI=2; /*Securities Firms*/
	else if CUST_SUB_TYP_CD in ('34','35','36')			then FLAG_BK_FI=3; /*Bank*/
	else if substr(CUST_SIC_CD,1,1)='9' 				then FLAG_BK_FI=4; /*Bank*/
	else if substr(CUST_SIC_CD,1,3) in ('803','804')	then FLAG_BK_FI=5; /*Securities Firms*/
	end;
	
	if put(CUST_SEC_ID,$c_elim.)="**ELIM**" 			then FLAG_ELIM=1;
	if substr(CUST_SEC_ID,1,3) in ("HKI","***","   ")	then FLAG_DELETE=1;

	/* Merge the Rating into Master Table */	
	if substr(CURR_CD,1,2)= COUNTRY_CD then CCY_GROUP='LOC'; else CCY_GROUP='FGN';

	NOTCH		= input(put(trim(left(CUST_SEC_ID))||trim(left(CCY_GROUP)),$notch_cc. ),3.);
	NOTCH_BONDS	= input(put(trim(left(ACCT_ID)),$notch_bd.),3.);

	*if missing(NOTCH) and not missing(NOTCH_BONDS) then NOTCH=NOTCH_BONDS;
	if not missing(NOTCH_BONDS) then NOTCH=NOTCH_BONDS;

	if missing(NOTCH) then do;
		FLAG_UNRATED=1;
		if APPL_RISK_WEIGHT = 20	then NOTCH = &notch_unrated_20.;
		if APPL_RISK_WEIGHT = 50	then NOTCH = &notch_unrated_50.;
		if APPL_RISK_WEIGHT = 100	then NOTCH = &notch_unrated_100.;
		if APPL_RISK_WEIGHT = 150	then NOTCH = &notch_unrated_150.;
	end;
	ECAI_RATING	= put(NOTCH, sp_rate. );
run;
