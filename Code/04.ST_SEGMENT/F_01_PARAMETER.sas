 %let src_tbl=;
%macro checkICAAP();
	%if &ind_ICAAP. = ICAAP %then %do;
		%let src_tbl=siw.xls_st_parm_ICAAP_&st_Rptmth.;
	%end;
	%else %do;
		%let src_tbl=siw.xls_st_parameter_&st_Rptmth.;
	%end;
%mend;
%checkICAAP;

data st_parameter;
	set &src_tbl.;
	where effective_from <=&dt_Rptmth.<=effective_to;
	
	if SEGMENT="FI" and TYPE="NOTCH" then do;
		call symput("st_notch0",base);
		call symput("st_notch1",mild);
		call symput("st_notch2",medium);
		call symput("st_notch3",severe);
	end;
	if upcase(SEGMENT)="HK" then do;
		if TYPE="PROPERTY_PRICE_YOY" then do;
			call symput("hkccl_yoy0",base);
			call symput("hkccl_yoy1",mild);
			call symput("hkccl_yoy2",medium);
			call symput("hkccl_yoy3",severe);
		end;
		if TYPE="PROPERTY_COLL_HAIRCUT" then do;
			call symput("hk_haircut0",base);
			call symput("hk_haircut1",mild);
			call symput("hk_haircut2",medium);
			call symput("hk_haircut3",severe);
		end;
	end;
	if upcase(SEGMENT)="CN" then do;
		if TYPE="PROPERTY_PRICE_YOY" then do;
			call symput("cnccl_yoy0",base);
			call symput("cnccl_yoy1",mild);
			call symput("cnccl_yoy2",medium);
			call symput("cnccl_yoy3",severe);
		end;
		if TYPE="PROPERTY_COLL_HAIRCUT" then do;
			call symput("cn_haircut0",base);
			call symput("cn_haircut1",mild);
			call symput("cn_haircut2",medium);
			call symput("cn_haircut3",severe);
		end;
	end;
	if upcase(SEGMENT)="ALL" then do;
		if TYPE="LOAN_GOWTH" then do;
			call symput("loangwth0",base);
			call symput("loangwth1",mild);
			call symput("loangwth2",medium);
			call symput("loangwth3",severe);
		end;
	end;
	if upcase(SEGMENT)="DERIV" then do;
		if TYPE="CURR_EXP_MULTIPLIER" then do;
			call symput("dcurr_m0",base);
			call symput("dcurr_m1",mild);
			call symput("dcurr_m2",medium);
			call symput("dcurr_m3",severe);
		end;
	end;
run;
data st_parameter1;
	set st_parameter;
	if TYPE in ("NPL" "LGD" "NPLCOV");
	call symput(compress(TYPE||"_"||SEGMENT||"0"," "),base);	
	call symput(compress(TYPE||"_"||SEGMENT||"1"," "),mild);
	call symput(compress(TYPE||"_"||SEGMENT||"2"," "),medium);
	call symput(compress(TYPE||"_"||SEGMENT||"3"," "),severe);
run;

/* Override the NPL_BASE, Using average NPL Base to replace the actual spot NPL base*/
data st_parameter2;
	set st_parameter;
	if TYPE in ("NPLBASE");
	call symput(compress("NPL_BU_"||SEGMENT," "),Base);
run;

/* NPL Ratio for HKMA Unsecured PIL Portfolio */
data st_parameter2;
	set st_parameter;
	if SEGMENT in ("PUL") and substr(TYPE,1,3)="NPL";
	name=compress(trim(TYPE)||"_PUL"," ");
	call symput(name,Severe);
run;

%put &NPL_BU_WBG;
%put &NPL_BU_WBG_REF;
%put &NPL_BU_IBG;
%put &NPL_BU_IBG_SGP;
%put &NPL_BU_CBIC;
%put &NPL_BU_BB;
%put &NPL_BU_ORR;
%put &NPL_BU_RML;
%put &NPL_BU_CTU;

%macro putVar();
	%if &ind_ICAAP. = ICAAP %then %do;
	%end;
	%else %do;
		%put &npl_00dpd_pul;
		%put &npl_30dpd_pul;
		%put &npl_60dpd_pul;
		%put &npl_90dpd_pul;
	%end;
%mend;
%putVar;

%put &st_notch0.;
%put &st_notch1.;
%put &st_notch2.;
%put &st_notch3.;

%put &hkccl_yoy0.;
%put &hkccl_yoy1.;
%put &hkccl_yoy2.;
%put &hkccl_yoy3.;
%put &cnccl_yoy0.;
%put &cnccl_yoy1.;
%put &cnccl_yoy2.;
%put &cnccl_yoy3.;

%put &hk_haircut0.;
%put &hk_haircut1.;
%put &hk_haircut2.;
%put &hk_haircut3.;
%put &cn_haircut0.;
%put &cn_haircut1.;
%put &cn_haircut2.;
%put &cn_haircut3.;

%put &loangwth0;
%put &loangwth1;
%put &loangwth2;
%put &loangwth3;

%put &dcurr_m0;
%put &dcurr_m1;
%put &dcurr_m2;
%put &dcurr_m3;

%put &npl_wbg1.;
%put &npl_wbg2.;
%put &npl_wbg3.;

%put &nplcov_wbg1.;
%put &nplcov_wbg2.;
%put &nplcov_wbg3.;

%put &npl_wbg_ref1.;
%put &npl_wbg_ref2.;
%put &npl_wbg_ref3.;

%put &npl_ibg1.;
%put &npl_ibg2.;
%put &npl_ibg3.;

%put &npl_ibg_sgp1.;
%put &npl_ibg_sgp2.;
%put &npl_ibg_sgp3.;

%put &npl_cbic1.;
%put &npl_cbic2.;
%put &npl_cbic3.;

%put &npl_bb1.;
%put &npl_bb2.;
%put &npl_bb3.;

%put &npl_rml1.;
%put &npl_rml2.;
%put &npl_rml3.;

%put &npl_orr1.;
%put &npl_orr2.;
%put &npl_orr3.;

%put &npl_deriv1.;
%put &npl_deriv2.;
%put &npl_deriv3.;


