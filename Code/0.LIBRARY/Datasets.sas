/********************************************************************/
/* Objective:  Add suffix into the field of the table                                                                 */
/* Example :  %addFieldSuffix(inlibds, outlibds, suffix, keyfields)                                            */ 
/* Example :  %addFieldSuffix(inlibds, , suffix, keyfields)                                            			*/ 
/********************************************************************/
%macro addFieldSuffix(inlibds, outlibds, suffix, keyfields ,view=N, sort=N);
	%local __keyfield_;
	%let __key_=%sysfunc(compbl(&keyfields.));
	%let __keyfield_=%sysfunc(tranwrd("&__key_.",%str( ),%str(%",%")));
	proc contents data=&inlibds. out=__t_field_(keep= name type format) noprint;run; 
	filename c_file temp;
	data _null_;
		file c_file;
		set __t_field_(where=(name not in (&__keyfield_)));
		if _n_=1 then put "rename";
		newname= cat(trim(name),"&suffix.");
		put name "=" newname;
	run;
	%if &outlibds= %then %do;
		%local __Lib;
		%local __Dsn;
		%let __Lib=%scan(&inlibds.,1,.);
		%let __Dsn=%scan(&inlibds.,2,.);
		proc datasets library=&__Lib.;
			modify &__Dsn.;
			%include c_file /source2;
			;
		quit;
		run;
	%end;
	%else %do;
		data &outlibds.
		%if &view=Y %then %do;
		/view=&outlibds.
		%end;
		;
			set &inlibds.;
			%include c_file /source2;
			;
		run;
	%end;
	%if &sort.=Y %then %do;
		proc sort data=&outlibds.; by &keyfields.; run;
	%end;
%mend;
