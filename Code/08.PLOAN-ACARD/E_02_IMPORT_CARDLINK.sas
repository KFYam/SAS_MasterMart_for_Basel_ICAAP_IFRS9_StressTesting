/************************************************************************************/
/* BEGIN - Retrieve Cardlink Performance data 										*/
/************************************************************************************/
/************************************************************************************/
%macro ds_group(src_cd, dt_begmth, dt_finmth, mode);
	%if &src_cd. = CRD %then %do;
		%let dat_src=i_crdk.card;
		%let dat_out=stg.PERFORM_CRD;
	%end;
	%else %do;
		%let dat_src=i_crdk.pil;
		%let dat_out=stg.PERFORM_PIL;
	%end;

	%if &mode = INITIAL %then %do;
		/* BEGIN - Group the month end dataset into single view table */
		filename jnt_&src_cd. temp;
		data _null_;
			file jnt_&src_cd. lrecl=65535;
			intx=intck("MONTH",&dt_begmth.,&dt_finmth.);
			put "set";
			do i = 0 to intx;
				dt_rptmth = intnx("MONTH",&dt_begmth.,i,"END");
				st_rptmth = put(dt_rptmth,yymmdd6.);	
				curtable = compress("&dat_src."||st_rptmth||"(in=a"||i||")"," ") ;
				put curtable ;
			end;
			put ";";
		run;
		/* FINISH - Group the month end dataset into single view table */
		/* BEGIN - Assign reporting month data value into every table when grouping */
		data _null_;
			file jnt_&src_cd. lrecl=65535 mod;
			intx=intck("MONTH",&dt_begmth.,&dt_finmth.);
			put "format rpt_mth z6.;";
			do i = 0 to intx;
				dt_rptmth = intnx("MONTH",&dt_begmth.,i,"END");
				st_rptmth = put(dt_rptmth,yymmn6.);	
				stat = "if "||compress("a"||i," ")||" then "||compress("rpt_mth="||st_rptmth||";") ;
				put stat;
			end;
		run;
		/* FINISH - Assign reporting month data value into every table when grouping */
		/* BEGIN - Create and group as into single view table */
		data &dat_out./view=&dat_out.;
			%include jnt_&src_cd. /source2; 
		run;
		/* FINISH - Create and group as into single view table */
	%end;
%mend;
%ds_group(CRD, &dt_beg_CRD., &dt_end_CRD., INITIAL);
%ds_group(PIL, &dt_beg_PIL., &dt_end_PIL., INITIAL);

