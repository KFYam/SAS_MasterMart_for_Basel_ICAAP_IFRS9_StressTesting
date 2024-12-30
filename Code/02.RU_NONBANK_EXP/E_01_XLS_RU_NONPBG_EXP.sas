%let yymm	=%SYSFUNC(putn(&dt_RptMth.,yymmn4.));
%let xls_ru	=derek_&yymm..xls;

/* where RU stands for Risk Status Update */
PROC IMPORT OUT = siw.xls_RU_NONBK_IBG_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\&xls_ru." DBMS=XLS REPLACE; 
	SHEET="OV Branch"; 	
RUN;
PROC IMPORT OUT = siw.xls_RU_NONBK_WBGHK_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\&xls_ru." DBMS=XLS REPLACE; 
	SHEET="WBG HK"; 	
RUN;
PROC IMPORT OUT = siw.xls_RU_NONBK_WBGCBIC_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\&xls_ru." DBMS=XLS REPLACE; 
	SHEET="WBG CBIC"; 	
RUN;


