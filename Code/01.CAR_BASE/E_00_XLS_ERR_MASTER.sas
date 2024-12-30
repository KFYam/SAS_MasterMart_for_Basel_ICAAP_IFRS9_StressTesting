PROC IMPORT OUT = siw.XLS_ST_MANUAL_MASTER_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="Manual_Adj";
/*	SCANTEXT=YES;*/
/*	USEDATE=YES;*/
/*	SCANTIME=YES;*/
run;
PROC IMPORT OUT = siw.XLS_ST_PARAMETER_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="ST_Parameter";
run;
PROC IMPORT OUT = siw.XLS_CBIC_BANK_CUST_ID_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="CBIC_Bank_Mapping";
run;

/* For ICAAP purpose */
PROC IMPORT OUT = siw.XLS_ST_PARM_ICAAP_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="ST_Parameter_ICAAP";
run;

/* For RST purpose */
PROC IMPORT OUT = siw.XLS_RST_PARM_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="RST_Parameter";
run;

/* For RP purpose */
PROC IMPORT OUT = siw.XLS_RP_PARM_&st_rptmth.
	DATAFILE="&dir_xls.\ST_Manual_Master.xls" 
	DBMS=XLS REPLACE;
	SHEET="RP_Parameter";
run;


