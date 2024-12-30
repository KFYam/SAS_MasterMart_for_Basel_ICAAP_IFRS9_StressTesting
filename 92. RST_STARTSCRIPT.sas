/* ************************************************************************* */
/* Override the Date Setting from STARTUP SCRIPT							 */
/* ************************************************************************* */
%let ind_RST		= RST;

%let dir_stg		= &dir_root.\Data\2.STAGING\RST;
%let dir_mart		= &dir_root.\Data\4.MART\RST;
libname stg			"&dir_stg.";
libname mart		"&dir_mart.";

%let st_RptMth		= 201406 ; 

%let dt_RptMth		= %SYSFUNC(intnx(MONTH,%SYSFUNC(inputn(&st_RptMth.01,yymmdd8.)),0,END));
%let st_RptYMD		= %SYSFUNC(putn(&dt_RptMth.,yymmddn8.));
%let st_RptYYMM		= %SYSFUNC(putn(&dt_RptMth.,yymmn4.));
/* ************************************************************************* */

filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename ptr "&dir_pgm.\Code\01.CAR_BASE";
filename pgm "&dir_pgm.\Code\05.RST_SEGMENT";

%include ptr(E_00_XLS_ERR_MASTER.sas)				/source2;
%include ptr(L_02_FACT_ICAAP_FORMAT.sas)			/source2;

%include pgm(E_01_XLS_RST_NBMCE)					/source2;
%include pgm(E_02_XLS_RST_PRTY_INV_DEV)				/source2;
%include pgm(F_01_RST_NBMCE)						/source2;
%include pgm(F_02_RST_PRTY_INV_DEV)					/source2;
%include pgm(F_03_JOIN_NBMCE)						/source2;
%include pgm(F_04_PARAMETER)						/source2;
%include pgm(F_05_SEGMENT)							/source2;
%include pgm(F_06_RST_RML)							/source2;
%include pgm(F_07_RST_PROP_INVDEV)					/source2;
%include pgm(F_08_RST_BANK_FI)						/source2;
%include pgm(F_09_RST_DERIVATIVE)					/source2;
%include pgm(F_10_RST_NBMCE)						/source2;
%include pgm(F_11_RST_OTHER)						/source2;
%include pgm(F_12_COMBINED)							/source2;
%include pgm(F_13_RST_SUMMARY)						/source2;



%include pgm(S_01_EXPORT_FACT)						/source2;

