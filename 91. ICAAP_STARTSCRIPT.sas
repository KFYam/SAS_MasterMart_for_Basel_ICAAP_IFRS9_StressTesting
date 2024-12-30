/* ************************************************************************* */
/* Override the Date Setting from STARTUP SCRIPT							 */
/* ************************************************************************* */
%let ind_ICAAP		= ICAAP;

%let dir_stg		= &dir_root.\Data\2.STAGING\ICAAP;
%let dir_mart		= &dir_root.\Data\4.MART\ICAAP;
libname stg			"&dir_stg.";
libname mart		"&dir_mart.";

%let st_RptMth		= 201312 ; 

%let dt_RptMth		= %SYSFUNC(intnx(MONTH,%SYSFUNC(inputn(&st_RptMth.01,yymmdd8.)),0,END));
%let st_RptYMD		= %SYSFUNC(putn(&dt_RptMth.,yymmddn8.));
%let st_RptYYMM		= %SYSFUNC(putn(&dt_RptMth.,yymmn4.));
/* ************************************************************************* */

filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename ptr "&dir_pgm.\Code\01.CAR_BASE";
filename pgm "&dir_pgm.\Code\04.ST_SEGMENT";

%include ptr(E_00_XLS_ERR_MASTER.sas)				/source2;
%include ptr(L_02_FACT_ICAAP_FORMAT.sas)			/source2;

%include pgm(F_01_PARAMETER.sas)					/source2;
%include pgm(F_02_SEGMENT.sas)						/source2;
%include pgm(F_03_ST_CASH.sas)						/source2;
%include pgm(F_04_ST_BANK_FI.sas)					/source2;
%include pgm(F_05_ST_RML.sas)						/source2;
%include pgm(F_06_ST_DERIVATIVE.sas)				/source2;
%include pgm(F_07_ST_NONRML.sas)					/source2;
%include pgm(F_08_COMBINED.sas)						/source2;
%include pgm(F_11_ST_SUMMARY.sas)					/source2;



