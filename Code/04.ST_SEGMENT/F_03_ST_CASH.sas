
data MART.STICAAP_02_CASH_&st_Rptmth.;
	set STG.STICAAP_02_CASH_&st_Rptmth.;

	length	RWA_ST0		- RWA_ST3	8;
	length	RW_ST0		- RW_ST3	8;
	length	CRM_ST0		- CRM_ST3	8;
	
	array a_rwa 		RWA_ST0		- RWA_ST3;
	array a_rw 			RW_ST0		- RW_ST3;
	array a_crm 		CRM_ST0		- CRM_ST3;
	array a_ead 		EAD_ST0		- EAD_ST3;
	array a_lngwth	{4}	_temporary_ (&loangwth0. &loangwth1. &loangwth2. &loangwth3.);

	if substr(PORT_CD,1,1)="B" then 
		EAD=APPL_CRM_AMT_HKE*CCF/100; 
	else 
		EAD=APPL_CRM_AMT_HKE;

	do i=1 to dim(a_rwa);
		a_ead(i)	=EAD;
		a_rw(i) 	=APPL_RISK_WEIGHT;
		a_rwa(i)	=RISK_WEIGHTED_AMT_HKE;
		a_crm(i)	=APPL_CRM_AMT_HKE;

		if substr(PORT_CD,1,1) ne "B" and IND_BUS_UNIT ne "CONSOL ADJ" then do; /* on-balance case */
			a_crm(i)	= (1+a_lngwth(i))*APPL_CRM_AMT_HKE;
			a_rwa(i)	= (1+a_lngwth(i))*RISK_WEIGHTED_AMT_HKE;
			a_ead(i)	= (1+a_lngwth(i))*EAD;
		end;
		
	end;
	drop i ;
run;

