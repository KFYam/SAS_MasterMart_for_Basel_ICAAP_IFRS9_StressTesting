filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename pgm "&dir_pgm.\Code\02.RU_NONBANK_EXP";

/* ************************************************************* */
/* PART 1 - EXTRACT common tables and parameters for any program */	
/* ************************************************************* */
%include cmn(E_IMPORT_IW.sas) 						/source2;
%include cmn(E_IMPORT_BASEL_SGP.sas) 				/source2;
%include cmn(E_IMPORT_PARAMETERS.sas) 				/source2;
%include cmn(E_IMPORT_APS_PIL.sas) 					/source2;	*Added on 30Sep2014;

/* ************************************************************* */
/* PART 2 - EXTRACT tables only for RWA program					 */	
/* ************************************************************* */
%include pgm(E_01_XLS_RU_NONPBG_EXP.sas)			/source2;
%include pgm(E_02_XLS_NPL.sas) 						/source2;
%include pgm(E_03_XLS_DSR.sas) 						/source2;
%include pgm(E_04_PBG_TABLES.sas) 					/source2;

/* ************************************************************* */
/* PART 3 - FORMUATE and TRANSFORM tables 						 */
/* ************************************************************* */
%include pgm(F_01_RU_NONPBG_EXP.sas)				/source2;
%include pgm(F_02_RU_PBG_ADD_DSR.sas)				/source2;
%include pgm(F_03_RU_PBG_EXP.sas)					/source2;

/* ************************************************************* */
/* PART 4 - LOAD into FACT Base table 							 */
/* ************************************************************* */
%include pgm(L_01_RU_NPL_FACT_TABLE.sas)			/source2;

%global flag_npl_bu;%let flag_npl_bu=NEW;
%include pgm(M_01_NPL_RATIO_BY_BU.sas)				/source2;


/* ************************************************************* */
/* PART 5 - Report Generation				 					 */
/* ************************************************************* */
%include pgm(R_01_SUMMARY.sas)						/source2;
