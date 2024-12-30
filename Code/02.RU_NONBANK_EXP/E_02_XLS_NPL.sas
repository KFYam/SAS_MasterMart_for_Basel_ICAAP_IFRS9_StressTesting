%let yymm	=%SYSFUNC(putn(&dt_RptMth.,yymmn4.));
%let xls_npl=Criticized Accounts List_&yymm..xls;

PROC IMPORT OUT = xls_NPL_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\&xls_npl." DBMS=XLS REPLACE; 
RUN;

data siw.xls_NPL_&st_Rptmth.;
	set xls_NPL_&st_Rptmth.;
	if missing(NAME) or substr(NAME,1,5)="Note:" then delete;

	* Due to match with Risk Update overall NPL ratio, CBI_CHINA_CUST_SEC_ID would not be counted; 
	*if trim(left(CUST_SEC_ID)) = "na" then CUST_SEC_ID = CBI_CHINA_CUST_SEC_ID;
	if trim(left(CUST_SEC_ID)) = "na" then CUST_SEC_ID="";
run;
