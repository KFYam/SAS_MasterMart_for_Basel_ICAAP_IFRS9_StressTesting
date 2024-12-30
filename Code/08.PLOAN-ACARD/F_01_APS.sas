/************************************************************************************/
/* BEGIN - CONVERT OLD APS DATA's FIELD 											*/
data v_oaps / view=v_oaps;
	set STG.OAPS(
	rename=(
	kmo_res		= kmon_res
	kmo_post	= kmo_pos
	cDur		= Tenor
	cpubstat	= t_cpubstat
	cResult		= t_cResult
	cMarital	= t_cMarital
	fSef_Emp	= cfSef_Emp
	crmdRea		= cDeclin_all
	fnegApp		= cfnegApp
	));

	fVIP 		= trim(fVIP);
	cpubstat 	= input(compress(t_cpubstat,"CVP,."), best10.);
	cResult		= put(t_cResult, $o_appr.);
	cMarital	= put(t_cMarital, $o_mrtal.);
	fSef_Emp 	= input(cfSef_Emp, best12.);
	cCamp		= put(cmkt, best5.);
	fnegApp		= input(fnegApp, best12.);
run;
/* FINISH - CONVERT OLD APS DATA's FIELD 											*/
/************************************************************************************/

/************************************************************************************/
/* BEGIN - CONVERT NEW APS DATA's FIELD 											*/
data v_naps / view=v_naps;
	set STG.NAPS(rename=(
		fSAsupp 	= cfSAsupp
		fNegApp 	= cfNegApp
		fSef_Emp	= cfSef_Emp
		fFor_add	= cfFor_add
		cfraud		= t_cfraud
	));
	kmo_pos 	= sum(kyr_pos*12, kmo_pos); /* Combined the field of Position Period */
	fFor_add	= input(cfFor_add, YN_ind.);
	fSAsupp 	= input(cfSAsupp, YN_ind.);
	fNegApp 	= input(cfNegApp, YN_ind.);
	cClass		= compress(cClass, " ");
	fSef_Emp	= input(cfSef_Emp, YN_ind.);
	cDeclin_all	= catx(" ", of cDecline1-cDecline2);
	cfraud		= input(substr(t_cfraud,1,1), YN_ind.);
run;
/* FINISH - CONVERT NEW APS DATA's FIELD 											*/
/************************************************************************************/

/************************************************************************************/
data FACT.APS_Factors;
	set v_naps(in=a) v_oaps(in=b);

	n_APSref	= input(nAPSref, best32.);
	nstaff		= compress(nstaff, " ");
	cIncTyp 	= compress(cIncTyp, " ");
	age			= intck("YEAR", dbirth, dapp_rec);
	cdev		= catx(" ", of cdev1-cdev3);
	cNation		= put(cNation, $nation.);
	cedu_Lv		= put(cedu_Lv, $edu.);
	mth_Residen	= sum(kyr_res*12, kmon_res);

	/* 
	   DTI Calculation Logic : 
		xTotCR1		: TU Revolving Credits - Total Limit 		(not in Old APS)
		xTotUsed1	: TU Revolving Credits - Total Used Limit 	(not in Old APS)
		xTotInst1	: TU Instalment Loans - Total Instal. Amt.	(not in Old APS)
		dummy1		: Initial Instalment Loan (i.e. Tenors <= 2)(not in New and Old APS)
		dummy2		: Outside Loans Instal. Amt.				(not in New and Old APS)
		amthInst	: MIL Instal. & Rental Expense
		acrtlmt		: New Proposed credit card limit
		apr_inc		: Proven Monthly Income
		TU_RC_min 	: TU Revolving Credit Min. Payment (i.e 4% of Limit ) 
		p_crd_min	: proposed card min pymt (i.e. 4 % of New Proposed credit card limit)
		tot_mth_deb	: Total Monthly Debts	= TU Revolving Credit Min. Payment
											+ Total Instal. Amt
											- Initial Instalment Loan
											+ Outside Loans Instal. Amt.
											+ MIL Instal. & Rental Expense
											+ proposed card min pymt
		DTI			: Total Monthly Debts / apr_inc	
	*/
	/* Total Used Limit > Total Limit or 80% of Total Limit > Total Used Limit */
	tu_rc_min 		= ifn((xTotUsed1 > xTotCR1) or (xTotCR1*0.8 > xTotUsed1), xTotUsed1, xTotCR1)*0.04;
	tot_mth_deb		= sum(tu_rc_min, xTotInst1, -0, +0, amthInst , acrtlmt*0.04);

	if missing(Apr_Inc) or Apr_Inc=0 then DTI_pct = .; 
	else DTI_pct=tot_mth_deb / Apr_Inc*100;

	/* Cancel case - 60 days timeout and system automatically set as Decline */
	if cResult = "D" and compress(cDecline1," ") in ("00" "") then cResult = "C"; 

	nBkscore 		= input(nBkscore1, best32.);
	cr_exp_cnt 		= CreditExposureCnt;
	
	IND_SRC			= ifn(a,.N,.O);
	IND_PRODUCT 	= input(cCardTyp,prd_typ.);
	IND_DEBIT_AC	= ifn(input(Debit_AcctNbr,best32.)>0,1,.); /*Check with the A/C exist debit A/C */

	FLAG_EXCLUDE_APS = .;
	if missing(FLAG_EXCLUDE_APS) then do;
		if fSAsupp = 1 						then FLAG_EXCLUDE_APS = 100; /* Sampling Exclusion: Supplementary Card */
		else if cClass="S" 					then FLAG_EXCLUDE_APS = 120; /* Sampling Exclusion: Staff */	
		else if not missing(nstaff) 		then FLAG_EXCLUDE_APS = 121; /* Sampling Exclusion: Staff */	
		else if cClass="V" 					then FLAG_EXCLUDE_APS = 140; /* Sampling Exclusion: VIP */	
		else if fVIP="1" 					then FLAG_EXCLUDE_APS = 141; /* Sampling Exclusion: VIP */	
		else if index(cdev,"32")>=1 		then FLAG_EXCLUDE_APS = 142; /* Sampling Exclusion: VIP */	
		else if cClass="P" 					then FLAG_EXCLUDE_APS = 160; /* Sampling Exclusion: Deposit Pledge Account */	
		else if cIncTyp="T7"				then FLAG_EXCLUDE_APS = 161; /* Sampling Exclusion: Deposit Pledge Account */	
		else if NOT(18<=age<=65) 			then FLAG_EXCLUDE_APS = 180; /* Sampling Exclusion: Fail Age Requirement */	
		else if NOT(18<=kage<=65) 			then FLAG_EXCLUDE_APS = 181; /* Sampling Exclusion: Fail Age Requirement */	
		else if index(cDeclin_all,"33")>=1	then FLAG_EXCLUDE_APS = 200; /* Sampling Exclusion: Incomplete/Insufficient information */	
		else if cIncTyp = ""				then FLAG_EXCLUDE_APS = 220; /* Sampling Exclusion: Fail Income Requirement or Cannot Provide Income Proof */	
		else if index(cdev,"23")>=1 		then FLAG_EXCLUDE_APS = 221; /* Sampling Exclusion: Fail Income Requirement or Cannot Provide Income Proof */
		else if index(cDeclin_all,"37")>=1	then FLAG_EXCLUDE_APS = 222; /* Sampling Exclusion: Fail Income Requirement or Cannot Provide Income Proof */	
		else if index(cDeclin_all,"54")>=1	then FLAG_EXCLUDE_APS = 223; /* Sampling Exclusion: Fail Income Requirement or Cannot Provide Income Proof */	
		else if index(cdev,"10")>=1 		then FLAG_EXCLUDE_APS = 240; /* Sampling Exclusion: Internal Negative Hit in Other Business Area */	
		else if index(cdev,"11")>=1 		then FLAG_EXCLUDE_APS = 241; /* Sampling Exclusion: Internal Negative Hit in Other Business Area */	
		else if index(cDeclin_all,"01")>=1 	then FLAG_EXCLUDE_APS = 242; /* Sampling Exclusion: Internal Negative Hit in Other Business Area */	
		else if fNegApp	= 1					then FLAG_EXCLUDE_APS = 260; /* Sampling Exclusion: Customer in Blacklist */	
		else if index(cDeclin_all,"02")>=1 	then FLAG_EXCLUDE_APS = 280; /* Sampling Exclusion: Bankruptcy Hit */	
		else if cpubstat > 0				then FLAG_EXCLUDE_APS = 281; /* Sampling Exclusion: Bankruptcy Hit */	
		else if index(cdev,"13")>=1 		then FLAG_EXCLUDE_APS = 282; /* Sampling Exclusion: Bankruptcy Hit */	
		else if index(cDeclin_all,"13")>=1 	then FLAG_EXCLUDE_APS = 300; /* Sampling Exclusion: Existing Customer with Poor Credit Performance */	
		else if index(cDeclin_all,"32")>=1 	then FLAG_EXCLUDE_APS = 301; /* Sampling Exclusion: Existing Customer with Poor Credit Performance */	
		else if index(cdev,"31")>=1 		then FLAG_EXCLUDE_APS = 302; /* Sampling Exclusion: Existing Customer with Poor Credit Performance */
		else if index(cdev,"12")>=1 		then FLAG_EXCLUDE_APS = 320; /* Sampling Exclusion: Exceed Total Credit Exposure */
		else if index(cDeclin_all,"38")>=1 	then FLAG_EXCLUDE_APS = 321; /* Sampling Exclusion: Exceed Total Credit Exposure */
		else if index(cDeclin_all,"36")>=1 	then FLAG_EXCLUDE_APS = 340; /* Sampling Exclusion: False/Fraud Application - Suspicious Fraud */
		else if cfraud = 1					then FLAG_EXCLUDE_APS = 341; /* Sampling Exclusion: False/Fraud Application - Suspicious Fraud */
	end;

	format 
		dapp_rec	yymmdds10.
		dapp_com	yymmdds10.
		dbirth		yymmdds10.
		DTI_pct		comma20.2
	;
	keep 
		n_APSref	/* Application Reference Key */	
		cCardTyp	/* Card/Loan Type */
		dapp_rec	/* Application Received Date */
		dapp_com	/* Application Completed Date */
		cSex		/* Sex */
		cNation		/* Nationality */
		cMarital	/* Marital Status */
		cRes_sts	/* Lack of OLD APS mapping description */
		dbirth		/* Date of Birth */
		kno_dep		/* No. of dependent */
		amthInst	/* MIL Instal./ Rental Expense */
		cedu_Lv		/* Educational Level */
		mth_Residen	/* Year & Month of residence */
		cResult		/* Approval decision status */
		cDecline1
		cDecline2
		cOccup		/* Occupation */
		cPost		/* Position */
		cPhVerf		/* Phone Verification Status */
		aOthInc		/* Other Income (Monthly or Yearly basis) */
		aReqLnAmt	/* Required Loan Amt */	
		cCamp		/* Campaign Code */

		kyr_prof	/* Year of Profession */
		kmo_pos		/* Year & Month of Position */
		ade_inc		/* Declared Monthly Income */
		fSef_Emp	/* Self Employed Indicator */
		Apr_Inc		/* Proven Monthly Income */
		acrtlmt		/* New Proposed credit card limit */
		amthInst	/* MIL Instal./ Rental Expense */
		aAprInsL	/* Final Instalment Limit */
		Tenor		/* Tenor */
		nBkscore	/* TU: Bank Score */
		cBkRisk1	/* TU: Bank Risk Rating */
		cPPDAc		/* TU: Past Due account count (only in NAPS) */
		cr_exp_cnt  /* TU: Open Account Count */
		cpubstat	/* TU: Public Record */
		kenqalrt	/* TU: Enquiry Alert Count */
		xRevAc1		/* TU: EX Revoloving Account Count */
		xTotInst1	/* TU: EX Total Installment Amount */
		xTotCR1		/* TU: EX Total Credit Limit */
		xTotUsed1	/* TU: EX Total Used Credit Limit */
		xRevPPD1	/* TU: EX Revolving Past Due Amount */
		xPastAc1	/* TU: EX Loan Account Count */
		xTotAmt1	/* TU: EX Total Loan Amount */
		xTotos1		/* TU: EX Total OS */
		xPPD1		/* TU: EX Total Loan Past Due Amount */
		kage		/* Age */
		tu_rc_min
		tot_mth_deb
		DTI_pct

		IND_SRC
		IND_PRODUCT
		IND_DEBIT_AC
		FLAG_EXCLUDE_APS
		;
run;
proc sort data=FACT.APS_Factors; by n_APSref; run;

