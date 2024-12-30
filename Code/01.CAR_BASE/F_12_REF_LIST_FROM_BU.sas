/* ******************************************************************************************** */
/* ******************************************************************************************** */
data ref_list;
	retain TYPE "C";
	set stg.Ref_list_&st_RptMth.;
	FMTNAME="ref_bu";
	START=left(trim(FAC_REF));
	label="#~#";
	keep FMTNAME TYPE START LABEL ;
run;
proc sort data=ref_list nodupkey; by FMTNAME TYPE START LABEL; run;
proc format cntlin=ref_list; run;

