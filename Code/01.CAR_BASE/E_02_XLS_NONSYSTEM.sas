%macro tx(out);
	/*
	*Branch Code mapping;
	proc transpose data=nonsystem(obs=2) out=branchcode;var _ALL_;run;
	data branchcode_V1(rename=(COL1=CODE COL2=BRANCH));
		set branchcode;
		where not missing(COL1);
		keep COL1 COL2;
	run;
	*/
	proc contents data=&out. out=columnvar(keep=name type varnum format) noprint;
	run;
	proc transpose data=&out. (firstobs=1 obs=1) out=columnname(keep=_NAME_ COL1);
		var _ALL_;
	run;
	proc sql noprint;
		create table columnvar2 as
		select a.*, upcase(compress(b.COL1," +-'/(%)&."||"0D0A"x)) as TXTNAME
		from columnvar a left join columnname b on a.NAME=b._NAME_
		order by varnum;
	quit;
	data columnvar3;
		set columnvar2;
		if missing(TXTNAME) then delete;
		if TXTNAME in("PORT_CD" "ITEM" "NATUREOFITEM") then FLAG_NUM=0; else FLAG_NUM=1;
	run;

	filename tmp temp;
	data _null_;
		file tmp lrecl=65535;
		set columnvar3 end=eof;
		if _n_=1 then do;
			put "data stg.&out._&st_rptmth.;";
			put "set &out.(firstobs=2);";
		end;
		if FLAG_NUM > 0 then do;
			put TXTNAME "=input(" NAME ",comma32.);";
		end;
		else do;
			put TXTNAME "=" NAME ";";
		end;
		put "drop " NAME ";";
		put "keep " TXTNAME ";";
		if eof then do;
			put "if not missing(ITEM);"; 
			put "run;";
		end;
	run;
	%include tmp /source2; 
%mend;
%macro nonsysImport(file, out);
	PROC IMPORT OUT = &out.
			DATAFILE="&dir_xls.\FMD_&st_Rptmth.\&file." 
			DBMS=XLS REPLACE;
			GETNAMES=NO; DATAROW=5; 	
			SHEET="NonSys_Summary";
	RUN;
	%tx(&out.);
%mend;
%nonsysImport(OGL outstanding for Basel_&st_RptYMD._RMG.xls,nonsystem);
%nonsysImport(HKCBF Non_Sys_&st_RptYMD..xls,ns_hkcbf);
