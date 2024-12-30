
%let dir_oaps		= \\cf-smesas\creditcard$\aps\backup\sas; 			/*Input - old APS Application Data */
%let dir_naps		= \\cf-smesas\creditcard$\new aps\history\backup; 	/*Input - new APS Application Data */
%let dir_card1		= \\cf-smesas\CreditCard$\Cardlink\history\master;	/*Input - Cardlink Performance Data (Current with Daily Snapshot */
%let dir_card2		= \\ckwb411\common$\Z_backup\credit card\host; 		/*Input - Cardlink Performance Data (Archive with Monthly Snapshot)*/

%let dir_vali		= &dir_root.\Data\5.SCORECARD\VALIDATION;
%let dir_ica		= &dir_root.\Data\5.SCORECARD\ICA;
%let dir_scor		= &dir_root.\Data\5.SCORECARD\SCORE;

libname i_oaps		"&dir_oaps."					access=readonly; 
libname i_naps		"&dir_naps."					access=readonly; 
libname i_crdk		("&dir_card2." "&dir_card1.")	access=readonly; /* Becasue the later is more correct */

libname vali		"&dir_vali.";
libname ica			"&dir_ica.";
libname scor		"&dir_scor.";	/* Library for PRELIM-SCORECARD, REJECT INFERENCE, CUT-OFF related dataset storage */

%let dt_beg_CRD		= '01Nov2001'd;
%let dt_end_CRD		= '30Aug2012'd;
%let dt_beg_PIL		= '01Apr2004'd;
%let dt_end_PIL		= '30Aug2012'd;

