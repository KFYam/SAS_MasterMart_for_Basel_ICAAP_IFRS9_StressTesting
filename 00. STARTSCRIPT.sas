/******************************************************************************
  PURPOSE  : Fact Table Preparation for all purpose (such as Stress Testing)
  DATE     : 11 Mar 2013
  REMARKS  : N/A
*******************************************************************************

Version By        	Date     Description
-------------------------------------------------------------------------------
1.0     Philip Yam  20130311 Program Framework Creation
2.0     Philip Yam  20140312 All Programs Combination 
******************************************************************************/

/* Parameters and Properties Definition */
option nomprint ERRORS=max;
option compress=binary;

/* Paths Definition */
%let dir_base		= \\ckwb610\Credit Data & Model\Credit Risk, Economic Capital & Models\STRESS TEST;
%let dir_pbg		= \\ckwb505\aps-data\Yvonne_V\SAS_Data_V8;				          *specific PBG or retail data marts;
%let dir_ccd		= \\cf-smesas\creditcard$\HLee\data\portfolio segment; 	    *specific for Credit Card segment;
%let dir_aps		= \\cf-smesas\creditcard$\new aps\history\backup;		        *specific APS orignal path for getting information about DSR;
%let dir_card1	= \\cf-smesas\CreditCard$\Cardlink\history\master;		    *Input - Cardlink Performance Data (Current with Daily Snapshot;

%let ind_ICAAP	=;

%let dir_root		= &dir_base.\#SAS.Logic;
%let dir_xls		= &dir_root.\Data\0.INPUT_XLS;
%let dir_xlssiw	= &dir_root.\Data\0.INPUT_XLSSIW;
%let dir_siw		= &dir_root.\Data\1.SIW;
%let dir_stg		= &dir_root.\Data\2.STAGING;				                        *Keep the staging tables for checking purpose, need to be housekeeping and archive from time to time;
%let dir_fact		= &dir_root.\Data\3.FACT;					                          *Create fact table with time dimension;
%let dir_mart		= &dir_root.\Data\4.MART;					                          *Project spectific;
%let dir_pgm		= &dir_root.\Program;
%let dir_rpt		= &dir_root.\Report;
%let dir_lib		= &dir_pgm.\Code\0.LIBRARY;

filename LIB		"&dir_lib.";
%include			LIB(Datasets.sas);
%include			LIB(Macro.sas);

libname pbg			"&dir_pbg."		access=readonly;			                        *Link to Retail data mart;
libname ccd			"&dir_ccd."		access=readonly;			                        *Link to Credit Card data mart;
libname aps			"&dir_aps." 	access=readonly;			                        *Link to APS data mart;
libname crdk		"&dir_card1."	access=readonly; 			                        *Link to CardLink data mart;
libname siw			"&dir_siw."; 								                                *Common data storage: Basel,IW and parameters;
libname stg			"&dir_stg.";
libname fact		"&dir_fact.";
libname mart		"&dir_mart.";

/* ************************************************************************* */
/* Excel Datevalue vs SAS Datavalue; 										                     */
/* 01Jan1990 in excel = 32874 while that in SAS = 10958;					           */
/* 28Mar2013 in excel = 41361 while that in SAS = 19445;					           */
/* So that implies the diff = 21916											                     */
/* ************************************************************************* */
%let dt_f_x2s 		= 21916;

/* ************************************************************************* */
%let st_RptMth		= 201412 ; *If Blank, the value is current month minus 1 month;
%Auto_RptMth();
%let dt_RptMth		= %SYSFUNC(intnx(MONTH,%SYSFUNC(inputn(&st_RptMth.01,yymmdd8.)),0,END));
%let st_RptYMD		= %SYSFUNC(putn(&dt_RptMth.,yymmddn8.));
%let st_RptYMD6		= %SYSFUNC(putn(&dt_RptMth.,yymmddn6.));
%let st_RptYYMM		= %SYSFUNC(putn(&dt_RptMth.,yymmn4.));
/* ************************************************************************* */
