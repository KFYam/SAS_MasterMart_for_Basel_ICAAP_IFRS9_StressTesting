/* Revised the sas data source updated version for Sep 2013 only */ 
filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename pgm "&dir_pgm.\Code\01.CAR_BASE";
filename ctr "&dir_pgm.\Code\05.ST_COUNTRY_FI";

/* Given the program of 01. CAR_BASE.sas has been fully run without error */

%include pgm(L_01_BASE.sas)		/source2;
%include ctr(M_01_BASE.sas)		/source2;
%include ctr(R_01_BASE.sas)		/source2;

