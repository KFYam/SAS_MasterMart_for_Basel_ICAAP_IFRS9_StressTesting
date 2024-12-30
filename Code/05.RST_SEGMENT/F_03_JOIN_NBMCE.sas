data NBMCE_KEY;
	length ACCT_ID $50 NBMCE_IND $30;
	format ACCT_ID $50. NBMCE_IND $30.;
	set 
		RST_CBIC_NBMCE (in=a keep=ACCT_ID NBMCE_IND)
		RST_HK_NBMCE (in=b keep=ACCT_ID NBMCE_IND)
		RST_OV_NBMCE (in=c keep=ACCT_ID NBMCE_IND)
		RST_CBF_NBMCE (in=d keep=ACCT_ID NBMCE_IND)
	;
	if a then FLAG_NBMCE="CBIC";
	if b then FLAG_NBMCE="HK  ";
	if c then FLAG_NBMCE="OV  ";
	if d then FLAG_NBMCE="CBF ";
run;
proc sort data=NBMCE_KEY out=stg.NBMCE_KEY nodupkey; by ACCT_ID; run;
proc sort data=fact.st_crm_rwa_fact_&st_Rptmth. out=tmp; by ACCT_ID; run;

data STG.RST_CRM_RWA_FACT_&st_Rptmth. MART.NBMCE_KEY_EXCEPTIONS;
	merge tmp(in=a) stg.NBMCE_KEY (in=b);
	by ACCT_ID;
	if a then output stg.rst_crm_rwa_fact_&st_Rptmth.;
	if not a and b then output MART.NBMCE_KEY_EXCEPTIONS;
run;
/* Those exceptions case are almost from SGP accounts, so the numsum adjustment need to be added on Excel */
/* ****************************************************************************************************** */
/* ****************************************************************************************************** */
/* ****************************************************************************************************** */
data PROPERTY_HKKEY;
	length ACCT_ID $50 MapRow $30;
	format ACCT_ID $50. MapRow $30.;
	set 
		PROPERTY_INV_DEV_LOCALOFFICE (in=a keep=ACCT_ID MapRow)
		PROPERTY_INV_DEV_HKCBF (in=b keep=ACCT_ID MapRow)
	;
	if a then FLAG_PRTY="LOCALOFFICE";
	if b then FLAG_PRTY="HKCBF      ";
run;
proc sort data=PROPERTY_HKKEY out=stg.PROPERTY_HKKEY nodupkey; by ACCT_ID; run;

data MART.RST_CRM_RWA_FACT_&st_Rptmth.(rename=(NBMCE_IND=IND_NBMCE)) MART.PROPERTY_HKKEY_EXCEPTIONS;
	merge STG.RST_CRM_RWA_FACT_&st_Rptmth. (in=a) stg.PROPERTY_HKKEY (in=b);
	by ACCT_ID;

	if not missing(MapRow) then do;
		if MapRow in ("B1a" "B1b" "B1c" "B1d" "B2a" "B2b" "B2c" "B2d" ) then IND_PROPERTY_INV_n_DEV=1;
	end;
	if ORIG_PORT_CD="IX" then IND_BASEL_RML=1;
	if not missing(NBMCE_IND) then IND_NBMCE_GRP=1;
	if a then output MART.RST_CRM_RWA_FACT_&st_Rptmth.;
	if not a and b then output MART.PROPERTY_HKKEY_EXCEPTIONS;;
run;
		

* Manual adjustment SGP NBMCE exposure;
proc sql ;
create table check_ov_nbmce_ex as
select a.*
from stg.rst_ov_nbmce_&st_rptmth. a inner join mart.nbmce_key_exceptions b
on a.acct_id=b.acct_id;
quit;
proc sql;
	select 
		sum(Total_On) as Total_On format comma30.2,
		sum(Total_Off) as Total_Off format comma30.2,
		sum(sum(Total_On,Total_Off)) as Total format comma30.2
	from check_ov_nbmce_ex;
quit;

proc sql noprint;
	create table stg.rst_crm_rwa_fact_&st_Rptmth. as
	select a.*, b.NBMCE_IND
	from fact.st_crm_rwa_fact_&st_Rptmth. a left join stg.NBMCE_KEY b
	on a.ACCT_ID=b.ACCT_ID;
quit;

proc sql noprint;
select count(1) into: cnt from (select distinct acct_id, NBMCE_IND from stg.rst_crm_rwa_fact_&st_Rptmth.) where not missing (NBMCE_IND );
quit;
%put &cnt.;

