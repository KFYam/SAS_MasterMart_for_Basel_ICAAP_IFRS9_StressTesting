/* ---------------------------------------------------------------- */
/* CBIC 															*/
/* ---------------------------------------------------------------- */
/* Ensure the font of the excel must be Arial format */
PROC IMPORT OUT = STG.RST_CBIC_NBMCE_&st_Rptmth.
	DATAFILE="&dir_xls.\CBIC_&st_Rptmth.\NBMCE_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;
/* ---------------------------------------------------------------- */
/* ---------------------------------------------------------------- */
/* HK	 															*/
/* ---------------------------------------------------------------- */
/* Ensure the font of the excel must be Arial format */
/* All the accounts in this file are valid NBMCE cases */
PROC IMPORT OUT = STG.RST_HK_NBMCE_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\HK_Office_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;

/* ---------------------------------------------------------------- */
/* OV	 															*/
/* ---------------------------------------------------------------- */
PROC IMPORT OUT = STG.RST_OV_NBMCE_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\OV_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;

/* ---------------------------------------------------------------- */
/* CBF	 															*/
/* ---------------------------------------------------------------- */
PROC IMPORT OUT = STG.RST_CBF_NBMCE_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\HKCBF_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;

