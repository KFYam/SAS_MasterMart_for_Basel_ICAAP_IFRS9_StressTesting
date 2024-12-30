data 
	STG.RST_01_HK_RML_&st_Rptmth.
	STG.RST_02_HK_PRTY_INVnDEV_&st_Rptmth.
	STG.RST_03_BANK_FI_&st_Rptmth.
	STG.RST_04_DERI_&st_Rptmth.
	STG.RST_05_NBMCE_&st_Rptmth.
	STG.RST_06_PASTDUE_&st_Rptmth.
	STG.RST_99_OTH_&st_Rptmth.
	;
	set MART.RST_CRM_RWA_FACT_&st_Rptmth.;
	if 		ORIG_PORT_CD = "IX" and FILE_SRC ne "CBIC"									then output STG.RST_01_HK_RML_&st_Rptmth.;			/* Only HK segments */
	else if IND_PROPERTY_INV_n_DEV = 1 													then output STG.RST_02_HK_PRTY_INVnDEV_&st_Rptmth.;	/* Only HK segments */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("04. Bank" "05. Securities Firm") 	then output STG.RST_03_BANK_FI_&st_Rptmth.; 		
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("14. Derivative") 					then output STG.RST_04_DERI_&st_Rptmth.;
	else if IND_NBMCE_GRP = 1 and IND_AFS ne 1 											then output STG.RST_05_NBMCE_&st_Rptmth.; 			/* Excluding AFS(i.e. Debt securities), banking exposure, derivative */
	else if put(IND_BASEL_ASSET_CLASS,$portcd.) in ("12. PastDue" "13. Other") 			then output STG.RST_06_PASTDUE_&st_Rptmth.; 			
	else 																					 output STG.RST_99_OTH_&st_Rptmth.;
run;
