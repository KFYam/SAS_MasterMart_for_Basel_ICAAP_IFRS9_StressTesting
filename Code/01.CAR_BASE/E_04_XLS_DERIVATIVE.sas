%macro off_Derv_Import(file, out);
	PROC IMPORT OUT = &out.
			DATAFILE="&dir_xls.\FMD_&st_Rptmth.\&file." 
			DBMS=XLS REPLACE;
			GETNAMES=NO;  	
	RUN;
/*	%offbal_tx(&out.);*/
%mend;
%off_Derv_Import(Summary of Car adj for Derivatives_&st_RptYMD..xls, stg.x_deriv_&st_Rptmth.);
