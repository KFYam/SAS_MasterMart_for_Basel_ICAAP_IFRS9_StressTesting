proc format;
value $BU_IBG /* Group SGP into IBG segments */
'7.IBG_SGP'='6.IBG'
;
run;


%macro GenRpt(title=,wclause=);
	title "&title.";
	proc tabulate data=FACT.RU_NONBANK_EXP_&st_Rptmth. missing;
		where	FLAG_DELETE = . and &wclause.; 
		class	BU_GROUP CLASSIFIED;
		var		PRIN_HKE ALLOCATED_CMV_HKE_ALL ALLOCATED_CMV_HKE_TD;
		table 
			BU_GROUP ="" all, 
				CLASSIFIED*(PRIN_HKE*sum) 
				CLASSIFIED*(ALLOCATED_CMV_HKE_ALL*sum) 
				CLASSIFIED*(ALLOCATED_CMV_HKE_TD*sum)
		;
		*ods output table = &table.;
		format BU_GROUP $BU_IBG.;
	run; 
%mend;

ods html body ="&dir_rpt.\02.RU_NONBANK_EXP\RU_STRESS_GRP_&st_Rptmth..xls";
%GenRpt(title=WBG,						wclause=%str(FLAG_SRC="NONPBG"));
%GenRpt(title=WBG_wo_Dubai,				wclause=%str(FLAG_SRC="NONPBG" and cust_sec_id ~in ("HKZFIG081")));
%GenRpt(title=PBG,						wclause=%str(FLAG_SRC="PBG"));
%GenRpt(title=PBG_excl_CBIC,			wclause=%str(FLAG_SRC="PBG" and BUS_UNIT not in ("BJ" "SH" "SZ")));
%GenRpt(title=PBG_excl_CBIC_n_HKCBF,	wclause=%str(FLAG_SRC="PBG" and BUS_UNIT not in ("BJ" "SH" "SZ" "HKCBF")));
ods html close;

