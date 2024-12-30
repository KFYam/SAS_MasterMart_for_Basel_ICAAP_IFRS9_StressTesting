/* ------------------------------------------------- */
/* a.Import the REF fac_ref list which are collected EL monthly information excel */
PROC IMPORT OUT = stg.APS_DSR_ADJ_&st_Rptmth.
	DATAFILE="\\ckwb505\aps-data\Yvonne_V\RBCA_MIS\CardLink nAPSref Cleansing\nAPSref_Cleansing.xls"
	DBMS=xls REPLACE;
RUN;
data stg.APS_DSR_ADJ_&st_Rptmth.;
	set stg.APS_DSR_ADJ_&st_Rptmth.;
	if missing(input_dt) or input_dt='1Jan1900'd then delete;
run;


