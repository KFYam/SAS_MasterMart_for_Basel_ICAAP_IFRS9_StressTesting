proc format;
	invalue port_rw 
		'Ia_0'=1
		'Ia_10'=2
		'Ib_0'=3
		'Ib_10'=4
		'Ib_20'=5
		'Ib_50'=6
		'Ib_100'=7
		'Ib_150'=8
		'Ic_0'=9
		'II4_20'=10
		'II4_50'=11
		'II4_100'=12
		'II4_150'=13
		'II5_0'=14
		'II5_10'=15
		'II5_20'=16
		'II5_50'=17
		'II5_100'=18
		'II5_150'=19
		'III_0'=20
		'IV_20'=21
		'IV_50'=22
		'IV_100'=23
		'IV_150'=24
		'IV_Y_20'=25
		'IV_Y_50'=26
		'IV_Y_100'=27
		'IV_Y_150'=28
		'V_20'=29
		'V_50'=30
		'V_100'=31
		'V_150'=32
		'VI_20'=33
		'VI_50'=34
		'VI_100'=35
		'VI_150'=36
		'VII_20'=37
		'VII_50'=38
		'X19c_100'=39
		'VII_150'=40
		'VIII_0'=41
		'VIII_100'=42
		'VIII_20'=43
		'VIIa'=44
		'VIIb'=45
		'VIIc'=46
		'VIId'=47
		'VIIe'=48
		'VII16_20'=49
		'VII16_10'=50
		'VII16_0'=51
		'VIIIa_75'=52
		'VIIIb_75'=53
		'IX_35'=54
		'IX_75'=55
		'IX_100'=56
		'X19a_100'=57
		'X19b_100'=58
		'X19d_100'=59
		'X19e_100'=60
		'XI_0'=61
		'XI_10'=62
		'XI_20'=63
		'XI_50'=64
		'XI_75'=65
		'XI_100'=66
		'XI_150'=67
		'XIII_22a_1250'=68
		'VII_15b_1250'=69
		'DUMMY_100'=70
		'IIA_2a_1250'=71
		other=99
	;
run;

data VIEW_FACT/view=VIEW_FACT;
	set FACT.ST_CRM_RWA_FACT_&st_Rptmth.;
	if PORT_CD="IV" and SHORT_TERM_CLAIM_IND="Y" then do;
		PORT_RW_NO=input(cats(PORT_CD,"_Y_",APPL_RISK_WEIGHT),port_rw.);
	end;
	else do;
		PORT_RW_NO=input(cats(PORT_CD,"_",APPL_RISK_WEIGHT),port_rw.);
	end;
run;

proc sql;
	create table SC_ONBAL_BY_PORT_RW as 
	select 
		PORT_RW_NO,PORT_CD,APPL_RISK_WEIGHT,
		sum(ORIG_CRM_AMT_HKE)/1000 as ORIG_CRM_AMT_HKE format comma30.0,
		sum(APPL_CRM_AMT_HKE)/1000 as APPL_CRM_AMT_HKE format comma30.0,
		sum(RISK_WEIGHTED_AMT_HKE)/1000 as RISK_WEIGHTED_AMT_HKE format comma30.0
	from VIEW_FACT
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		substr(PORT_CD,1,1) ne "B"
	group by PORT_RW_NO,PORT_CD,APPL_RISK_WEIGHT
	order by PORT_RW_NO;

	create table SC_ONBAL_ALL as 
	select 
		sum(ORIG_CRM_AMT_HKE) as ORIG_CRM_AMT_HKE format comma32.,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from VIEW_FACT
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_ELIM_CONSOL = . and 
		substr(PORT_CD,1,1) ne "B"
	;
quit;

proc sql;
	create table SC_ONBAL_BY_PORT_RW_SOLO as 
	select 
		PORT_RW_NO,PORT_CD,APPL_RISK_WEIGHT,
		sum(ORIG_CRM_AMT_HKE)/1000 as ORIG_CRM_AMT_HKE format comma30.0,
		sum(APPL_CRM_AMT_HKE)/1000 as APPL_CRM_AMT_HKE format comma30.0,
		sum(RISK_WEIGHTED_AMT_HKE)/1000 as RISK_WEIGHTED_AMT_HKE format comma30.0
	from VIEW_FACT
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and
		substr(PORT_CD,1,1) ne "B"
	group by PORT_RW_NO,PORT_CD,APPL_RISK_WEIGHT
	order by PORT_RW_NO;

	create table SC_ONBAL_ALL_SOLO as 
	select 
		sum(ORIG_CRM_AMT_HKE) as ORIG_CRM_AMT_HKE format comma32.,
		sum(APPL_CRM_AMT_HKE) as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE) as RISK_WEIGHTED_AMT_HKE format comma32.
	from VIEW_FACT
	where 
		FLAG_DELETE = . and  
		FLAG_ELIM_COMBIN = . and 
		FLAG_SOLO ne . and
		substr(PORT_CD,1,1) ne "B"
	;
quit;



%macro SC_Breakdown(portrw_no, out);
proc sql;
	create table &out. as 
	select 
		FILE_SRC, FLAG_ADJ, FLAG_DELETE, FLAG_ELIM_COMBIN, FLAG_ELIM_CONSOL,
		sum(ORIG_CRM_AMT_HKE)/1000 as ORIG_CRM_AMT_HKE format comma32.,
		sum(APPL_CRM_AMT_HKE)/1000 as APPL_CRM_AMT_HKE format comma32.,
		sum(RISK_WEIGHTED_AMT_HKE)/1000 as RISK_WEIGHTED_AMT_HKE format comma30.0
	from VIEW_FACT
	where  PORT_RW_NO = &portrw_no.
	group by FILE_SRC, FLAG_ADJ, FLAG_DELETE, FLAG_ELIM_COMBIN, FLAG_ELIM_CONSOL
	order by                                                                                                                                                                                            FILE_SRC, FLAG_ADJ;
quit;
%mend;
/*%SC_Breakdown(54, SC_ONBAL_IX35);*/
/*%SC_Breakdown(22, SC_ONBAL_IV50);*/
/*%SC_Breakdown(35, SC_ONBAL_VI100);*/
/*%SC_Breakdown(26, SC_ONBAL_IV_Y50);*/

/*%SC_Breakdown(21, SC_ONBAL_IV_20);*/
/*%SC_Breakdown(22, SC_ONBAL_IV_50);*/
/*%SC_Breakdown(25, SC_ONBAL_IV_Y_20);*/
/*%SC_Breakdown(26, SC_ONBAL_IV_Y_50);*/


%SC_Breakdown(49, SC_ONBAL_VII16_20);
%SC_Breakdown(1, ia);

