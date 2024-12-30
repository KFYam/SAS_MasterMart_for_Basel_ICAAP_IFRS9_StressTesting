filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename ptr "&dir_pgm.\Code\01.CAR_BASE";
filename rue "&dir_pgm.\Code\02.RU_NONBANK_EXP";
filename pgm "&dir_pgm.\Code\04.ST_SEGMENT";

%include ptr(E_00_XLS_ERR_MASTER.sas)				/source2;
%include ptr(L_02_FACT_ICAAP_FORMAT.sas)			/source2;

/*%global flag_npl_bu;%let flag_npl_bu=ICAAP;*/
/*%include rue(M_01_NPL_RATIO_BY_BU.sas)			/source2;*/

%include pgm(F_01_PARAMETER.sas)					/source2;
%include pgm(F_02_SEGMENT.sas)						/source2;
%include pgm(F_03_ST_CASH.sas)						/source2;
%include pgm(F_04_ST_BANK_FI.sas)					/source2;
%include pgm(F_05_ST_RML.sas)						/source2;
%include pgm(F_06_ST_DERIVATIVE.sas)				/source2;
%include pgm(F_07_ST_NONRML.sas)					/source2;
%include pgm(F_08_COMBINED.sas)						/source2;
%include pgm(F_09_PUL_UNSECURED_REFINED.sas)		/source2; /* Cater the Delq Bucket Movement */
%include pgm(F_09_PUL_UNSECURED.sas)				/source2;
%include pgm(F_10_ST_TAXI.sas)						/source2;
%include pgm(F_11_ST_SUMMARY.sas)					/source2;

