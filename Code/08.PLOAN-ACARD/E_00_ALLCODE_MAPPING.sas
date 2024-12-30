/* Centralized Mapping Matrix */
proc format;
	invalue prd_typ
	"118","188",
	"288","388",
	"168","201",
	"198","298"		= 10	/* Credit Card - CBI Card */	
	"386"			= 11	/* Credit Card - For CITICfirst Customer */
	"383"			= 12	/* Credit Card - For Private Banking Customer */
	"128","166",
	"228","266"		= 13	/* Credit Card - Issued by HKCBF */
	"171","272",
	"271"			= 14	/* Credit Card - In RMB Currency */
	"668"			= 20	/* Dollar$mart PIL - Personal Instalment Loan */
	"667"			= 30	/* Dollar$mart TIL - Taxation Instalment Loan */
	"996"			= 40	/* PLOC - Personal Line of Credit (Revolving Loan - Overdraft) */
	other 			= .
	;
	value prd_nam
	10-<20 			= "Credit Card"
	20 				= "Personal Loan"
	30 				= "Tax Loan"
	40 				= "Revolving Loan (PLOC)"
	;
run;
proc format;
	invalue YN_Ind
	"Y" 			= 1
	"N" 			= 0
	other 			= .
	;
run;
proc format;
	value $o_appr
	"APPR"			= "A"
	"CANCL"			= "C"
	"DECLI"			= "D"
	"EXPRE"			= "I"
	"WIP"			= "I"
	"*****"			= "I"
	;
	value $n_appr
	"A"				= "APRROVED"
	"C"				= "CANNCEL"
	"D"				= "DECLINE"
	"I"				= "PENDING/OTHERS"
	;
run;
proc format;
	value $o_mrtal
	"M"="M"
	"S"="S"
	"O"="O"
	" ",""=" "
	other="O"
	;
run;
proc format;
	value $nation
	" ",""=" "
	"HKG"="HKG"
	"CHN"="CHN"
	other="OTH"
	;
run;
proc format;
value $edu
"B","P"	="P"	/*Primary or Below Primary*/
"S"		="S"	/* Secondary */	
"T"		="T"	/* TI */
"U"		="U"	/* University */
" ","","V"=" "	/* Missing */
;
run;

proc format;
value $occ
	" ",""			= "Missing"
	other			= "[Other]"
	'111'			= '111-Accounting / Audit'
	'112'			= '112-Banking'
	'121'			= '121-HKG - Discipline'
	'131'			= '131-HKG - Non-discipline'
	'132'			= '132-HKG - Organization'
	'133'			= '133-Embassy'
	'141'			= '141-Education - Tertiary / University'
	'142'			= '142-Education - Professional & Secondary'
	'143'			= '143-Education - Primary / Preliminary'
	'144'			= '144-Education - VTC'
	'145'			= '145-Education - Training schools'
	'151'			= '151-Hospital / Medical '
	'152'			= '152-Nursery'
	'161'			= '161-Public Utilities'
	'171'			= '171-Legal Services'
	'181'			= '181-Association -  Non Business'
	'182'			= '182-Association - Business'
	'183'			= '183-Social Services'
	'191'			= '191-Architectural'
	'213'			= '213-IT - Non Internet Services'
	'214'			= '214-IT - Internet Services'
	'215'			= '215-Scientific'
	'221'			= '221-Trading / Shipping'
	'222'			= '222-Express / Forwarding'
	'223'			= '223-Consultancy'
	'224'			= '224-Secretarial'
	'225'			= '225-Information Services - Non IT'
	'226'			= '226-Marketing'
	'227'			= '227-Advertising'
	'228'			= '228-Exhibition'
	'229'			= '229-Airport Services'
	'22A'			= '22A-Recruitment Company'
	'231'			= '231-Hotel / Hostel'
	'232'			= '232-Travel Agency'
	'233'			= '233-Airlines'
	'241'			= '241-Telecommunication'
	'251'			= '251-Design - Professional'
	'261'			= '261-Brokerage'
	'262'			= '262-Investment'
	'271'			= '271-HKG Non-discipline Marginal'
	'281'			= '281-Large Corporation'
	'311'			= '311-Manufacturing - Mechanic'
	'312'			= '312-Manufacturing - Chemical'
	'313'			= '313-Manufacturing - Electronic'
	'314'			= '314-Manufacturing - Textile'
	'315'			= '315-Manufacturing - Other'
	'316'			= '316-Shipbuilding / Repair'
	'317'			= '317-Printing'
	'321'			= '321-Leasing / Hire Purchase'
	'322'			= '322-Department Stores'
	'323'			= '323-Retail Sales - Chain Stores'
	'324'			= '324-Retail Sales - Technical'
	'325'			= '325-Retail Sales - Pharmacy'
	'326'			= '326-Retail Sales - Optical Shop'
	'327'			= '327-Retail Sales - Small Shop'
	'328'			= '328-Sales - Automobile'
	'329'			= '329-Distribution'
	'32A'			= '32A-Wholesales'
	'32B'			= '32B-Insurance - Large Company'
	'32C'			= '32C-Insurance - Small Company'
	'32D'			= '32D-Real Estate Agency'
	'331'			= '331-Broadcasting'
	'332'			= '332-Press Media'
	'333'			= '333-Production - Mass Media'
	'334'			= '334-Publishing'
	'337'			= '337-Entertainment'
	'341'			= '341-Transport, Tunnel'
	'342'			= '342-Transportation - Public'
	'343'			= '343-Transportation - Non-public'
	'344'			= '344-Courier'
	'411'			= '411-Jewellery / Goldsmith / Craftsman'
	'412'			= '412-Engineering - Civil'
	'413'			= '413-Engineering - E & M'
	'414'			= '414-Semi-conductor / Disk Drive'
	'421'			= '421-Construction - Developer'
	'422'			= '422-Construction - Contractor'
	'431'			= '431-Maintenance - Auto Repair'
	'432'			= '432-Maintenance/ Audio & Video'
	'433'			= '433-Maintenance - Elect / Furniture'
	'434'			= '434-Training Services'
	'435'			= '435-Private Tuition'
	'436'			= '436-Decoration'
	'437'			= '437-Interior Design'
	'438'			= '438-Beauty Salon'
	'439'			= '439-Property Management'
	'43A'			= '43A-Security Guards'
	'43B'			= '43B-Fire Security'
	'43C'			= '43C-Security System '
	'43D'			= '43D-Gardener'
	'43E'			= '43E-Financial Company - Small'
	'43F'			= '43F-Money Exchange'
	'43G'			= '43G-Paper Recycling'
	'43H'			= '43H-Photography'
	'43I'			= '43I-Plumbing '
	'43J'			= '43J-Storage'
	'43L'			= '43L-Wedding Dress Maker'
	'43M'			= '43M-Petroleum'
	'43N'			= '43N-Life Guard'
	'43O'			= '43O-General Services'
	'441'			= '441-Cake Shop'
	'442'			= '442-Restaurant / Coffee Hse / Canteen'
	'443'			= '443-Manufacturing  Food Processing'
	'451'			= '451-Quality Surveyor'
	'452'			= '452-Valuation'
	'513'			= '513-Professional Services'
	'519'			= '519-Other - Normal'
	'521'			= '521-Embassy ( Expatriate )'
	'522'			= '522-Night Club'
	'529'			= '529-Other - Undesirable'
	'911'			= '911-Unemployed'
	'999'			= '999-Unknown'
;
run;
