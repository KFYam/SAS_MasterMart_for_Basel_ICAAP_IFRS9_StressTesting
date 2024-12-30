/* Check the Banking Exposure in CTU unit */
data BANK_in_CTU;
	set MART.STICAAP_00_BASE_&st_Rptmth.;
	where 
		put(IND_BUS_UNIT,$busunit.)="5.0 CTU" and 
		put(IND_BASEL_ASSET_CLASS, $portcd.)="04. Bank";
run;

%let where_cond	= FLAG_DELETE=. and FLAG_ELIM_COMBIN=. and FLAG_SOLO ne .;
%ST_SUM(tbl=BANK_in_CTU, st=SEVERE_RWA_PL,		var=RWA_ST3);
