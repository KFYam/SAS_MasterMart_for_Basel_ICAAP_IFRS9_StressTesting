proc format;
value resid
0-<1 		= "a. < 1 year"
1-<5 		= "b. >= 1 year to 5 years"
5-<10 		= "c. >= 5 years to 10 years"
10-<20 		= "d. >= 10 years to 20 years"
20-high 	= "e. >= 20 years"
;
run;
proc format;
value $cq
"IG" = "a. IG"
"HY & NR" = "b. HY & NR";
run;


%let fact=fact.bis_b4crm_overall_&st_Rptmth.;
/* Data for Part A1*/
data CSRBB_A1_OnBal;
	set &fact.;
	if substr(flagbis,1,2)="ON";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	BIS_CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));

	/* Added on 03 Apr 2014 15:00 based on Stella's comments to exclude the below port cd for reporting */
	if ORIG_PORT_CD in ("X19b" "X19c" "X19d" "X19e" "20e")	then FLAG_BIS_DELETE=1; *the non-credit obligation exposure (equity, fixed assets and other assets) should be excluded.;
	if ORIG_PORT_CD = "VIII" and ORIG_RISK_WEIGHT=0 		then FLAG_BIS_DELETE=2.1;
	if ORIG_PORT_CD = "VIII" and ORIG_RISK_WEIGHT=100		then FLAG_BIS_DELETE=2.2; * the cash and gold bullion under the CAR worksheet for Class VIII - Cash items of 11 and 14 should also be excluded.;

	keep 
		FLAG_BIS_DELETE
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR FLAG_RESIDMAT
		ENTITY ACCT_ID ORIG_PORT_CD CURR_CD ORIG_RISK_WEIGHT
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		ORIG_CRM_AMT_HKE BIS_CRM_AMT_HKE;
run;
data CSRBB_A1_OnBal_Adj_addon;
	BIS_CQ="HY & NR";
	BIS_SECTOR_TYP="7. Other";
/*	BIS_RES_MAT_YEAR=20;*/
	BIS_RES_MAT_YEAR=0;
	ORIG_RISK_WEIGHT=100;
	ORIG_CRM_AMT_HKE=3114; * which is between from Basel Return =206138900830 and Actual=206138897716.9;
run;
data CSRBB_A1_OnBal_v1;
	set CSRBB_A1_OnBal CSRBB_A1_OnBal_Adj_addon;
run;

ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A1_OnBal.xls";
title "CSRBB Part A1) Original CRM HK Amount in On-Balance Item (ALL)";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table BIS_CQ=" "*BIS_SECTOR_TYP=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run; 

title "CSRBB Part A1) Original CRM HK Amount in On-Balance Item (Excluded Case)";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table BIS_CQ=" "*BIS_SECTOR_TYP=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
	where not missing(FLAG_BIS_DELETE);
run; 


ods html close;

proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class ORIG_PORT_CD ORIG_RISK_WEIGHT BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table ORIG_PORT_CD=" "*ORIG_RISK_WEIGHT=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
	where not missing(FLAG_BIS_DELETE);
run; 


data CSRBB_A1_OffBal;
	set &fact.;
	if substr(flagbis,1,3)="OFF";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	BIS_CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR FLAG_RESIDMAT
		ENTITY ACCT_ID ORIG_PORT_CD CURR_CD ORIG_RISK_WEIGHT
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		ORIG_CRM_AMT_HKE BIS_CRM_AMT_HKE;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A1_OffBal.xls";
title "CSRBB Part A1) Original CRM HK Amount in Off-Balance Item";
proc tabulate data=CSRBB_A1_OffBal 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table BIS_CQ=" "*BIS_SECTOR_TYP=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run; 

title "CSRBB Part A1) Original CRM HK Amount with CCF in Off-Balance Item";
proc tabulate data=CSRBB_A1_OffBal 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR;
	var BIS_CRM_AMT_HKE;
	table BIS_CQ=" "*BIS_SECTOR_TYP=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*BIS_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*BIS_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run; 
ods html close;


/*data CSRBB_A1_OnBal_X19d;*/
/*	set &fact.;*/
/*	if ORIG_PORT_CD="X19d";*/
/*run;*/
/*ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A1_X19.xls";*/
/*title "CSRBB Part A1) Original Port CD= X19d Original CRM HK Amount ";*/
/*proc tabulate data=CSRBB_A1_OnBal_X19d */
/*	ORDER=FORMATTED noseps missing formchar='|-' style=printer;*/
/*	class BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR;*/
/*	var ORIG_CRM_AMT_HKE;*/
/*	table BIS_CQ=" "*BIS_SECTOR_TYP=" " ALL="Total", */
/*		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";*/
/*	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;*/
/*run; */
/*ods html close; */

proc format;
value rw_f
0 			="a. 0%"
0<-12		="b. > 0% and = 12%"
12<-20		="c. > 12% and = 20%"
20<-50		="d. > 20% and = 50%"
50<-75 		="e. > 50% and = 75%"
75<-100		="f. > 75% and = 100%"
100<-425	="g. > 100% and = 425%"
425<-1250	="h. > 425% and = 1250%"
;
run;

ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A2_OnBal.xls";
title "CSRBB Part A2) Original CRM HK Amount in On-Balance Item by Risk Weight";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class ORIG_RISK_WEIGHT BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table ORIG_RISK_WEIGHT=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ORIG_RISK_WEIGHT rw_f.;
run; 

title "CSRBB Part A2) Original CRM HK Amount in On-Balance Item by Risk Weight (Exclusion part)";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class ORIG_RISK_WEIGHT BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table ORIG_RISK_WEIGHT=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ORIG_RISK_WEIGHT rw_f.;
	where not missing(FLAG_BIS_DELETE);
run; 
ods html close;



ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A2_OffBal.xls";
title "CSRBB Part A1) Original CRM HK Amount with CCF in Off-Balance Item";
proc tabulate data=CSRBB_A1_OffBal 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class ORIG_RISK_WEIGHT BIS_RES_MAT_YEAR;
	var BIS_CRM_AMT_HKE;
	table ORIG_RISK_WEIGHT=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*BIS_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*BIS_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ORIG_RISK_WEIGHT rw_f.;
run; 
ods html close;





ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A3_OnBal.xls";
title "CSRBB Part A3) Original CRM HK Amount in On-Balance Item by Currency";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class CURR_CD BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table CURR_CD=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ;
run; 

title "CSRBB Part A3) Original CRM HK Amount in On-Balance Item by Currency - Exclusion";
proc tabulate data=CSRBB_A1_OnBal_v1 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class CURR_CD BIS_RES_MAT_YEAR;
	var ORIG_CRM_AMT_HKE;
	table CURR_CD=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*ORIG_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*ORIG_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ;
	where not missing(FLAG_BIS_DELETE);
run; 

ods html close;

ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_A3_OffBal.xls";
title "CSRBB Part A3) Original CRM HK Amount with CCF in Off-Balance Item";
proc tabulate data=CSRBB_A1_OffBal 
	ORDER=FORMATTED noseps missing formchar='|-' style=printer;
	class CURR_CD BIS_RES_MAT_YEAR;
	var BIS_CRM_AMT_HKE;
	table CURR_CD=" " ALL="Total", 
		  BIS_RES_MAT_YEAR=" "*BIS_CRM_AMT_HKE=" "*SUM=" " ALL="Total"*BIS_CRM_AMT_HKE=" "*SUM=" "/rts=20 misstext="0";
	format BIS_RES_MAT_YEAR resid. ;
run; 
ods html close;




/* Breakdown - Checking the Residual Maturity > 20 years */
data bk_CSRBB_A1_OnBal;
	set &fact.;
	if substr(flagbis,1,2)="ON";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	BIS_CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
run;
data bk_CSRBB_A1_OnBal_Adj_addon;
	BIS_CQ="HY & NR";
	BIS_SECTOR_TYP="7. Other";
	BIS_RES_MAT_YEAR=0;
	ORIG_RISK_WEIGHT=100;
	ORIG_CRM_AMT_HKE=3114; * which is between from Basel Return =206138900830 and Actual=206138897716.9;
run;
data bk_CSRBB_A1_OnBal_yr20;
	set bk_CSRBB_A1_OnBal bk_CSRBB_A1_OnBal_Adj_addon;
	if BIS_RES_MAT_YEAR>=20;
run;


data bk_CSRBB_A1_OffBal;
	set &fact.;
	if substr(flagbis,1,3)="OFF";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	BIS_CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	if BIS_RES_MAT_YEAR>=20;
run;



data BASE;
	set fact.bis_b4crm_overall_201312 bk_CSRBB_A1_OnBal_Adj_addon;
/*	if BIS_RES_MAT_YEAR>=20 and substr(flagbis,1,4) ne "DERV";*/
run;
PROC EXPORT DATA= BASE
            OUTFILE= "d:\base.csv" 
            DBMS=csv REPLACE;
RUN;
