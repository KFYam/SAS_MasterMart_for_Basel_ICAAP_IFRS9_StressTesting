%macro fillArray(src=,out=);
data &out.;
	set &src.;
	array a_crm			CRM_ST0			- CRM_ST3;
	array a_rw			RW_ST0			- RW_ST3;
	array a_rwa			RWA_ST0			- RWA_ST3;
	array a_ead			EAD_ST0			- EAD_ST3;

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;

	do i=1 to dim(a_crm);
		a_crm(i)	= APPL_CRM_AMT_HKE;
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_ead(i)	= EAD;
	end;
	drop i;
run;
%mend;
%fillArray(src=STG.RST_06_PASTDUE_&st_Rptmth., 	out=MART.RST_06_PASTDUE_&st_Rptmth.);

data MART.RST_00_BASE_&st_Rptmth.;
	set 
	MART.RST_01_HK_RML_&st_Rptmth.				(in=a)
	MART.RST_02_HK_PRTY_INVnDEV_&st_Rptmth.		(in=b)
	MART.RST_03_BANK_FI_&st_Rptmth.				(in=c)
	MART.RST_04_DERI_&st_Rptmth.				(in=d)
	MART.RST_05_NBMCE_&st_Rptmth.				(in=e)
	MART.RST_06_PASTDUE_&st_Rptmth.				(in=f)
	MART.RST_99_OTH_&st_Rptmth.					(in=g)
	;
	length IND_RST_UNIT $20;
	if a then IND_RST_UNIT = "01. RML";
	if b then IND_RST_UNIT = "02. PRTY INV & DEV";
	if c then IND_RST_UNIT = "03. BANK & FI";
	if d then IND_RST_UNIT = "04. DERIVATIVE";
	if e then IND_RST_UNIT = "05. NBMCE";
	if f then IND_RST_UNIT = "06. PASTDUE";
	if g then IND_RST_UNIT = "07. OTHER";
run;



