/* ********************************************************** */
/* ********************************************************** */
/* BEGIN - Tranform Cardlink Performance data */
data v_Perform / view=v_Perform ;
	set STG.Perform_CRD(in=a) STG.Perform_PIL(in=b);
	where not missing(nAPSref);

	n_APSref			= input(nAPSref, best32.);
	n_Card				= input(nCard, best32.);
	n_Cust				= input(nCust, best32.);
	IND_PERMSRC 		= ifn(a=1,.C, .P);
	IND_SUPPCARD		= ifn(input(ncustAlt,best32.) > 0, 1, .);

	IND_BAD				= .;	
	IND_MED				= .; /* Intermindate case */
	FLAG_EXCLUDE_PERF	= .; 

	if missing(IND_BAD) then do;
		if kDaydelq >=90 or kcycDue >=5 					then IND_BAD = 100;		/* >= 90 days past due */
		else if index(cPriBlk,"O") >=1						then IND_BAD = 200;		/* Charge-off A/C to Collection Agent */
		else if index(cPriBlk,"Y") >=1						then IND_BAD = 201;		/* Credit Charge-off A/C */
		else if index(cPriBlk,"U") >=1	and aCurBal > 0 	then IND_BAD = 202;		/* Bankruptcy with O/S Bal > 0 */
		else if index(cPriBlk,"G") >=1						then IND_BAD = 203;		/* Closed Account to Collection Agent (Usually after involuntary Cancellation) */
		else if index(cPriBlk,"B") >=1						then IND_BAD = 204;		/* Deceased */
	end;
	if missing(IND_BAD) and missing(IND_MED) then do;
		if IND_PERMSRC=.C and index(cPriBlk,"A")>=1			then IND_MED = 200;		/* Counterfeit Card (not for P.Loan) */
		else if kDaydelq >=60 or kcycDue >=4 				then IND_MED = 201;		/* Ever 60 days past due */
		else if IND_PERMSRC=.C and index(cPriBlk,"J")>=1	then IND_MED = 202;		/* Credit Risky A/C (not for P.Loan) */
		else if IND_PERMSRC=.C and index(cPriBlk,"Q")>=1	then IND_MED = 203;		/* Voluntary Cancellation (not for P.Loan) */
		else if index(cPriBlk,"X")>=1						then IND_MED = 204;		/* Involuntary Cancellation */
	end;

	/* It should be excluded during perfromance because it is not related on creditness issue but accidental outcome */
	if missing(FLAG_EXCLUDE_PERF) then do;
		if index(cStatus,"4") >=1							then FLAG_EXCLUDE_PERF = 001;	/* Transferred Record */
		else if IND_SUPPCARD = 1							then FLAG_EXCLUDE_PERF = 002;	/* Supp. card */
		else if index(cPriBlk,"Z") >=1						then FLAG_EXCLUDE_PERF = 100;	/* Fraud Charge-off */
		else if index(cPriBlk,"F") >=1						then FLAG_EXCLUDE_PERF = 101;	/* Fraud */
		else if IND_PERMSRC=.C and index(cPriBlk,"L") >=1	then FLAG_EXCLUDE_PERF = 103;	/* Lost/Stolen A/C (only in Credit Card) */
	end;

	keep
		n_APSref
		n_Card
		n_Cust
		rpt_mth
		dopen
		dclose
		kcycDue
		kDaydelq
		cPriBlk
		cStatus
		aCurBal
		aCshBal
		aRBal
		aCrtLmt
		aRPCO
		aCACO
		cPriBlk

		IND_PERMSRC
		IND_SUPPCARD
		IND_BAD
		IND_MED
		FLAG_EXCLUDE_PERF
	;
run;
proc sort data=v_Perform out=STG.PLCC_Perform;
	by n_APSref rpt_mth FLAG_EXCLUDE_PERF cStatus;
run;

data FACT.PLCC_Perform FACT.PLCC_Perform_Dup;
	retain SEQ 0 tmp_rpt_mth 0;
	set STG.PLCC_Perform ;
	by n_Apsref rpt_mth;
	if first.n_Apsref then do;
		SEQ=0;
		tmp_rpt_mth = rpt_mth;
	end;	
	SEQ=intck("MONTH",
			input(cat(put(tmp_rpt_mth,z6.),"01"),yymmdd10.),
			input(cat(put(rpt_mth,z6.),"01"),yymmdd10.)
		)+1;
	drop tmp_rpt_mth;

	if first.rpt_mth 					then output FACT.PLCC_Perform;
	if first.rpt_mth ne last.rpt_mth 	then output FACT.PLCC_Perform_Dup;

run;

%macro TX_PILCRD(var);
	proc transpose 
		data=FACT.PLCC_Perform
		out=STG.PLCC_Perform_TX_&var.(drop=_NAME_) 
		prefix=&var._;
		var &var.;
		by n_Apsref;
		id SEQ;
	run;
%mend;
%TX_PILCRD(kcycDue);
%TX_PILCRD(kDaydelq);
%TX_PILCRD(aCurBal);
%TX_PILCRD(aCrtLmt);
%TX_PILCRD(IND_BAD);
%TX_PILCRD(IND_MED);

proc sql noprint;
	create table STG.PLCC_PERFORM_KEY as
	select 
		n_Apsref,
		max(dopen)				as dopen,
		max(dclose)				as dclose,
		min(IND_PERMSRC) 		as IND_PERMSRC,
		max(IND_SUPPCARD) 		as IND_SUPPCARD,
		max(SEQ)				as WORKOUT_PERIOD,
		max(FLAG_EXCLUDE_PERF) 	as FLAG_EXCLUDE_PERF
	from FACT.PLCC_Perform
	group by n_Apsref
	order by n_Apsref
	;
quit;				

/* **************************************************************************** */
/* Due to high resources used when browsing the content of sashelp.vstable, 	*/
/* therfore, dis-libname the i_crdk library here								*/
/*libname i_crdk;*/
