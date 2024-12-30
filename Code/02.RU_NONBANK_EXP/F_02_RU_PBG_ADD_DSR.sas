/* ----------------------------------------------------------------------------------------- */
/* STAGE 1: Add all the APS reference and adjustment into the PBG Base table				 */
/* ----------------------------------------------------------------------------------------- */
/* START - Add APS reference into RBG_Base table											 */
data card_pil;
	set 
	siw.pil_&st_RptMth.(keep=ncard cOrg nAPSref aXfer2) /*where aXfer2=interest rate*/
	siw.card_&st_RptMth.(keep=ncard cOrg nAPSref )
	;
run;
/* START - Checking average interest rate of existing record */
proc sql;
	select avg(axfer2) as avg_AXFER2 from card_pil where not missing(axfer2);
quit;
/* END - Checking average interest rate of existing record */

proc sort 
	data=card_pil 
	out=stg.APS_Ref_&st_RptMth.(rename=(ncard=acct_id)) nodupkey;
	by ncard;
run;
proc sort 
	data=stg.aps_dsr_adj_&st_RptMth. 
	out=aps_dsr_adj_&st_RptMth.;
	by ncard input_dt;
run;

data aps_dsr_adj1_&st_RptMth.(
	drop=Input_DT
	rename=(
		ncard=ACCT_ID
		nAPSref=nAPSref_adj 
		DSR=DSR_adj 
		TENOR=TENOR_adj 
		BKS_Score=BKS_Score_adj 
		CMS_score=CMS_Score_adj
));
	set aps_dsr_adj_&st_RptMth.;
	by ncard;
	if last.ncard then output;

run;
/* END - Add APS reference into RBG_Base table												 */
/* ----------------------------------------------------------------------------------------- */

proc sort 
	data=siw.pbg_rbg_base_&st_RptMth. 
	out=pbg_rbg_base_&st_RptMth.; 
	by acct_id; 
run; 
data pbg_rbg_base1_&st_RptMth.; 
	merge 
		pbg_rbg_base_&st_RptMth.(in=a) 
		stg.APS_Ref_&st_RptMth.(in=b) 
		aps_dsr_adj1_&st_RptMth.(in=c)
	; 
	by acct_id;
	if a;
	if not missing(nAPSref_adj) then nAPSref=nAPSref_adj;
run;

/* ----------------------------------------------------------------------------------------- */
/* STAGE 2: Add all the DSR from System APS 												 */
/* ----------------------------------------------------------------------------------------- */
data stg.app_combine ;
	set siw.app_combine (keep=nAPSref cOrg cltext2 Tenor CCARDTYP cBkRisk1 cBkRisk2 cOccup cPost ade_inc apr_inc);

	if CCARDTYP in ('667' '668') and cOrg = ' ' then corg = '222';

	/* check numeric from text field for grabbing the DSR */
	if not missing(cltext2) and missing(compress(cltext2,"0123456789. ","")) then do;
		DSR = input(trim(left(cltext2)),32.);
	end;

	nAPSref		= substr(nAPSref,10,7);
	BKS_Score	= cBkRisk1;
	CMS_Score	= cBkRisk2;
	de_income	= ade_inc;
	pr_income	= apr_inc;

	keep
		DSR
		nAPSref
		cOrg
		Tenor 
		BKS_Score
		CMS_Score 
		cOccup
		cPost
		de_income
		pr_income
	;
run;

/* Specially for PLOC case */
data stg.app_combine_ploc(keep=dLstUpd cstext2 cltext2 nAPSref ACCT_ID DSR Tenor BKS_Score CMS_Score de_income pr_income);
	set siw.app_combine ;
	where cCardtyp='996' and not missing (cstext2) ;
	
	key=trim(compress(cstext2,"- ",""));

	ACCT_ID="18100"||substr(key,1,3)||"00000"||substr(key,4,9);

	/* check numeric from text field for grabbing the DSR */
	if not missing(cltext2) and missing(compress(cltext2,"0123456789. ","")) then do;
		DSR = input(trim(left(cltext2)),32.);
	end;

	BKS_Score	= cBkRisk1;
	CMS_Score	= cBkRisk2;
	de_income	= ade_inc;
	pr_income	= apr_inc;

run;
proc sort data=stg.app_combine_ploc; by acct_id descending dlstupd; run;
proc sort data=stg.app_combine_ploc out=app_combine_ploc nodupkey; by acct_id; run;

/* ----------------------------------------------------------------------------------------- */
/* STAGE 3: Add System APS with DSR information into PBG Base								 */
/* ----------------------------------------------------------------------------------------- */
proc sql noprint;
	create table pbg_rbg_base2_&st_RptMth. as 
	select a.*, b.*
	from pbg_rbg_base1_&st_RptMth. a left join stg.app_combine b
	on a.COrg = b.cOrg and a.nAPSref = b.nAPSref;
quit;

/* Must use merge because some of fields are already in PBG_BASE2 */
proc sort data=pbg_rbg_base2_&st_RptMth.; 	
	by ACCT_ID; 
run;

data pbg_rbg_base3_&st_RptMth.;
	merge pbg_rbg_base2_&st_RptMth.(in=a) app_combine_ploc (in=b drop=dLstUpd cstext2 cltext2 nAPSref);
	by ACCT_ID;
	if a;
run;

/* ----------------------------------------------------------------------------------------- */
/* STAGE 4: Update DSR adj from PBG into information brought from System APS 				 */
/* ----------------------------------------------------------------------------------------- */
data FACT.pbg_base_with_DSR_&st_RptMth.;
	set pbg_rbg_base3_&st_RptMth.;
	if not missing(DSR_adj) 		then 	DSR = DSR_adj;
	if not missing(Tenor_adj) 		then 	Tenor = Tenor_adj;
	if not missing(BKS_Score_adj) 	then 	BKS_Score = BKS_Score_adj;
	if not missing(CMS_Score_adj) 	then 	CMS_Score = CMS_Score_adj;

run;

/*proc freq data=pbg_rbg_base3_&st_RptMth.;*/
/*	table DSR /missing;*/
/*run;*/
