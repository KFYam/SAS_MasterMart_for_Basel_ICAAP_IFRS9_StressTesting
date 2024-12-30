proc format;
value $portcd 
"Ia","Ib","Ic"						="01. Sovereign"
"II4","II5"							="02. PSE" /*Public Sector Entity*/
"III"								="03. MDB" /*Multilateral Development Bank*/
"IV"								="04. Bank"
"V"									="05. Securities Firm"
"VI"								="06. Corporate"
"VII","X19c"						="07. CIS" /*Collective Investment Scheme*/
"VIII","VII15a","VII16"				="08. Cash"
"VIIIa","VIIIb"						="09. Regulatory Retail"
"IX"								="10. RML"
"X19a","X19b","X19d","20e","X19e"	="11. Other (Not PastDue)"
"XI"								="12. PastDue"
"XIII_22a","VII15b"					="13. Other"
"B10","B11","B12","B14","B15","B18"	="14. Derivative"
other								="99. ###"
;
run;


proc format;
	value $busunit
	"CBG"					= "1.0 WBG"
	"WBG-REF"				= "1.1 WBG-REF"
	"CBIC"					= "2.0 CBIC"
	"IBG","MBR"				= "3.0 IBG"
	"IBG-SGP"				= "3.1 IBG-SGP"
	"CARD","RBG","SCBF"		= "4.0 PBG"
	"RBG-BB"				= "4.1 PBG-BB" 
	"CTU","FUND","TSY"		= "5.0 CTU"
	"CONSOL ADJ","OFD","RAM"= "6.0 OTHER"
	other					= "6.0 OTHER"
	;
run;
