/* ------------------------------------------------- */
/* a.Import the REF fac_ref list which are collected EL monthly information excel */
PROC IMPORT OUT = stg.REF_List_&st_Rptmth.
	DATAFILE="&dir_xls.\WBG_&st_Rptmth.\REF_List_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;

data stg.REF_List_&st_Rptmth.;
	set stg.REF_List_&st_Rptmth.;
	where not missing(FAC_REF);
run;

