/* ******************************************************************************************/
/* ************************************* CBIC Section ************************************* */
data RST_CBIC_NBMCE;
	set stg.RST_CBIC_NBMCE_&st_Rptmth.(rename=(NBMCE_IND=NBMCE_IND_N));
	NBMCE_IND=compress(""||NBMCE_IND_N," ");
	keep ACCT_ID PORT_CD FAC_REF CUST_SEC_ID NBMCE_IND ON_BS_EXP OFF_BS_EXP;
run;
proc sort data=RST_CBIC_NBMCE nodupkey; by ACCT_ID; run;
/* ******************************************************************************************/
/* ************************************ HK Section ************************************ 	*/
data RST_HK_NBMCE;
	set stg.RST_HK_NBMCE_&st_Rptmth.;
	On_Exp=Part3_1p4_On_Exp;
	Off_Exp=sum(Part3_2p1_Cont_Liab, Part3_2p2_Irre_Undr_Comm, Part3_2p3_FX_n_Deri);
	keep ACCT_ID NBMCE_IND 
		Part3_1p4_On_Exp 
		Part3_2p1_Cont_Liab 
		Part3_2p2_Irre_Undr_Comm 
		Part3_2p3_FX_n_Deri
		On_Exp Off_Exp
		;
run;
proc sort data=RST_HK_NBMCE nodupkey; by ACCT_ID; run;
/* ******************************************************************************************/
/* ************************************ OV Section ************************************ 	*/
data RST_OV_NBMCE;
	set stg.RST_OV_NBMCE_&st_Rptmth.(rename=(Total_On=On_Exp Total_Off=Off_Exp NBMCE_ACCT=NBMCE_IND));
	keep ACCT_ID NBMCE_IND On_Exp Off_Exp;
run;
proc sort data=RST_OV_NBMCE nodupkey; by ACCT_ID; run;
/* ******************************************************************************************/
/* ************************************ HKCBF Sections ************************************ */
data RST_CBF_NBMCE;
	set stg.RST_CBF_NBMCE_&st_Rptmth.;
	NBMCE_IND = substr(Final_IND_NBMCE_ACCT,9);
	keep ACCT_ID NBMCE_IND BAL_HKE TOT_INT_HKE;
run;
proc sort data=RST_CBF_NBMCE nodupkey; by ACCT_ID; run;

/* Sense Checking : 
proc sql;
	select sum(sum(On_Exp,Off_Exp)) as checksum format comma32.
	from RST_HK_NBMCE;
quit;
proc sql;
	select sum(sum(On_Exp,Off_Exp)) as checksum format comma32.
	from RST_OV_NBMCE;
quit;
proc sql;
	select sum(sum(BAL_HKE,TOT_INT_HKE)) as checksum format comma32.
	from RST_CBF_NBMCE;
quit;
proc sql;
	select sum(sum(ON_BS_EXP,OFF_BS_EXP)) as checksum format comma32.
	from RST_CBIC_NBMCE;
quit;
* Sense Checking : Jun  14 - 9,863,371;
*/
