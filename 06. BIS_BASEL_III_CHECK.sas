/* Revised the sas data source updated version for Sep 2013 only */ 
filename cmn "&dir_pgm.\Code\0.SIW_IMPORT";
filename pgm "&dir_pgm.\Code\01.CAR_BASE";
filename bsl "&dir_pgm.\Code\06.BIS_BASEL_III_CHECK";

/* Given the program of 01. CAR_BASE.sas has been fully run without error */

%include bsl(F_01_BIS_GEN_INFO.sas)		/source2;
%include bsl(F_02_BIS_CSRBB_BASE.sas)	/source2;
