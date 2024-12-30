%macro notchlookup(fmtname, label);
	data notchlookup (keep=FMTNAME TYPE START LABEL HLO);
		length START LABEL $20;
		set siw.xls_master_scale_pd;
		FMTNAME	="&fmtname.";
		TYPE	='I';
		HLO		='I';
		START	=NOTCH;
		LABEL	=&label.;
	run;
	proc format cntlin=notchlookup; run;
%mend;
%notchlookup(pd_f, PD_AVG);
%notchlookup(rw_l, rw_long);
%notchlookup(rw_s, rw_short);

%put &lgd_fi0.;
%put &lgd_fi1.;
%put &lgd_fi2.;
%put &lgd_fi3.;


data MART.STICAAP_04_BANK_FI_&st_Rptmth.;
	set STG.STICAAP_04_BANK_FI_&st_Rptmth.;

	length 	NOTCH_ST0	- NOTCH_ST3	8;
	length	EL_ST0		- EL_ST3	8;
	length	PD_ST0		- PD_ST3	8;
	length	RWA_ST0		- RWA_ST3	8;
	length	RW_ST0		- RW_ST3	8;
	length	CRM_ST0		- CRM_ST3	8;
	
	array a_nh_delta	{4}	_temporary_ (&st_notch0.	&st_notch1. &st_notch2. &st_notch3.);
	array a_lgd			{4}	_temporary_ (&lgd_fi0. 		&lgd_fi1. 	&lgd_fi2. 	&lgd_fi3.);
	array a_nh 			NOTCH_ST0	- NOTCH_ST3;
	array a_el 			EL_ST0		- EL_ST3;
	array a_pd 			PD_ST0		- PD_ST3;

	array a_rwa 		RWA_ST0		- RWA_ST3;
	array a_rw 			RW_ST0		- RW_ST3;
	array a_crm 		CRM_ST0		- CRM_ST3;
	array a_ead 		EAD_ST0		- EAD_ST3;
	
	NOTCH_ST0=NOTCH;

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;


	do i=1 to dim(a_nh);
		a_nh(i)		=sum(NOTCH_ST0,a_nh_delta(i));
		a_ead(i)	=EAD;
		
		if PORT_CD in ("IV" "V") and IND_BUS_UNIT ne "CONSOL ADJ" then do; /* on-balance case */
			a_rw(i)	= ifn(SHORT_TERM_CLAIM_IND='Y', input(a_nh(i), rw_s.), input(a_nh(i), rw_l.) ); 
			if i=1 then a_rw(i) = APPL_RISK_WEIGHT;
		end;
		else do; /* off-balance case ; Not stress */
			a_rw(i)	= APPL_RISK_WEIGHT;
			a_nh(i) = a_nh(1);
		end; 

		if a_rw(i) < APPL_RISK_WEIGHT then a_rw(i) = APPL_RISK_WEIGHT;

		if PORT_CD not in ("IV" "V") then t_CCF=CCF/100; else t_CCF=1; /* => Only for off-balance Exposure */
		a_pd(i) 	=input(a_nh(i),pd_f.);
		a_rwa(i)	=APPL_CRM_AMT_HKE*a_rw(i)/100*t_CCF; 
		a_el(i) 	=APPL_CRM_AMT_HKE*a_pd(i)*a_lgd(i)*t_CCF;
		a_crm(i)	=APPL_CRM_AMT_HKE;
	end;
	drop i t_ccf;
run;
/* Note:
For NPL of Banking & FI, based on historical worse scenarios show no default exists, 
so we assume no default under stressed; Further, no LGD for Banking and FI; besides 
IA for Bank & FI are not necessary.
*/
