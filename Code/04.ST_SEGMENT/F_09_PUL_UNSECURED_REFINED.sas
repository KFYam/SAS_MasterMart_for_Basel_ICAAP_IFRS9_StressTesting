

/* START Stress DSR and Re-assign the DELQ_BUCKET */
/* ************************************************************ */
proc format;
value dsr
low-30		="1"
30<-50		="2"
50<-70		="3"
70<-high 	="4"
;
run;
/* As at Q3 2014 position, the average interest rate is 8.102564;
therefore, increase of the paygment = 3/8.102564 = 37.03% */
%let DSR_mult		=1.3703; 		/* Multiplier for Stress DSR */


data STHKMA_02_PUL_wrk ;
	set STG.STHKMA_02_PUL_&st_Rptmth.(rename=(DELQ_BUCKET=DELQ_BUCKET_OLD));
	if missing(DSR) then do;
		if IAS_PROD = "PLOC" then DSR_stress = 60 * &DSR_mult.; 
		else DSR_stress = 70 * &DSR_mult.;
	end;
	else do;
		DSR_stress	= DSR * &DSR_mult.;
	end;

	DSR_Stress_Bucket = put(DSR_stress, dsr.);
	OVERALL_SEQ=_n_;

run;

%macro update_DELQMTX(dsrtype=, delqtype=);
	data tmp1;
	set STHKMA_02_PUL_wrk;
		where FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_ELIM_CONSOL=. and FLAG_DELETE_PUL=.; 
		if  DSR_Stress_Bucket= "&dsrtype." and DELQ_BUCKET_OLD="&delqtype.";
		seq=ranuni(12353546);
	run;
	proc sort data=tmp1; by seq; run;
	proc sql noprint; select count(1) into :cnt from tmp1;quit;
	
	data tmp2;
		set tmp1;
		by seq;
		proportion=_n_/&cnt.*100;

		%if &dsrtype.=1 and &delqtype.=M0 %then %do;
			/* DSR=1 , delinq = M0*/	
			if proportion <= 97.1 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 97.1 < proportion <=99.6  then DELQ_BUCKET="M1";
			else if 99.6 < proportion <=99.8  then DELQ_BUCKET="M3";
			else if 99.8 < proportion <=100   then DELQ_BUCKET="M4";
		%end;

		%if &dsrtype.=1 and &delqtype.=M1 %then %do;
			/* DSR=1 , delinq = M1*/	
			if proportion <= 90.9 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 90.9 < proportion <=100  then DELQ_BUCKET="M2";
		%end;
		
		%if &dsrtype.=2 and &delqtype.=M0 %then %do;
			/* DSR=2 , delinq = M0*/	
			if proportion <= 95.6 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 95.6 < proportion <= 99.3 then DELQ_BUCKET="M1";
			else if 99.3 < proportion <= 99.5 then DELQ_BUCKET="M2";
			else if 99.5 < proportion <= 99.9 then DELQ_BUCKET="M3";
			else if 99.9 < proportion <= 100 then DELQ_BUCKET="M5";
		%end;

		%if &dsrtype.=2 and &delqtype.=M1 %then %do;
			/* DSR=2 , delinq = M1*/	
			if proportion <= 96.8 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 96.8 < proportion <= 100 then DELQ_BUCKET="M2";
		%end;

		%if &dsrtype.=2 and &delqtype.=M2 %then %do;
			/* DSR=2 , delinq = M2*/	
			if proportion <= 80.0 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 80.0 < proportion <= 100 then DELQ_BUCKET="M3";
		%end;

		%if &dsrtype.=3 and &delqtype.=M0 %then %do;
			/* DSR=3 , delinq = M0*/	
			if proportion <= 98.0 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 98.0 < proportion <= 99.5 then DELQ_BUCKET="M1";
			else if 99.5 < proportion <= 99.8 then DELQ_BUCKET="M2";
			else if 99.8 < proportion <= 99.9 then DELQ_BUCKET="M3";
			else if 99.9 < proportion <= 100 then DELQ_BUCKET="M4";
		%end;

		%if &dsrtype.=3 and &delqtype.=M1 %then %do;
			/* DSR=3 , delinq = M1*/	
			if proportion <= 92.7 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 92.7 < proportion <= 97.6 then DELQ_BUCKET="M2";
			else if 97.6 < proportion <= 100 then DELQ_BUCKET="M3";
		%end;

		%if &dsrtype.=4 and &delqtype.=M0 %then %do;
			/* DSR=4 , delinq = M0*/	
			if proportion <= 99.2 then DELQ_BUCKET=DELQ_BUCKET_OLD;
			else if 99.2 < proportion <= 99.8 then DELQ_BUCKET="M1";
			else if 99.8 < proportion <= 100 then DELQ_BUCKET="M6";
		%end;

	run;
	proc sort data=tmp2 out=tmp3(keep=OVERALL_SEQ DELQ_BUCKET); by OVERALL_SEQ; run;
	proc sort data=STHKMA_02_PUL_wrk; by OVERALL_SEQ; run;
	data STHKMA_02_PUL_wrk;
		merge STHKMA_02_PUL_wrk(in=a) tmp3(in=b);
		by OVERALL_SEQ;
		if a;
	run;
%mend;

%update_DELQMTX(dsrtype=1, delqtype=M0);
%update_DELQMTX(dsrtype=1, delqtype=M1);
%update_DELQMTX(dsrtype=2, delqtype=M0);
%update_DELQMTX(dsrtype=2, delqtype=M1);
%update_DELQMTX(dsrtype=2, delqtype=M2);
%update_DELQMTX(dsrtype=3, delqtype=M0);
%update_DELQMTX(dsrtype=3, delqtype=M1);
%update_DELQMTX(dsrtype=4, delqtype=M0);

data STG.STHKMA_02_PUL_&st_Rptmth.;
	set STHKMA_02_PUL_wrk;
	if missing(DELQ_BUCKET) then DELQ_BUCKET=DELQ_BUCKET_OLD;
run;

title " CHECKING PURPOSE ";
proc tabulate data=STG.STHKMA_02_PUL_&st_Rptmth. missing;
	class	DSR_Stress_Bucket DELQ_BUCKET_OLD DELQ_BUCKET;
	var		OVERALL_SEQ;
	table 	DSR_Stress_Bucket=" "*DELQ_BUCKET_OLD="", 
			DELQ_BUCKET="after"*OVERALL_SEQ=""*n=" ";
run; 



