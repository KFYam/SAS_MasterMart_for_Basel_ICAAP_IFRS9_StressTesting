/* ******************************************************************************************/
/* ************************************* CBIC Section ************************************* */
DATA PROPERTY_INV_DEV_LOCALOFFICE;
	set stg.RST_CNCBI_BY_INDUSTRY_&st_Rptmth.;
	if APPL_CD="HP" then do;
		ACCT_ID=compress("01"||ACCT_PROD||ACCT_ID," ");
	end;
	/* Manual Adjustment for Jun 2014 Position */
	if ACCT_ID="1810077200000200391500" then ACCT_ID="1810072500000204514500";
	if not missing(ACCT_ID);
run;
/* HKCBF should not have the HP case, but the below logic just for the completeness purpose */
DATA PROPERTY_INV_DEV_HKCBF;
	set stg.RST_HKCBF_BY_INDUSTRY_&st_Rptmth.;
	if not missing(ACCT_ID);
run;
