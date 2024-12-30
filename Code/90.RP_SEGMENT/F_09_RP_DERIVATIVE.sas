data MART.RP_04_DERI_&st_Rptmth.;
	set STG.RP_04_DERI_&st_Rptmth.;

	length	RWA_ST0		- RWA_ST3	8;
	length	RW_ST0		- RW_ST3	8;
	length	CRM_ST0		- CRM_ST3	8;
	
	array a_npldta		{4}	_temporary_ (&der_npl0.		&der_npl1.		&der_npl2. 		&der_npl3.);
	array a_curr_mult	{4}	_temporary_ (&der_multi0. 	&der_multi1.	&der_multi2. 	&der_multi3.);

	array a_crm 		CRM_ST0		- CRM_ST3;
	array a_rw 			RW_ST0		- RW_ST3;
	array a_rwa 		RWA_ST0		- RWA_ST3;
	array a_crm_npl 	CRM_NPL_ST0	- CRM_NPL_ST3;
	array a_rwa_npl		RWA_NPL_ST0	- RWA_NPL_ST3;;
	array a_ead			EAD_ST0		- EAD_ST3;

	/* Because value of CCF in CAR table is not for OTC derivative, please refer to TABLE 11 (i.e. p81) of Capital Rule getting the proper value */
	/* Cannot Replicate the Potential Amt due to CCF not correct:
		RWA of OTC derivative  = Credit Equivalent Amount * RW
		where 
			Credit Equivalent Amount (CEA) 	= Current Exposure + Potential Exposure
			Potential Exposure 				= prinicpial(i.e.CUR_BAL_OFF_HKE) *CCF
			
		t_POTENT_EXP_AMT_HKE	=CUR_BAL_OFF_HKE*CCF/100; 
		t_CUR_EXP_AMT_HKE		=CUR_EXP_AMT_HKE;
		t_CREDIT_EQU_AMT_HKE	=t_POTENT_EXP_AMT_HKE+t_CUR_EXP_AMT_HKE;
		t_RWA_HKE				=t_CREDIT_EQU_AMT_HKE*APPL_RISK_WEIGHT/100;
	*/
	/* 
		For B18 is the Repo Case, the risk weight is based on the rating of counterparty; Not stressed these cases.
		Since Before CRM and after CRM may different due to migitation and splitting to several transactions,
	   	Ratio of Before CRM / After CRM is applied after stress testing 
	*/
	EAD			= APPL_CRM_AMT_HKE;/*sum(POTENT_EXP_AMT_HKE,CUR_EXP_AMT_HKE);*/
	a_crm(1)	= APPL_CRM_AMT_HKE;
	a_rw(1)		= APPL_RISK_WEIGHT;
	a_rwa(1)	= RISK_WEIGHTED_AMT_HKE;
	a_ead(1)	= EAD;


	do i=2 to dim(a_rw);
		if PORT_CD ne "B18" and FILE_SRC not in ("COMBINED-DERV" "CONSOLID-DERV") then do;
			a_ead(i)	= EAD;
			t_NPL_TAR	= sum(a_npldta(i), 0); *Actual NPL Ratio (with Base);

			/* Since Collateral mitigation exist in derivative for orig_crm <> appl_crm, 
			   clean portion is identified as without coll_acct_id,and secured portion is identified as with coll_acct_id?
			   Only unsecured portion would be stressed.
				For example:
				account 1,  transaction 1, 			 CEA of AC=100, appl_crm_b4_stress=70, appl_crm_af_stress=100*2.5-(100-70)=220; 
				account 1,  transaction 2 with coll, CEA of AC=100, appl_crm_b4_stress=20, appl_crm_af_stress=20;
				account 1,  transaction 3 with coll, CEA of AC=100, appl_crm_b4_stress=10, appl_crm_af_stress=10; 
			*/
			if APPL_CRM_AMT_HKE ne ORIG_CRM_AMT_HKE then do;
				if not missing(COLL_ACCT_ID) then do; 
					a_crm(i)	= APPL_CRM_AMT_HKE;
					a_rw(i)		= APPL_RISK_WEIGHT;
					a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
				end;
				else do;
					t_crm		= sum(CUR_EXP_AMT_HKE*a_curr_mult(i),POTENT_EXP_AMT_HKE) - (ORIG_CRM_AMT_HKE-APPL_CRM_AMT_HKE);
					a_crm(i)	= t_crm*(1-t_NPL_TAR);
					a_rw(i)		= APPL_RISK_WEIGHT;
					a_rwa(i)	= a_crm(i)*a_rw(i)/100;
					a_crm_npl(i)= t_crm*t_NPL_TAR;
					a_rwa_npl(i)= a_crm_npl(i)*1.5;
				end;
			end;
			else do;
				/* NPL ratio is not the delta, no need to add back the actual base NPL */
				t_crm		= sum(CUR_EXP_AMT_HKE*a_curr_mult(i),POTENT_EXP_AMT_HKE);
				a_crm(i)	= t_crm*(1-t_NPL_TAR);
				a_rw(i)		= APPL_RISK_WEIGHT;
				a_rwa(i)	= a_crm(i)*a_rw(i)/100;
				a_crm_npl(i)= t_crm*t_NPL_TAR;
				a_rwa_npl(i)= a_crm_npl(i)*1.5;
			end;
		end;
		else do;
			a_crm(i)	= APPL_CRM_AMT_HKE;
			a_rw(i)		= APPL_RISK_WEIGHT;
			a_ead(i)	= EAD;
			a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		end;
	end;
	format RWA_: CRM_ST: comma30.2;
	drop i t_NPL_TAR t_crm;
run;	
