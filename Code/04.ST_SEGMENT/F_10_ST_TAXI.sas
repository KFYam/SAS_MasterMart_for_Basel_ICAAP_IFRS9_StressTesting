%let rw_pastdue	=150;
%let tbl_tar	=MART.STHKMA_01_TAXI_&st_Rptmth;
%let tbl_src	=STG.STHKMA_01_TAXI_&st_Rptmth.;

proc sql noprint;
	create table TAXI_BASE1 as
	select 		a.*, b.LICNO
	from 		(
		select *, case when PROD_SYS_CD in ('ELS') then substr(left(ACCT_ID),3,30) else ACCT_ID end as ACCT_ID_TAXI 
		from &tbl_src.
	) a
	left join 	siw.pbg_taxi_dist_&st_RptMth. b
	on a.ACCT_ID_TAXI = b.ACNO;
quit;
proc sql noprint;
	create table TAXI_BASE2 as
	select 
		a.*, 
		b.UNS_0,	b.UNS_20,	b.UNS_50,
		b.DSR_N,	b.DSR_UP1,	b.DSR_UP2DN2,	b.DSR_UP3DN2,	b.DSR_UP4DN3,
		b.CUST1
	from TAXI_BASE1 a left join siw.pbg_taxi_stress_&st_RptMth. b
	on a.LICNO = b.LICNO;
quit;

data &tbl_tar.;
	set TAXI_BASE2;
	length	RW_ST0		- RW_ST3	8;
	length	RWA_ST0		- RWA_ST3	8;
	length	CRM_ST0		- CRM_ST3	8;
	length	IA_ST0		- IA_ST3	8;
	length 	T_ST0		- T_ST3 	8;
	length	T_RAN_ST0	- T_RAN_ST3	8;

	T_RANDOM_SEED 			=45;
	T_RANDOM_PASTDUE_CUT_OFF=25;

	array a_tia 		UNS_0 	UNS_20 	UNS_20 		UNS_50;
	array a_dsr 		DSR_N 	DSR_UP1	DSR_UP2DN2	DSR_UP3DN2;
	array a_ia 			IA_ST0		- IA_ST3;
	array a_rw 			RW_ST0		- RW_ST3;
	array a_rwa 		RWA_ST0		- RWA_ST3;
	array a_crm 		CRM_ST0		- CRM_ST3;
	array a_tar 		T_ST0		- T_ST3;
	array a_ran 		T_RAN_ST0	- T_RAN_ST3;
	*array a_npl 		NPL_ST0		- NPL_ST4;
	*array test	 		IA_ST0		- IA_ST4;


	a_rw(1)		= APPL_RISK_WEIGHT;
	a_rwa(1)	= RISK_WEIGHTED_AMT_HKE;
	a_crm(1)	= APPL_CRM_AMT_HKE;

	do i=2 to dim(a_dsr);

		a_rw(i)		= APPL_RISK_WEIGHT;
		a_rwa(i)	= RISK_WEIGHTED_AMT_HKE;
		a_crm(i)	= APPL_CRM_AMT_HKE;

		if CUST1='INV' 		and a_dsr(i)>=1.0 	then a_tar(i)=1;
		else if CUST1='OWN' and a_dsr(i)>=0.7 	then a_tar(i)=1;

		if a_tar(i)=1 then do;
			a_ran(i)=int(ranuni(T_RANDOM_SEED)*100);
			if a_ran(i) < T_RANDOM_PASTDUE_CUT_OFF then do;
				a_ia(i)		=a_tia(i);
				a_rw(i)		=&rw_pastdue.;
				a_rwa(i)	=(APPL_CRM_AMT_HKE - a_ia(i)) * a_rw(i)/100;
				a_crm(i)	=APPL_CRM_AMT_HKE - a_ia(i);
			end;
		end;
	end;
	drop i /*T_: UNS_: DSR_: CUST1 LICNO */;
run;

