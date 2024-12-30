/************************************************************************************/
/* BEGIN - Collect the New APS Application Data 									*/
/************************************************************************************/
/************************************************************************************/
data napp/view=napp;
	set i_naps.app;
	nAPSref=substr(nAPSref,10);
run;
proc sort data=napp out=STG.NAPS; 
	by nAPSref descending dapp_rec;
run;
/************************************************************************************/






/************************************************************************************/
/* BEGIN - Collect the Old APS Application Data  									*/
/************************************************************************************/
/************************************************************************************/
proc sort data= i_oaps.app_all out=OAPS;
	by nAPSref descending crmdActn descending dapp_rec;
run;
proc sort data= i_oaps.recommend_all out=OAPS_RECOMM_ALL(keep=nAPSref crmdActn crmdRea);
	by nAPSref descending crmdActn crmdRea;
run;
proc transpose data=OAPS_RECOMM_ALL OUT=OAPS_RECOMM_ALL_TX;
	by nAPSref descending crmdActn ;
	var crmdRea;
run;

data OAPS_RECOMM_ALL_TX1;
	set OAPS_RECOMM_ALL_TX;
	by nAPSref descending crmdActn ;
	crmdRea=catx(" ", of COL:);
	keep nAPSref crmdActn crmdRea;
run;

data STG.OAPS;
	merge OAPS(in=a) OAPS_RECOMM_ALL_TX1;
	by nAPSref descending crmdActn ;
	if a;
run;
/************************************************************************************/
