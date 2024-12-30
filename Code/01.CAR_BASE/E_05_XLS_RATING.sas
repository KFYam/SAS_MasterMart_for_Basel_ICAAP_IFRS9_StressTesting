/* ------------------------------------------------- */
/* a.Import the Bond issue rating and CC issuer rating */
PROC IMPORT OUT = stg.bonds_rating_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\Bond_Rating_&st_Rptmth..xls"
	DBMS=xls REPLACE;
RUN;


PROC IMPORT OUT = stg.cc_rating_&st_Rptmth.
	DATAFILE="&dir_xls.\RIORM_&st_Rptmth.\Counterparty_Risk_Rating_&st_Rptmth..xls"
	DBMS=xls REPLACE; 
RUN;
