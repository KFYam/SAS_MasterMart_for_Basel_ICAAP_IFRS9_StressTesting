/* Below parameters are generated from the SAS program of M_01_NPL_RATIO_BY_BU.sas */

%put &npl_bu_RML.;

proc sort data=STG.STICAAP_05_RML_&st_Rptmth. out=st_icaap_rml;by ACCT_ID; run;
proc sort data=siw.vi_cmv_aclevel_&st_RptMth. out=cmv_aclevel;	by ACCT_ID; run;

data MART.STICAAP_05_RML_&st_Rptmth.;
	merge st_icaap_rml(in=a) cmv_aclevel(in=b);
	by acct_id; 
	if a;

	array a_hkcclyoy{4}		_temporary_ (&hkccl_yoy0.	&hkccl_yoy1. 	&hkccl_yoy2. 	&hkccl_yoy3.);
	array a_cncclyoy{4}		_temporary_ (&cnccl_yoy0.	&cnccl_yoy1. 	&cnccl_yoy2. 	&cnccl_yoy3.);
	array a_hk_haircut{4}	_temporary_ (&hk_haircut0.	&hk_haircut1. 	&hk_haircut2. 	&hk_haircut3.);
	array a_cn_haircut{4}	_temporary_ (&cn_haircut0.	&cn_haircut1. 	&cn_haircut2. 	&cn_haircut3.);
	array a_npldta	{4}		_temporary_ (&npl_rml0.		&npl_rml1. 		&npl_rml2. 		&npl_rml3.);
	array a_lgd	{4}			_temporary_ (&lgd_rml0.		&lgd_rml1. 		&lgd_rml2. 		&lgd_rml3.);
	array a_lngwth	{4}		_temporary_ (&loangwth0. 	&loangwth1. 	&loangwth2. 	&loangwth3.);

	array a_cmv			CMV_ST0				- CMV_ST3;
	array a_cltv		CLTV_ST0			- CLTV_ST3;

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

	/* For ICAAP purpose */
	array b_cov_ratio	ICAAP_COV_RATIO0	- ICAAP_COV_RATIO3;
	array b_crm_npl_s	ICAAP_crm_npl_s0	- ICAAP_crm_npl_s3;
	array b_crm_npl_c	ICAAP_crm_npl_c0	- ICAAP_crm_npl_c3;


	if CMV_HKE in ( 0, .) and ORIG_LTV_RATIO > 0 then 
		CMV_HKE =APPL_CRM_AMT_HKE/(ORIG_LTV_RATIO/100); * Adjustment for missing CMV;

	if CMV_HKE > 0 then a_cltv(1)= APPL_CRM_AMT_HKE/CMV_HKE*100; 	else a_cltv(1)=CUR_LTV_RATIO;

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE; 

	a_ead(1)	= EAD*(1+a_lngwth(1));
	a_cmv(1)	= CMV_HKE*(1+a_lngwth(1));
	a_crm(1)	= APPL_CRM_AMT_HKE*(1+a_lngwth(1));
	a_rw(1)		= APPL_RISK_WEIGHT*(1+a_lngwth(1));
	a_rwa(1)	= RISK_WEIGHTED_AMT_HKE*(1+a_lngwth(1));
	
	do i=2 to dim(a_hkcclyoy);
		t_NPL_TAR	= a_npldta(i)+ &npl_bu_RML.; *Actual NPL Ratio (with Base);
		t_APPL_CRM	= (1+a_lngwth(i))*APPL_CRM_AMT_HKE;
		a_crm(i)	= t_APPL_CRM;
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_ead(i)	= EAD;

		if IND_BUS_UNIT ne "CONSOL ADJ" then do;
			if IND_BUS_UNIT in ("CBIC" "WBG-REF") then
				t_ccldiscount=(1+a_cncclyoy(i))*(1-a_cn_haircut(i));
			else
				t_ccldiscount=(1+a_hkcclyoy(i))*(1-a_hk_haircut(i)); 
			

			if substr(PORT_CD,1,1)="B" then 
				t_CCF=CCF/100; 
			else 
				t_CCF=1; /* => Only for off-balance Exposure */

			a_cmv(i)		= a_cmv(1)*t_ccldiscount;
			a_cltv(i)		= a_cltv(1)/t_ccldiscount; 

			if a_cltv(i) in (0 .) and a_cmv(i) > 0 then	do;
				a_cltv(i)	= t_APPL_CRM/a_cmv(i)*100;
			end;
			if a_cltv(i) > 0 then do;
				t_cov_ratio	= min(max(0,1/(a_cltv(i)/100)),1);	/* where 1/LTV = collateral coverage ratio; bound between 0 and 1*/
			end;
			else do;
				t_cov_ratio	 = 0;
			end;

			a_crm(i)		= t_APPL_CRM*(1-t_NPL_TAR);			/* which peforming (loan or CRM) */ 
			a_crm_npl(i)	= t_APPL_CRM*t_NPL_TAR;				/* which impaired (loan or CRM) */ 

			t_CRM_NPL_SECUR	= a_crm_npl(i)*t_cov_ratio;  
			t_CRM_NPL_CLEAN	= a_crm_npl(i)*(1-t_cov_ratio);

	
			a_ia(i)			= t_CRM_NPL_CLEAN*t_CCF*a_lgd(i);
			/* For Peforming Portion */
			a_rwa(i)		= a_crm(i)*a_rw(i)/100*t_CCF;
			
			/* For non-Peforming Portion */
			a_rwa_npls(i)	= t_CRM_NPL_SECUR * 1*t_CCF; * where 1 mean 100% RW;
			a_rwa_nplc(i)	= sum(t_CRM_NPL_CLEAN*t_CCF,-a_ia(i))*1.50; * where 150 mean 150% RW;
			a_rwa_npl(i)	= sum(a_rwa_npls(i),a_rwa_nplc(i));

			/* Only applying for RML and Non-RML cases but exclude SOV, PSE, DEVIATIVE and CASH segments */
			a_ead(i)			= a_crm(i)*t_CCF;
			/* For GRI Purpose */
			a_EAD_NPL_SECUR(i)	= t_CRM_NPL_SECUR*t_CCF;
			a_EAD_NPL_CLEAN(i)	= t_CRM_NPL_CLEAN*t_CCF;
			a_ead_npl(i)		= sum(a_EAD_NPL_SECUR(i),a_EAD_NPL_CLEAN(i),-a_ia(i));

		end;
	end;
	drop i t_NPL_TAR t_CCLDISCOUNT t_cov_ratio t_CRM_NPL_: t_APPL_CRM t_CCF; 
	format RWA_: CRM_ST: CRM_NPL_: IA_: comma30.2;
run;

/*
potential problem : transactions with orig_port_cd="IX" and port_cd="II4" are stressed from RW=20 to RW=100
where II4 is PSE

proc freq data=stg.ST_D_RML_&st_RptMth.;
table orig_port_cd*port_cd/missing;
run;

*/


