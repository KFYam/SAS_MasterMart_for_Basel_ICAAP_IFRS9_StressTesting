/* *********************************************************************************************************************************************** */
/* Orginal Source: Z:\Credit Risk, Economic Capital & Models\Jenny\Stress_Test\StressTestingRWA_2012\Corp_SME\RWA_V2\Corp_ppt\parameters\pd_st.xls */
PROC IMPORT OUT = XLS_PD
			DATAFILE="&dir_xlssiw.\PD_ST.xls" 
/*			DBMS=EXCELCS REPLACE;*/
/*			SCANTEXT=YES;*/
/*			USEDATE=YES;*/
/*			SCANTIME=YES;*/
			DBMS=XLS REPLACE;
			GETNAMES=YES; 	
     		SHEET="PD"; 
RUN;
data siw.xls_param_PD;
	set XLS_PD;
	if trim(left(Rating)) eq "" then delete;
run;

PROC IMPORT OUT = siw.XLS_MASTER_SCALE_PD
			DATAFILE="&dir_xlssiw.\Master_Scale.xls" 
/*			DBMS=EXCELCS REPLACE;*/
/*			SCANTEXT=YES;*/
/*			USEDATE=YES;*/
/*			SCANTIME=YES;*/
			DBMS=XLS REPLACE;
			GETNAMES=YES; 	
     		SHEET="PD"; 
RUN;
