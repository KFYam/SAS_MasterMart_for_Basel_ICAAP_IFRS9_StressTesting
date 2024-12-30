%macro getNS_CRM(field);
	data ns_&field.;
		set stg.nonsystem_&st_Rptmth.;
		if not missing(PORT_CD) and not missing(&field.);
		ENTITY 				="CNCBI";
		APPL_CD				="&field.";
	
		if find(PORT_CD,"_Y_") > 0 then SHORT_TERM_CLAIM_IND = "Y";

		tmp1				=compress(tranwrd(tranwrd(PORT_CD,trim(left(put(RISKWEIGHT,3.))),""),"_Y_","")," _");

		ORIG_PORT_CD 		=tmp1;
		PORT_CD				=tmp1;
		ORIG_RISK_WEIGHT	=RISKWEIGHT;
		APPL_RISK_WEIGHT	=RISKWEIGHT;
		ORIG_CRM_AMT_HKE	=&field.*1000;
		APPL_CRM_AMT_HKE	=&field.*1000;
		RISK_WEIGHTED_AMT_HKE=APPL_CRM_AMT_HKE*APPL_RISK_WEIGHT/100;
		keep
		ENTITY
		APPL_CD
		ORIG_PORT_CD
		PORT_CD
		ORIG_RISK_WEIGHT
		APPL_RISK_WEIGHT
		ORIG_CRM_AMT_HKE
		APPL_CRM_AMT_HKE
		RISK_WEIGHTED_AMT_HKE
		SHORT_TERM_CLAIM_IND
		;
	run;
%mend;

/* ********************************************************************* */
/* Combined Figures Adjustment Handling 								 */
/* ********************************************************************* */
%getNS_CRM(LOCAL);
%getNS_CRM(LA);
%getNS_CRM(NY);
%getNS_CRM(SHANGHAI);
%getNS_CRM(MACAU);
%getNS_CRM(SINGAPORE);
%getNS_CRM(VIEWCON);
%getNS_CRM(COMBINEDADJ);

data stg.adj_ns_combined_delta_&st_Rptmth.;
	length ENTITY APPL_CD ORIG_PORT_CD PORT_CD $60;
	set 
	ns_LOCAL
	ns_LA
	ns_NY
	ns_SHANGHAI
	ns_MACAU
	ns_SINGAPORE
	ns_VIEWCON
	ns_COMBINEDADJ
	;
	FILE_SRC ="NS_COMBINED"; /* Non-system T/B Adjustment */
run;
/* Sense Checking
proc sql;
	select orig_port_cd, orig_risk_weight,
	sum(ORIG_CRM_AMT_HKE)
	from  stg.Adj_ns_combined_delta_&st_Rptmth.
	group by orig_port_cd, orig_risk_weight
	;
quit;
*/

/* ********************************************************************* */
/* Subsidiaries Figures Adjustment Handling 							 */
/* ********************************************************************* */
%getNS_CRM(KWIMFG);
%getNS_CRM(CIBL);
%getNS_CRM(CBICHINALTD);
%getNS_CRM(KWBANKTRUSTEELTD);
%getNS_CRM(KWBMGTLTD);
%getNS_CRM(FULLSHINEHLDGLTD);
%getNS_CRM(CARDFOLDINTLLTD);
%getNS_CRM(CKWBSNLTD);

data stg.adj_ns_subsidiaries_delta_&st_Rptmth.;
	length ENTITY APPL_CD ORIG_PORT_CD PORT_CD $60;
	set 
		ns_KWIMFG
		ns_CIBL
		ns_CBICHINALTD
		ns_KWBANKTRUSTEELTD
		ns_KWBMGTLTD
		ns_FULLSHINEHLDGLTD
		ns_CARDFOLDINTLLTD
		ns_CKWBSNLTD
	;
	FILE_SRC ="NS_SUBSIDIARIES"; /* Non-system T/B Adjustment */
run;
/* Sense Checking
proc sql;
	select orig_port_cd, orig_risk_weight,
	sum(ORIG_CRM_AMT_HKE)
	from  stg.Adj_ns_subsidiaries_delta_&st_Rptmth.
	group by orig_port_cd, orig_risk_weight
	;
quit;
*/

/* ********************************************************************* */
/* Consolidated Figures Adjustment Handling 							 */
/* ********************************************************************* */
%getNS_CRM(CONSOLADJBEFORECRM);

data stg.adj_ns_consolid_crm_delta_&st_Rptmth.;
	length ENTITY APPL_CD ORIG_PORT_CD PORT_CD $60;
	set ns_CONSOLADJBEFORECRM;
	FILE_SRC ="NS_CONSOLID_CRM_ADJ"; /* Non-system T/B Adjustment */
run;
