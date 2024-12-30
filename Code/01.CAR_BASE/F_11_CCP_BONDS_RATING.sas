/* ******************************************************************************************** */
/* ******************************************************************************************** */
/* Using Master Scale PD to set the mapping between rating and the notches 						*/
%macro fmt_rating(type);
	data fmtrate(keep=FMTNAME TYPE START LABEL);
		length START LABEL $20;
		set siw.xls_master_scale_pd;
		where &type. ne "-";
		FMTNAME	="&type.";
		TYPE	="I";
		START	=&type.;
		LABEL	=NOTCH;
	run;
	proc format cntlin=fmtrate; run;
%mend;
%fmt_rating(Moody_s);
%fmt_rating(S_P);
%fmt_rating(Fitch);

data sprate(keep=FMTNAME TYPE START LABEL);
	length START LABEL $20;
	set siw.xls_master_scale_pd;
	where S_P ne "-";
	FMTNAME	="SP_rate";
	TYPE	="N";
	START	=NOTCH;
	LABEL	=S_P;
run;
proc format cntlin=sprate; run;

/* ******************************************************************************************** */
/* ******************************************************************************************** */
/* Bonds Rating - when the Bank buy any bond issued by counterparties (most likely banks),		*/
/* we need to check the rating of the bond first, then check the issuers' rating,				*/

data bonds_v1;
	set STG.bonds_rating_&st_Rptmth.;
	length ACCT_ID $60 RATE RATESRC	$10;
	keep ACCT_ID RATE RATESRC NOTCH;
	/* Seems the account id includes short/long term and domestic/foreign currency info. */
	ACCT_ID	=left(trimn(secid)||trimn(cc)||trimn(pt)||trimn(inv));

	/* Obsolete starting from Jan 2014 because OPICS is changed to Calypso - RATE =compress(Sec_Moodynyc,"e"); */
	RATE	=compress(MOODYNYC,"e");
	RATESRC	="MOODY_S";
	NOTCH	=input(RATE,MOODY_S.);
	if not missing(RATE) then output;	

	/* Obsolete starting from Jan 2014 because OPICS is changed to Calypso - RATE =compress(Sec_SANDPNYC,"e"); */
	RATE	=compress(SANDPNYC,"e");
	RATESRC	="S_P";
	NOTCH	=input(RATE,S_P.);
	if not missing(RATE) then output;	
run;
proc sort data=bonds_v1 out=bonds_v1_dup nodupkey;
	by ACCT_ID NOTCH;
run;

proc sql noprint;
	create table bonds_v2 as
	select a.*, b.TOT_COUNT_NOTCH
	from 
		bonds_v1_dup a
	left join 
		(select ACCT_ID, count(1) as TOT_COUNT_NOTCH from bonds_v1_dup group by ACCT_ID) b
	on a.ACCT_ID=b.ACCT_ID
	order by a.ACCT_ID, a.NOTCH ;
quit;
data stg.bonds_notch_&st_Rptmth.;
	retain ACCT_ID_SEQ 0;
	set bonds_v2;
	by ACCT_ID NOTCH;

	if FIRST.ACCT_ID then ACCT_ID_SEQ=1; else ACCT_ID_SEQ=ACCT_ID_SEQ+1;

	if TOT_COUNT_NOTCH =1 then FLAG_TARGET=1;
	else if TOT_COUNT_NOTCH > 1 and ACCT_ID_SEQ=2 then FLAG_TARGET=1;
run;


/* ******************************************************************************************** */
/* ******************************************************************************************** */
/* CC Rating - Use issuer rating; rate would be varied by CCY_GROUP 							*/
data cc_rating_v1;
	set stg.cc_rating_&st_Rptmth.;
	where not missing(rateagncy);
	if rateagncy="S & P'S"	then NOTCH=input(RATE,S_P.);
	if rateagncy="MOODY'S"	then NOTCH=input(RATE,MOODY_S.);
	if rateagncy="Fitch" 	then NOTCH=input(RATE,FITCH.);
run;
proc sort data=cc_rating_v1 out=cc_rate_v1_dup nodupkey;
	by	RM_CUST_ID /*TERM*/ CCY_GROUP NOTCH;
	where not missing(NOTCH); 
run;
proc sql noprint;
	create table cc_rate_v2 as
	select a.*, b.TOT_COUNT_NOTCH
	from 
		cc_rate_v1_dup a
	left join 
		(	select 
				RM_CUST_ID,
				/*TERM,*/ 
				CCY_GROUP, 
				count(1) as TOT_COUNT_NOTCH 
			from cc_rate_v1_dup 
			group by 
				RM_CUST_ID,
				/*TERM,*/ 
				CCY_GROUP 
		) b
	on 
		a.RM_CUST_ID=b.RM_CUST_ID and 
		/* a.TERM=b.TERM and */ 
		a.CCY_GROUP=b.CCY_GROUP
	order by 
		a.RM_CUST_ID, /*a.TERM,*/ a.CCY_GROUP, a.NOTCH ;
quit;

data stg.cc_rate_notch_&st_Rptmth.;
	retain CCY_GROUP_SEQ 0;
	set cc_rate_v2;
	by RM_CUST_ID /*TERM*/ CCY_GROUP NOTCH ;

	if FIRST.CCY_GROUP then CCY_GROUP_SEQ=1; else CCY_GROUP_SEQ=CCY_GROUP_SEQ+1;

	if TOT_COUNT_NOTCH =1 then FLAG_TARGET=1;
	else if TOT_COUNT_NOTCH > 1 and CCY_GROUP_SEQ=2 then FLAG_TARGET=1;
run;

/* ******************************************************************************************** */
/* ******************************************************************************************** */
proc sort data=stg.cc_rate_notch_&st_Rptmth. out=notch_cc nodupkey;
	where flag_target=1;
	by RM_CUST_ID CCY_GROUP;
run;
data FMT_CCY_NOTCH (keep=FMTNAME TYPE START LABEL HLO);
	retain FMTNAME 'notch_cc' TYPE "C";
	set notch_cc end=last;

	START=trim(left(RM_CUST_ID))||trim(left(CCY_GROUP));
	LABEL=NOTCH;
	output;
	if last then do;
		START="**OTHER**";
		LABEL=".";
		HLO='O';
		output;
	end;
run;
proc format cntlin=FMT_CCY_NOTCH; run;



proc sort data=stg.bonds_notch_&st_Rptmth. out=notch_bd nodupkey;
	where flag_target=1;
	by ACCT_ID;
run;
data FMT_BOND_NOTCH(keep=FMTNAME TYPE START LABEL HLO);
	retain FMTNAME 'notch_bd' TYPE "C";
	set notch_bd end=last;

	START=trim(left(ACCT_ID));
	LABEL=NOTCH;
	output;
	if last then do;
		START="**OTHER**";
		LABEL=".";
		HLO='O';
		output;
	end;
	;
run;
proc format cntlin=FMT_BOND_NOTCH; run;

/* ******************************************************************************************** */
/* ******************************************************************************************** */
