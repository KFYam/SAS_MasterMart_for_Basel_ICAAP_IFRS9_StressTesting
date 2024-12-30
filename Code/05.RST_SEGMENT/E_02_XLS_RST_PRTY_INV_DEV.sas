/* ---------------------------------------------------------------- */
/* \\Ckwb610\PPRM\MIS\MIS by PPRM\FMD_Shared_Library\FMD_OS by Industry */
/* Property Investment and Development Segments						*/
/* ---------------------------------------------------------------- */
PROC IMPORT OUT = STG.RST_CNCBI_BY_INDUSTRY_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\CNCBI_OS by Industry_&st_RptYMD..xls"
	DBMS=xls REPLACE;
	SHEET="data";
RUN;
PROC IMPORT OUT = STG.RST_HKCBF_BY_INDUSTRY_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\HKCBF_OS by Industry_&st_RptYMD..xls"
	DBMS=xls REPLACE;
	SHEET="data";
RUN;
