filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename pgm "&dir_pgm.\Code\01.CAR_BASE";

/* ************************************************************* */
/* PART 1 - EXTRACT common tables and parameters for any program */	
/* ************************************************************* */
%include cmn(E_IMPORT_IW.sas) 						/source2;
%include cmn(E_IMPORT_BASEL_SGP.sas) 				/source2;
%include cmn(E_IMPORT_PARAMETERS.sas) 				/source2;

/* ************************************************************* */
/* PART 2 - EXTRACT tables only for RWA program					 */	
/* ************************************************************* */
%include pgm(E_00_XLS_ERR_MASTER.sas)				/source2;
/*%include pgm(E_01_XLS_SPGS_SEGS.sas) 				/source2; Obsolete due to system automation */
%include pgm(E_02_XLS_NONSYSTEM.sas) 				/source2;
/*%include pgm(E_03_XLS_DATACOM.sas) 				/source2; Obsolete due to system automation */
%include pgm(E_04_XLS_DERIVATIVE.sas) 				/source2;
%include pgm(E_05_XLS_RATING.sas) 					/source2; * Import CCY BONDS RATING;
%include pgm(E_06_XLS_REF_LIST.sas) 				/source2;	

/* ************************************************************* */
/* PART 3 - FORMUATE and TRANSFORM tables 						 */
/* ************************************************************* */
%include pgm(F_00_IW_TO_STG.sas)					/source2; * Prepare collateral and CMV tables for ongoing usage, such as for Stress Testing;
/*%include pgm(F_01_SPGS_SEGS.sas)					/source2; Obsolete due to system automation */
/*%include pgm(F_02_DATACOM.sas)					/source2; Obsolete due to system automation */
%include pgm(F_03_DERIVATIVE.sas)					/source2;
%include pgm(F_04_IW_ADJ.sas)						/source2;
%include pgm(F_05_SGP_XLS.sas)						/source2;
%include pgm(F_06_SGP_NOSTRO.sas)					/source2;
%include pgm(F_07_ADJ_DELTA.sas)					/source2; * SPGS_SEGS and DATACOM part remarked; 
%include pgm(F_08_NONSYS_DELTA.sas)					/source2;
%include pgm(F_09_HKCBF_ADJ_n_DELTA.sas)			/source2;
%include pgm(F_10_CBIC_ADJ.sas)						/source2;
%include pgm(F_11_CCP_BONDS_RATING.sas)				/source2; * Merge the rating information into FACT table;
%include pgm(F_12_REF_LIST_FROM_BU.sas)				/source2;	
/* Ask Eva for the purpose of CBI(CN) FX_adjustment */
/* ************************************************************* */
/* PART 4 - LOAD into FACT Base table 							 */
/* ************************************************************* */
%include pgm(L_01_FACT_RWA.sas)						/source2;
%include pgm(L_02_FACT_ICAAP_FORMAT.sas)			/source2;
%include pgm(L_03_FACT_ICAAP_INFO.sas)				/source2;


/* ************************************************************* */
/* PART 5 - SENSE Checking 					 					 */
/* ************************************************************* */
%include pgm(S_01_ONBAL_CHECKING.sas)				/source2;
%include pgm(S_02_OFFBAL_CHECKING.sas)				/source2;
%include pgm(S_03_DERVIATIVE_CHECKING.sas)			/source2;
