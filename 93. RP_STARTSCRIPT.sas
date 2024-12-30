/* ************************************************************************* */
/* Override the Date Setting from STARTUP SCRIPT							 */
/* ************************************************************************* */
%let dir_stg		= &dir_root.\Data\2.STAGING\RP;
%let dir_mart		= &dir_root.\Data\4.MART\RP;
%let dir_rmart		= &dir_root.\Data\4.MART\RST;
libname stg			"&dir_stg.";
libname mart		"&dir_mart.";
libname rstmart		"&dir_rmart.";

%let st_RptMth		= 201406 ; 

%let dt_RptMth		= %SYSFUNC(intnx(MONTH,%SYSFUNC(inputn(&st_RptMth.01,yymmdd8.)),0,END));
%let st_RptYMD		= %SYSFUNC(putn(&dt_RptMth.,yymmddn8.));
%let st_RptYYMM		= %SYSFUNC(putn(&dt_RptMth.,yymmn4.));
/* ************************************************************************* */

filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename ptr "&dir_pgm.\Code\01.CAR_BASE";
filename pgm "&dir_pgm.\Code\90.RP_SEGMENT";

%include ptr(E_00_XLS_ERR_MASTER.sas)				/source2;
%include ptr(L_02_FACT_ICAAP_FORMAT.sas)			/source2;

%include pgm(F_04_PARAMETER)						/source2;
%include pgm(F_05_SEGMENT)							/source2;
%include pgm(F_06_RP_RML)							/source2;
%include pgm(F_07_RP_PROP_INVDEV)					/source2;
%include pgm(F_08_RP_BANK_FI)						/source2;
%include pgm(F_09_RP_DERIVATIVE)					/source2;
%include pgm(F_10_RP_NBMCE)							/source2;
%include pgm(F_11_RP_OTHER)							/source2;
%include pgm(F_12_COMBINED)							/source2;
%include pgm(F_13_RP_SUMMARY)						/source2;

