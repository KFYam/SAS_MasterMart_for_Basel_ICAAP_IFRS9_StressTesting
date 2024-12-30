%let lgd_st		=0.45;
%let notch_st1	=3;
%let notch_st2	=11;

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


data MART.BKFI_ST_BASE_&st_Rptmth.;
	set FACT.BKFI_ST_BASE_&st_Rptmth.;
	if FLAG_BK_FI ne . and FLAG_DELETE=. and FLAG_ELIM=.;

	NOTCH_ST0	= NOTCH;
	NOTCH_ST1	= sum(NOTCH, &notch_st1.);
	NOTCH_ST2	= max(NOTCH, &notch_st2.);

	PD_ST0		= input(NOTCH,pd_f.);
	PD_ST1		= input(NOTCH_ST1,pd_f.);
	PD_ST2		= input(NOTCH_ST2,pd_f.);
	
	RW_ST0		= APPL_RISK_WEIGHT;
	RW_ST1		= input(NOTCH_ST1,rw_l.);
	RW_ST2		= input(NOTCH_ST2,rw_l.);

	if PORT_CD in ('B1','B2','B3','B4','B5','B6','B7','B8','B9a','B9b','B9c') then t_CCF=CCF/100; else t_CCF=1;

	EL_ST0		=APPL_CRM_AMT_HKE*t_CCF*PD_ST0*&lgd_st.;
	EL_ST1		=APPL_CRM_AMT_HKE*t_CCF*PD_ST1*&lgd_st.;
	EL_ST2		=APPL_CRM_AMT_HKE*t_CCF*PD_ST2*&lgd_st.;

	RWA_ST0		=RISK_WEIGHTED_AMT_HKE;
	RWA_ST1		=APPL_CRM_AMT_HKE*t_CCF*RW_ST1/100;
	RWA_ST2		=APPL_CRM_AMT_HKE*t_CCF*RW_ST2/100;

	GRP_NAM		=ifc(not missing(trimn(GROUP_NAME)), GROUP_NAME, CUST_NAME);

run;
	
