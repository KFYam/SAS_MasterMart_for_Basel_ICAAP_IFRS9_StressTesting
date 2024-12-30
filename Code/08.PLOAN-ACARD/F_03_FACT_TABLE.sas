proc sql noprint;
	select put(max(SEQ),3.) into :cnt from FACT.PLCC_PERFORM;
	%put &cnt.;
quit;

data FACT.APS_n_PERFORM;
	merge 
		FACT.APS_FACTORS(in=aps)
		STG.PLCC_PERFORM_KEY (in=p_key)
		STG.PLCC_PERFORM_TX_ACRTLMT (in=p_lmt)
		STG.PLCC_PERFORM_TX_ACURBAL (in=p_bal)
		STG.PLCC_PERFORM_TX_IND_BAD (in=p_bad)
		STG.PLCC_PERFORM_TX_IND_MED (in=p_med)
		STG.PLCC_PERFORM_TX_KCYCDUE	(in=p_cyc)
		STG.PLCC_PERFORM_TX_KDAYDELQ(in=p_dlq)
	;
	by n_APSref;

	if aps and not p_key then FLAG_MERGE=.A;
	if not aps and p_key then FLAG_MERGE=.P;

	array bad(*) ind_bad_1-ind_bad_&cnt.; 
	array med(*) ind_med_1-ind_med_&cnt.; 
	array dlq(*) kDaydelq_1-kDaydelq_&cnt.;
	array due(*) kcycDue_1-kcycDue_&cnt.;
	IND_1ST_BAD = .;
	IND_1ST_MED = .;
	IND_RELAX_SEQ = .;
	IND_1ST_RELAX_BAD = .;

	/* ever delq >= 60 days twices */
	do i=1 to dim(dlq);
		if dlq[i]>=60 or due[i]>=4 then do;
			IND_RELAX_SEQ = sum(IND_RELAX_SEQ,1);
			if IND_1ST_RELAX_BAD=. and IND_RELAX_SEQ >=2 then IND_1ST_RELAX_BAD=i;
		end;
	end;
	if sum(of bad[*]) > 0 then do;
		do i=1 to dim(bad);	if IND_1ST_BAD = . and bad[i] > 0 then IND_1ST_BAD = i;	end;
	end;
	if sum(of med[*]) > 0 then do;
		do i=1 to dim(med);	if IND_1ST_MED = . and med[i] > 0 then IND_1ST_MED = i;	end;
	end;
	drop i IND_RELAX_SEQ;
run;
