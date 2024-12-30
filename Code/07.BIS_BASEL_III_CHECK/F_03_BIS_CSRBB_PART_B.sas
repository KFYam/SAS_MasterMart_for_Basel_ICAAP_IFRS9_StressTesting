%let fact=fact.Bis_b4crm_overall_201312;

proc format;
value cq
0-<1="a. 0-<1"
1-<5="b. 1-<5"
5-<10="c. 5-<10"
10-<20="d. 10-<20"
20-high="e. >=20"
;
run;


%macro chkfigure(src=);
proc sql;
	select sum(sum(cur_bal_on_hke,cur_bal_off_hke)) as CUR_ONOFF format comma32.,
	sum(orig_crm_amt_hke) as CRM format comma32.
	from &src.;
quit;
%mend;



/* ****************************************************************************************** */
/* ****************************************************************************************** */
/* ****************************************************************************************** */
/*Debt Securities */
data ds1017012;		
	set fact.bis_b4crm_overall_201312;	
	where bal_ogl_acct="1017001"; 
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;

%chkfigure(src=ds1017012); /* ok! 12,927,180.55 to 12,927,112 due to currency rate */
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_1_1017012.xls";
title "CSRBB Part B - GL = 1017012";
proc print data=ds1017012;run;
ods html close;



data ds1007002;		
	set fact.bis_b4crm_overall_201312;	
	where bal_ogl_acct="1007002"; 
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_2_1007002.xls";
title "CSRBB Part B - GL = 1007002";
proc print data=ds1007002;run;
ods html close;
%chkfigure(src=ds1007002); /* ok! */



data ds1007005;		
set fact.bis_b4crm_overall_201312;	
where bal_ogl_acct="1007005"; 
run;
proc sort data=ds1007005 out=ds_prodsysref(keep=prod_sys_ref) nodupkey; by prod_sys_ref;run;
proc sql noprint;
	create table ds1007005_repo as
	select a.* from fact.bis_b4crm_overall_201312 a inner join ds_prodsysref b
	on a.prod_sys_ref=b.prod_sys_ref;
quit;
data ds1007005_repo_V1;
set ds1007005_repo;
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_3_1007005.xls";
title "CSRBB Part B - GL = 1007005";
proc print data=ds1007005_repo_V1;run;
ods html close;

%chkfigure(src=ds1007005_repo); /* only similar */



data ds1016002;		
set fact.bis_b4crm_overall_201312;	
where bal_ogl_acct="1016002"; 
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_4_1016002.xls";
title "CSRBB Part B - GL = 1016002";
proc print data=ds1016002;run;
ods html close;

%chkfigure(src=ds1016002); /* ok! */



data ds1019003;		set fact.bis_b4crm_overall_201312;	where bal_ogl_acct="1019003"; run;
proc sort data=ds1019003 out=ds_prodsysref(keep=prod_sys_ref) nodupkey; by prod_sys_ref;run;
proc sql noprint;
	create table ds1019003_repo as
	select a.* from fact.bis_b4crm_overall_201312 a inner join ds_prodsysref b
	on a.prod_sys_ref=b.prod_sys_ref
	where a.bal_ogl_acct not in ("1016002" "1017001" "1127035");
quit;
data ds1019003_repo_V1;
	set ds1019003_repo;
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_5_1019003.xls";
title "CSRBB Part B - GL = 1019003";
proc print data=ds1019003_repo_v1;run;
ods html close;
%chkfigure(src=ds1019003_repo); /* only similar */


data ds1007005_sgp;		
	set fact.bis_b4crm_overall_201312; 
	where entity="SGP" and ACCT_ID="1007005" and port_cd="Ib";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_6_ds1007005_sgp.xls";
title "CSRBB Part B - GL = ds1007005_sgp";
proc print data=ds1007005_sgp;run;
ods html close;



data ds_us;
	set fact.bis_b4crm_overall_201312;
	where Appl_cd in ("LA LOAN" "NY LOAN") and 
	left(trim(FAC_TYP))="DEBT SECURITIES - FI";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_7_ds_us.xls";
title "CSRBB Part B - GL = ds_us";
proc print data=ds_us;run;
ods html close;

data ds_mc;
	set fact.bis_b4crm_overall_201312;
	where Appl_cd in ("MC LOAN") and 
	left(trim(FAC_TYP))="DEBT SECURITIES - FI";
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_8_ds_mc.xls";
title "CSRBB Part B - GL = ds_mc";
proc print data=ds_mc;run;
ods html close;


data ds_cbic;
	set fact.bis_b4crm_overall_201312;
	where acct_id in (
		"130219"
		"120220"
		"100236"
		"130409"
		"130407"
		"110410"
		"100415"
		"120301"
		"110322"
		"110306"
	);
	ORIG_CRM_AMT_HKE=int(sum(ORIG_CRM_AMT_HKE,0.5));
	CRM_AMT_HKE=int(sum(BIS_CRM_AMT_HKE,0.5));
	keep 
		bal_ogl_acct
		BIS_CQ BIS_SECTOR_TYP BIS_RES_MAT_YEAR
		ACCT_ID ORIG_PORT_CD 
/*		CURR_CD ORIG_RISK_WEIGHT*/
		CUR_BAL_ON_HKE CUR_BAL_OFF_HKE
		CRM_AMT_HKE;
	format BIS_RES_MAT_YEAR resid. BIS_CQ $cq.;
run;
ods html file="&dir_rpt.\06.BIS_BASEL_III_Check\CSRBB_B_9_ds_cbic.xls";
title "CSRBB Part B - GL = ds_cbic";
proc print data=ds_cbic;run;
ods html close;

%chkfigure(src=ds_cbic); /*ok*/
/* ************************************************************************************ */
data ds_all_key;
	set 
		ds1017012 (in=a1)
		ds1007002 (in=a2)
		ds1007005_repo (in=a3)
		ds1016002 (in=a4)
		ds1019003_repo (in=a5)
		ds1007005_sgp (in=a6)
		ds_us (in=a7)
		ds_mc (in=a8)
		ds_cbic (in=a9)
	;
	if a1 then FLAG_DS=1;
	if a2 then FLAG_DS=2;
	if a3 then FLAG_DS=3;
	if a4 then FLAG_DS=4;
	if a5 then FLAG_DS=5;
	if a6 then FLAG_DS=6;
	if a7 then FLAG_DS=7;
	if a8 then FLAG_DS=8;
	if a9 then FLAG_DS=9;
	keep acct_id orig_port_cd flag_ds;
run;
proc sort data=ds_all_key; 
	by acct_id orig_port_cd; 
run; 
/*data aak;*/
/*	set ds_all_key;*/
/*	by acct_id orig_port_cd;*/
/*	if first.orig_port_cd ne last.orig_port_cd;*/
/*run;*/
/*proc freq data=ds1019003_repo;*/
/*table bal_ogl_acct /missing;*/
/*run;*/

proc sort data=&fact. out=tmp; by acct_id orig_port_cd; run;
data ds_all_check;
	merge tmp ds_all_key;
	by acct_id orig_port_cd;
	if 	not missing(flag_ds) or 
 		substr(alco_prod_cd,1,3) ="AFS" or  
 		substr(icaap_prod_cd,1,3) ="AFS" or
		ACCT_PROD = "FI" or
		FAC_TYP in ("SECUR|FI" "DEBT SECURITIES - FI")
	;
run;	
data ds_all_check_miss;
	set ds_all_check;
	if missing(flag_ds);
run;

proc freq data=fact.bis_b4crm_overall_201312;
table ICAAP_BUS_UNIT;
run;

data ram;
	set fact.bis_b4crm_overall_201312;
	where bal_ogl_acct="1017011";
run;
