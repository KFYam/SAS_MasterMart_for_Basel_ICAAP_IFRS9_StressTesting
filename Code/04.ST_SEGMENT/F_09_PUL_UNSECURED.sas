/* Derived from file of F_02_RU_PBG_EXP.sas */

%put &npl_00dpd_pul;
%put &npl_30dpd_pul;
%put &npl_60dpd_pul;
%put &npl_90dpd_pul;

%let lgd=1; /*LGD for unsecured PUL = 100%*/

/*
DELQ_BUCKET=M0 is 0 day pastdue
DELQ_BUCKET=M1 is 1-30 days pastdue
DELQ_BUCKET=M2 is 31-60 days pastdue
DELQ_BUCKET=M3 is 61-90 days pastdue
DELQ_BUCKET>=M4 is already default (NPL)

/*
proc freq data=STG.STHKMA_02_PUL_&st_Rptmth.;
	table DAYS_PASTDUE DELQ_BUCKET LOAN_CLASS_CD /missing;
	where missing(FLAG_DELETE_PUL);
run;
*/

data MART.STHKMA_02_PUL_&st_Rptmth.;
	set STG.STHKMA_02_PUL_&st_Rptmth.;

	array a_lngwth{4}		_temporary_ (&loangwth0.	&loangwth1.		&loangwth2.		&loangwth3.);
	array a_lgd{4}			_temporary_ (&lgd.			&lgd. 			&lgd. 			&lgd.);
	array a_crm				CRM_ST0				- CRM_ST3;
	array a_rw				RW_ST0				- RW_ST3;
	array a_rwa				RWA_ST0				- RWA_ST3;
	array a_rwa_npl			RWA_NPL_ST0			- RWA_NPL_ST3;
	array a_ca				CA_ST0				- CA_ST3;

	array a_crm_npl			CRM_NPL_ST0			- CRM_NPL_ST3;
	array a_rwa_nplc		RWA_NPL_CLEAN_ST0	- RWA_NPL_CLEAN_ST3;
	array a_ead_npl			EAD_NPL_ST0			- EAD_NPL_ST3;
	array a_ead				EAD_ST0				- EAD_ST3;

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;
	
	a_crm(1)	= APPL_CRM_AMT_HKE;
	a_rw(1)		= APPL_RISK_WEIGHT;
	a_rwa(1)	= RISK_WEIGHTED_AMT_HKE;
	a_ead(1)	= EAD;

	do i=2 to dim(a_crm);
		if 		DELQ_BUCKET="M0" then t_NPL_TAR	= &npl_00dpd_pul.; 
		else if DELQ_BUCKET="M1" then t_NPL_TAR	= &npl_30dpd_pul.; 
		else if DELQ_BUCKET="M2" then t_NPL_TAR	= &npl_60dpd_pul.; 
		else if DELQ_BUCKET="M3" then t_NPL_TAR	= &npl_90dpd_pul.; 
		else t_NPL_TAR	= 1; /* supposed the remaining should be >= M4 */
		
		a_crm(i)	= APPL_CRM_AMT_HKE;
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_ead(i)	= EAD;
		t_APPL_CRM	= (1+a_lngwth(i))*APPL_CRM_AMT_HKE;

		if substr(PORT_CD,1,1)="B" then t_CCF=CCF/100; 
		else t_CCF=1; /* => Only for off-balance Exposure */

		if IND_BASEL_ASSET_CLASS ne "XI" then do;				/* Only stress for performing account; some original past due accounts have M0 but DF that need not to be stressed */
			a_crm(i)		= t_APPL_CRM*(1-t_NPL_TAR);			/* which performing (loan or CRM) */ 
			a_crm_npl(i)	= t_APPL_CRM*t_NPL_TAR;				/* which impaired (loan or CRM) */ 
			a_ead_npl(i)	= t_APPL_CRM*t_NPL_TAR*t_CCF;
			t_CRM_NPL_CLEAN	= a_crm_npl(i);
			a_ca(i)			= t_CRM_NPL_CLEAN*a_lgd(i)*t_CCF;

			/* For Performing Portion */
			a_rwa(i)		= a_crm(i)*a_rw(i)/100*t_CCF;

			/* For non-Performing Portion */
			a_rwa_nplc(i)	= (t_CRM_NPL_CLEAN-a_ca(i)) *1.50*t_CCF; * where 150 mean 150% RW;
			a_ead(i)		= sum(a_crm(i),t_CRM_NPL_CLEAN, -a_ca(i) )*t_CCF;
			a_rwa_npl(i)	= a_rwa_nplc(i);
		end;

		drop i t_NPL_TAR t_CRM_NPL_: t_APPL_CRM t_CCF;
		format RWA_: CRM_ST: CRM_NPL_ST: CA_: comma30.2;
	end;
run;

/* Note: IA and CA for PBG 		
Since some products need IA while some need CA when impaired, then we first generally classify products of PBG into 
2 sets which are i) Secured related products such as Mortgage Loan and ii) Unsecured related products such as Credit Card.
We need to further classify SME and non-SME from product type ii, and IA is needed for SME subsegment and CA for non-SME 
subsegment.

In short,
Impaired Loan for secured product type 				-> IA
Impaired Loan for SME in unsecured product type  	-> IA 
Impaired Loan for non-SME in unsecured product type -> CA
*/
