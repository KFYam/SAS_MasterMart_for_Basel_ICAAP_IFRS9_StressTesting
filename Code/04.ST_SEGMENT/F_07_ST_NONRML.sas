

%macro genSTTable(bu=, type=);

	%let npl0		=&&npl_&bu.0.;
	%let npl1		=&&npl_&bu.1.;
	%let npl2		=&&npl_&bu.2.;
	%let npl3		=&&npl_&bu.3.;

	%let nplcov0	=&&nplcov_&bu.0.;
	%let nplcov1	=&&nplcov_&bu.1.;
	%let nplcov2	=&&nplcov_&bu.2.;
	%let nplcov3	=&&nplcov_&bu.3.;

	%let npl_bu		=&&npl_bu_&bu..;

	%let lgd0		=&&lgd_&bu.0.;
	%let lgd1		=&&lgd_&bu.1.;
	%let lgd2		=&&lgd_&bu.2.;
	%let lgd3		=&&lgd_&bu.3.;
	
	/* IMPORTNANT = For proxy to NPL SGP */
	%if &bu.=IBG_SGP and &type. ne MAS %then %do;
		%let npl0		=&npl_IBG0.;
		%let npl1		=&npl_IBG1.;
		%let npl2		=&npl_IBG2.;
		%let npl3		=&npl_IBG3.;

		%let nplcov0	=&nplcov_IBG0.;
		%let nplcov1	=&nplcov_IBG1.;
		%let nplcov2	=&nplcov_IBG2.;
		%let nplcov3	=&nplcov_IBG3.;

		%let npl_bu		=&npl_bu_IBG.;

		%let lgd0		=&lgd_IBG0.;
		%let lgd1		=&lgd_IBG1.;
		%let lgd2		=&lgd_IBG2.;
		%let lgd3		=&lgd_IBG3.;
	%end;


	data STICAAP_07_&bu.&type._&st_Rptmth.;
		set STG.STICAAP_07_NONRML_&st_Rptmth.;
		%if &bu. = WBG %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "1.0 WBG";
		%end;
		%else %if &bu. = WBG_REF %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "1.1 WBG-REF";
		%end;
		%else %if &bu. = CBIC %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "2.0 CBIC";
		%end;
		%else %if &bu. = IBG %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "3.0 IBG";
		%end;
		%else %if &bu. = IBG_SGP %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "3.1 IBG-SGP";
		%end;
		%else %if &bu. = ORR %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "4.0 PBG";
		%end;
		%else %if &bu. = BB %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "4.1 PBG-BB";
		%end;
		%else %if &bu. = CTU %then %do;
			if put(IND_BUS_UNIT,$busunit.)= "5.0 CTU";
		%end;

		array a_hkcclyoy{4}		_temporary_ (&hkccl_yoy0.	&hkccl_yoy1. 	&hkccl_yoy2. 	&hkccl_yoy3.);
		array a_cncclyoy{4}		_temporary_ (&cnccl_yoy0.	&cnccl_yoy1. 	&cnccl_yoy2. 	&cnccl_yoy3.);
		array a_hk_haircut{4}	_temporary_ (&hk_haircut0.	&hk_haircut1. 	&hk_haircut2. 	&hk_haircut3.);
		array a_cn_haircut{4}	_temporary_ (&cn_haircut0.	&cn_haircut1. 	&cn_haircut2. 	&cn_haircut3.);

		array a_npldta{4}		_temporary_ (&npl0. 		&npl1. 			&npl2.			&npl3.);
		array a_nplcov{4}		_temporary_ (&nplcov0. 		&nplcov1. 		&nplcov2.		&nplcov3.);
		array a_lgd{4}			_temporary_ (&lgd0. 		&lgd1. 			&lgd2.			&lgd3.);
		array a_lngwth{4}		_temporary_ (&loangwth0. 	&loangwth1. 	&loangwth2. 	&loangwth3.);

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
			t_NPL_TAR	= a_npldta(i)+ &npl_bu.; *Actual NPL Ratio (with Base);
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

				a_ia(i)			= t_CRM_NPL_CLEAN*a_lgd(i)*t_CCF;
				/* For Performing Portion */
				a_rwa(i)		= a_crm(i)*a_rw(i)/100*t_CCF;


				/* For GRI Purpose */
				a_EAD_NPL_SECUR(i) = t_CRM_NPL_SECUR*t_CCF;
				a_EAD_NPL_CLEAN(i) = t_CRM_NPL_CLEAN*t_CCF;


				/* For non-Performing Portion */
				a_rwa_npls(i)	= t_CRM_NPL_SECUR * 1*t_CCF; * where 1 mean 100% RW;
				a_rwa_nplc(i)	= (t_CRM_NPL_CLEAN*t_CCF-a_ia(i))*1.50; * where 150 mean 150% RW;
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
%mend;


%genSTTable(bu=WBG);
%genSTTable(bu=WBG_REF);
%genSTTable(bu=IBG);
%genSTTable(bu=IBG_SGP);
%genSTTable(bu=IBG_SGP,type=MAS); /* Specific for SGP MAS requirment */
%genSTTable(bu=CBIC);
%genSTTable(bu=BB);
%genSTTable(bu=CTU);
%genSTTable(bu=ORR);


data STICAAP_07_OTHER_&st_Rptmth.;
	set STG.STICAAP_07_NONRML_&st_Rptmth.;
	if put(IND_BUS_UNIT,$busunit.)= "6.0 OTHER";
	array a_crm			CRM_ST0			- CRM_ST3;
	array a_rw			RW_ST0			- RW_ST3;
	array a_rwa			RWA_ST0			- RWA_ST3;
	array a_ead			EAD_ST0			- EAD_ST3;

	do i=1 to dim(a_crm);
		a_crm(i)	= APPL_CRM_AMT_HKE;
		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_ead(i)	= RISK_WEIGHTED_AMT_HKE/(APPL_RISK_WEIGHT/100);
	end;
	drop i;
run;


data MART.STICAAP_07_NONRML_&st_Rptmth.;
	set 
		STICAAP_07_WBG_&st_Rptmth.	
		STICAAP_07_WBG_REF_&st_Rptmth.
		STICAAP_07_IBG_&st_Rptmth.
		STICAAP_07_IBG_SGP_&st_Rptmth.
		STICAAP_07_CBIC_&st_Rptmth.
		STICAAP_07_BB_&st_Rptmth.
		STICAAP_07_CTU_&st_Rptmth.
		STICAAP_07_ORR_&st_Rptmth.
		STICAAP_07_OTHER_&st_Rptmth.
	;
run;

/* **************************************************************************/
/* Added on 6 June 2014 - Specific for MAS requirement for SGP Portfolio	*/
/* **************************************************************************/
data MART.STMAS_07_NONRML_&st_Rptmth.;
	set STICAAP_07_IBG_SGPMAS_&st_Rptmth.;
run;
