/* ************************************************************************** */
/* Short listed x-variables and transform the x-variable before 			  */
/* Initial Characteristic Analysis											  */	
/* ************************************************************************** */
%let dt_SmpBgn 	= "01SEP2005"d; /* Sample Window Start Date */
%let dt_SmpEnd 	= "01SEP2011"d; /* Sample Window Completed Date */
%let mth_PerfW	= 12;			/* No of months of Performance Window */

data MART.PLOAN_ACARD;
	set FACT.APS_n_PERFORM;
	where 
	&dt_SmpBgn. < dapp_rec < &dt_SmpEnd. and 	/* 4 Years Sampling Windows */
	FLAG_MERGE in(.A .) and 					/* Application with/without performance data */
	IND_PRODUCT = 20							/* P-Loan case */
	;  				
	IND_BAD = ifn( 0<IND_1st_BAD<=&mth_PerfW. , 1, 0);
	IND_MED = ifn( 0<IND_1st_MED<=&mth_PerfW. , 1, 0);

	FLAG_ALL_EXCLUDED = .;
	if FLAG_ALL_EXCLUDED=. and FLAG_EXCLUDE_APS ne .				then FLAG_ALL_EXCLUDED=2; /* Sampling Exclusion */
	if FLAG_ALL_EXCLUDED=. and cResult = "D"						then FLAG_ALL_EXCLUDED=3; /* Declined at approval Stage */
	if FLAG_ALL_EXCLUDED=. and cResult = "C"						then FLAG_ALL_EXCLUDED=3; /* Cancelled at approval Stage */
	if FLAG_ALL_EXCLUDED=. and FLAG_MERGE = .A						then FLAG_ALL_EXCLUDED=4; /* Without Performance Information */
	if FLAG_ALL_EXCLUDED=. and IND_BAD=0 and FLAG_EXCLUDE_PERF ne .	then FLAG_ALL_EXCLUDED=5; /* Performance Exclusion */
	if FLAG_ALL_EXCLUDED=. and IND_BAD=0 and IND_MED=1				then FLAG_ALL_EXCLUDED=6; /* Indeterminate Case */
run;
proc freq data=MART.PLOAN_ACARD;
table FLAG_ALL_EXCLUDED*IND_BAD /missing norow nocol nopct;
run;

data MART.X_VAR_MAPPING;
	length c_name x_var $255;
	c_name="cedu_Lv";		x_var="x_01"; output;
	c_name="kage";			x_var="x_02"; output;
	c_name="cSex";			x_var="x_03"; output;
	c_name="kno_dep";		x_var="x_04"; output;
	c_name="cmarital";		x_var="x_05"; output;
	c_name="cPhVerf";		x_var="x_06"; output;
	c_name="cOccup";		x_var="x_07"; output;
	c_name="cPost";			x_var="x_08"; output;
	c_name="kyr_prof";		x_var="x_09"; output;
	c_name="kmo_pos";		x_var="x_10"; output;
	c_name="mth_Residen";	x_var="x_11"; output;
	c_name="cRes_sts";		x_var="x_12"; output;
	c_name="nBkscore";		x_var="x_13"; output;
	c_name="cPPDAc";		x_var="x_14"; output;
	c_name="cr_exp_cnt";	x_var="x_15"; output;
	c_name="cpubstat";		x_var="x_16"; output;
	c_name="kenqalrt";		x_var="x_17"; output;
	c_name="xRevAc1";		x_var="x_18"; output;
	c_name="xTotInst1";		x_var="x_19"; output;
	c_name="xTotCR1";		x_var="x_20"; output;
	c_name="xTotUsed1";		x_var="x_21"; output;
	c_name="xRevPPD1";		x_var="x_22"; output;
	c_name="xPastAc1";		x_var="x_23"; output;
	c_name="xTotAmt1";		x_var="x_24"; output;
	c_name="xTotos1";		x_var="x_25"; output;
	c_name="xPPD1";			x_var="x_26"; output;
	c_name="TENOR";			x_var="x_27"; output;
	c_name="amthInst";		x_var="x_28"; output;
	c_name="ade_inc";		x_var="x_29"; output;
	c_name="Apr_Inc";		x_var="x_30"; output;
	c_name="acrtlmt";		x_var="x_31"; output;
	c_name="DTI_pct";		x_var="x_32"; output;
	c_name="tot_mth_deb";	x_var="x_33"; output;
	c_name="fSef_Emp";		x_var="x_34"; output;
	c_name="aOthInc";		x_var="x_35"; output;
	c_name="aReqLnAmt";		x_var="x_36"; output;
	c_name="aAprInsL";		x_var="x_37"; output;
	c_name="cCamp";			x_var="x_38"; output;
run;

filename xvar temp;
data _null_;
	file xvar lrecl=65535;
	set MART.X_VAR_MAPPING end=eof;
	if _n_=1 then do;
		put "DATA MART.PLOAN_ACARD_X;";
		put "	SET MART.PLOAN_ACARD (rename=(";
	end;
	put c_name "=" x_var;
	if eof then do;
		put "	));";

		/* START - Transform the x-variable for reduce the seasonality / inflation effect	*/
		/* ******************************************************************************** */

		/* X_81: Ratio of external total used amount to monthly net income					*/
		put 'if sum(max(x_29, x_30), - x_28) not in (0, .) then ';
		put 'X_81 = sum(x_19,x_21,x_22,x_25,x_26, -x_35) / ';
		put	'	sum(max(x_29, x_30), - x_28);';

 		/* X_82: Ratio of external total credit limit to applied limit or required loan 	*/
		put 'if max(x_31,x_36) not in (0, .) then ';
		put 'X_82 = x_20 / max(x_31,x_36);';

		put 'if X_81 <= 0 then X_81 = .;';
		put 'if X_82 = 0 then X_82 = .;';

		/* END - Transform the x-variable for reduce the seasonality / inflation effect		*/
		/* ******************************************************************************** */

		put 'x_07 = SUBSTR(LEFT(x_07),1,1);';
		put 'if X_08 in ("1B2" "2B3" "281") then t_X_08=X_08;';
		put 'x_08 = SUBSTR(LEFT(x_08),1,1);';
		put 'if compress(t_X_08," ") ne "" then X_08 = t_X_08;';
		put 'x_38 = SUBSTR(LEFT(x_38),1,1);';
		put "	keep N_APSREF IND_BAD cResult FLAG_: X_:;";
		put "run;";
	end;
run;
%include xvar / source2;
data MART.PLOAN_ACARD_X_ACCEPT;
	set MART.PLOAN_ACARD_X;
	where cResult not in ("C" "I" "D") and FLAG_ALL_EXCLUDED = .;
run; 
proc freq data=MART.PLOAN_ACARD_X_ACCEPT;
table IND_BAD /missing;
run;
