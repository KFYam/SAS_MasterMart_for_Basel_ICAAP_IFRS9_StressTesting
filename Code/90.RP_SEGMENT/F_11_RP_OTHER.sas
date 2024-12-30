data MART.RP_99_OTH_&st_Rptmth.;
	set STG.RP_99_OTH_&st_Rptmth.;
	array a_hkcclyoy{4}		_temporary_ (&hkccl_yoy0.	&hkccl_yoy1. 	&hkccl_yoy2. 	&hkccl_yoy3.);
	array a_cncclyoy{4}		_temporary_ (&cnccl_yoy0.	&cnccl_yoy1. 	&cnccl_yoy2. 	&cnccl_yoy3.);
	array a_hk_haircut{4}	_temporary_ (&hk_haircut0.	&hk_haircut1. 	&hk_haircut2. 	&hk_haircut3.);
	array a_cn_haircut{4}	_temporary_ (&cn_haircut0.	&cn_haircut1. 	&cn_haircut2. 	&cn_haircut3.);

	array a_npldta{4}		_temporary_ (&oth_npl0. 		&oth_npl1. 		&oth_npl2.		&oth_npl3.);
	array a_nplcov{4}		_temporary_ (&oth_nplcov0. 		&oth_nplcov1. 	&oth_nplcov2.	&oth_nplcov3.);
	array a_lgd{4}			_temporary_ (&oth_lgd0. 		&oth_lgd1. 		&oth_lgd2.		&oth_lgd3.);
	array a_lngwth{4}		_temporary_ (&oth_lgth0. 		&oth_lgth1. 	&oth_lgth2. 	&oth_lgth3.);

	array a_crm			CRM_ST0				- CRM_ST3;
	array a_rw			RW_ST0				- RW_ST3;
	array a_rwa			RWA_ST0				- RWA_ST3;
	array a_rwa_npl		RWA_NPL_ST0			- RWA_NPL_ST3;
	array a_ia			IA_ST0				- IA_ST3;

	array a_crm_npl		CRM_NPL_ST0			- CRM_NPL_ST3;
	array a_rwa_nplc	RWA_NPL_CLEAN_ST0	- RWA_NPL_CLEAN_ST3;
	array a_rwa_npls	RWA_NPL_SECUR_ST0	- RWA_NPL_SECUR_ST3;
	array a_ead_npl		EAD_NPL_ST0			- EAD_NPL_ST3;
	array a_ead			EAD_ST0				- EAD_ST3;

	/* For GRI Purpose */
	array a_EAD_NPL_SECUR		EAD_NPL_SECUR_ST0 - EAD_NPL_SECUR_ST3;
	array a_EAD_NPL_CLEAN		EAD_NPL_CLEAN_ST0 - EAD_NPL_CLEAN_ST3;


	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;

	a_crm(1)	= APPL_CRM_AMT_HKE*(1+a_lngwth(1));
	a_rw(1)		= APPL_RISK_WEIGHT;
	a_rwa(1)	= RISK_WEIGHTED_AMT_HKE*(1+a_lngwth(1));
	a_ead(1)	= EAD*(1+a_lngwth(1));
		
	do i=2 to dim(a_hkcclyoy);
		t_NPL_TAR	= a_npldta(i); *Actual NPL Ratio (with Base);
		t_APPL_CRM	= APPL_CRM_AMT_HKE*(1+a_lngwth(i));
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE*(1+a_lngwth(i));
		a_ead(i)	= EAD*(1+a_lngwth(i));

		if IND_BUS_UNIT not in ("CONSOL ADJ","OFD","RAM") then do;
			if IND_BUS_UNIT in ("CBIC" "WBG-REF") then 
				t_ccldiscount=(1+a_cncclyoy(i))*(1-a_cn_haircut(i));
			else
				t_ccldiscount=(1+a_hkcclyoy(i))*(1-a_hk_haircut(i)); 

			t_NPL_coverage	= a_nplcov(i)*t_ccldiscount;

			if substr(PORT_CD,1,1)="B" then 
				t_CCF=CCF/100; 
			else 
				t_CCF=1; /* => Only for off-balance Exposure */

			a_crm(i)		= t_APPL_CRM*(1-t_NPL_TAR);			/* which performing (loan or CRM) */ 
			a_ead(i)		= a_crm(i)*t_CCF;
			a_crm_npl(i)	= t_APPL_CRM*t_NPL_TAR;				/* which impaired (loan or CRM) */ 

			t_CRM_NPL_SECUR	= a_crm_npl(i)*t_NPL_coverage;  
			t_CRM_NPL_CLEAN	= a_crm_npl(i)*(1-t_NPL_coverage);	
			/* For GRI Purpose */
			a_EAD_NPL_SECUR(i) = t_CRM_NPL_SECUR*t_CCF;
			a_EAD_NPL_CLEAN(i) = t_CRM_NPL_CLEAN*t_CCF;

			a_ia(i)			= t_CRM_NPL_CLEAN*a_lgd(i)*t_CCF;
			/* For Performing Portion */
			a_rwa(i)		= a_crm(i)*a_rw(i)/100*t_CCF;

			/* For non-Performing Portion */
			a_rwa_npls(i)	= t_CRM_NPL_SECUR * 1*t_CCF; * where 1 mean 100% RW;
			a_rwa_nplc(i)	= sum(t_CRM_NPL_CLEAN*t_CCF,-a_ia(i))*1.50; * where 150 mean 150% RW;
			a_rwa_npl(i)	= sum(a_rwa_npls(i),a_rwa_nplc(i));

			a_ead(i)			= a_crm(i)*t_CCF;
			/* For GRI Purpose */
			a_EAD_NPL_SECUR(i)	= t_CRM_NPL_SECUR*t_CCF;
			a_EAD_NPL_CLEAN(i)	= t_CRM_NPL_CLEAN*t_CCF;
			a_ead_npl(i)		= sum(a_EAD_NPL_SECUR(i),a_EAD_NPL_CLEAN(i),-a_ia(i));

		end;
	end;
	drop i t_NPL_TAR t_CCLDISCOUNT t_NPL_coverage t_CRM_NPL_: t_APPL_CRM t_CCF;
	format RWA_: CRM_ST: CRM_NPL_ST: IA_: comma30.2;
run;

