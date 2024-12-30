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
	else do;
		if CUST_SEC_ID='B*06381' 		and ACCT_ID='L BAC 0 01/30/2014820INV3A' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD19924' 	and ACCT_ID='X C 5.85 07/02/13820INV3A' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD18973' 	and ACCT_ID='0001431868' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD19673' 	and ACCT_ID='0001476731' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKB19983196000' and ACCT_ID='18100912000000000015659328' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD22253' 	and ACCT_ID='X HSBC 6.375 11/12820INV3A' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD18759' 	and ACCT_ID='L KBC 0 11/29/49824INV1ASUB_NOTE' 			then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZFIG074' 		and ACCT_ID='0001387410' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZFIG075' 		and ACCT_ID='0001387413' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKB08440309000' and ACCT_ID='18100912000000000015658658' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKB12256380000' and ACCT_ID='0001379158' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD18703' 	and ACCT_ID='CALL_CSA18703MSILL_USD' 					then FLAG_BK_FI=6;
		if CUST_SEC_ID='GBZ2068222' 	and ACCT_ID='0001508509' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZFIG068' 		and ACCT_ID='BEIIID894151077810ISS000Non-Funded NLRP'	then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKB10180347000' and ACCT_ID='18100912000000000015611661' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD24826' 	and ACCT_ID='L WFC 0 05/10/12820INV3A' 					then FLAG_BK_FI=6;
		if CUST_SEC_ID='CNZ560350041' 	and ACCT_ID='18100912000000000015655855' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKB11355571000' and ACCT_ID='0001336454' 								then FLAG_BK_FI=6;
		if CUST_SEC_ID='VGZ1644944' 	and ACCT_ID='18101912000000000015645469' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='HKZTOD25084' 	and ACCT_ID='L SANTAN 0 04/19/13820INV3A' 				then FLAG_BK_FI=6;
		if CUST_SEC_ID='ESZA95338000' 	and ACCT_ID='L BBVASM 0 01/22/13820INV3A' 				then FLAG_BK_FI=6;
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
