%let st_RptYYMM		=%SYSFUNC(putn(&dt_RptMth.,yymmn4.));
%let yymm			=%SYSFUNC(putn(&dt_RptMth.,yymmn4.));
%let yymmdd			=%SYSFUNC(putn(&dt_RptMth.,yymmddn6.));

data siw.pbg_rbg_base_&st_RptMth.;
	set pbg.rbg_base_&st_RptYYMM.;
run;

data siw.pbg_taxi_dist_&st_RptMth.;
	set pbg.taxi_dist_&yymm.;
run;

data siw.pbg_taxi_stress_&st_RptMth.;
	set pbg.taxi_stress&yymm.;
run;

/*data siw.ccd_segment_&st_RptMth.;*/
/*	set ccd.SEGMENT&yymmdd.;*/
/*run;*/
