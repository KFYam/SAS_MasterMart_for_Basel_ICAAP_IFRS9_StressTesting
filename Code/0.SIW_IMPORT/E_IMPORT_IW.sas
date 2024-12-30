
/* get the CMV */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_kw_ac_cov, output=siw.vi_iambs_kw_ac_cov_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cf_ac_cov, output=siw.vi_iambs_cf_ac_cov_&st_RptMth.); /* CITIC Finance */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_sz_ac_cov, output=siw.vi_iambs_sz_ac_cov_&st_RptMth.); /* Mainland */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_vc_ac_cov, output=siw.vi_iambs_vc_ac_cov_&st_RptMth.); /* Viewcom */

/* get the EAD and RWA */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_kw_car, 	output=siw.vi_iambs_kw_car_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cf_car, 	output=siw.vi_iambs_cf_car_&st_RptMth.); 	/* CITIC Finance */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_sz_car, 	output=siw.vi_iambs_sz_car_&st_RptMth.); 	/* Mainland */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_vc_car, 	output=siw.vi_iambs_vc_car_&st_RptMth.); 	/* Viewcom */

/* get the Collateral Information*/
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_kw_coll, 	output=siw.vi_iambs_kw_coll_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cf_coll, 	output=siw.vi_iambs_cf_coll_&st_RptMth.); 	/* CITIC Finance */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_sz_coll, 	output=siw.vi_iambs_sz_coll_&st_RptMth.); 	/* Mainland */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_vc_coll, 	output=siw.vi_iambs_vc_coll_&st_RptMth.); 	/* Viewcom */

/* get the Collateral with allocation information*/
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_kw_alc_dtl, output=siw.vi_iambs_kw_alc_dtl_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cf_alc_dtl, output=siw.vi_iambs_cf_alc_dtl_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_sz_alc_dtl, output=siw.vi_iambs_sz_alc_dtl_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_vc_alc_dtl, output=siw.vi_iambs_vc_alc_dtl_&st_RptMth.); 

/* get the Basel ACCT_ID by using SZ-spectific CUST_ID */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamcn_sz_loans, 	output=siw.vi_iamcn_sz_loans_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_sgmfc_cust, 		output=siw.vi_sgmfc_cust_&st_RptMth.); 

/* Customer monthly table (exclude singapore and CBI china branches */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamrm_cust_noid, output=siw.vi_iamrm_cust_noid_&st_RptMth.); 

/* get the account exposure for basel without collateral risk migtiation information*/
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_kw_ac_exp, output=siw.vi_iambs_kw_ac_exp_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cf_ac_exp, output=siw.vi_iambs_cf_ac_exp_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_sz_ac_exp, output=siw.vi_iambs_sz_ac_exp_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_vc_ac_exp, output=siw.vi_iambs_vc_ac_exp_&st_RptMth.); 

/* get the rating information */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamop_corp_rating, 	output=siw.vi_iamop_corp_rating_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamic_cap_excpt, 	output=siw.vi_iamic_cap_excpt_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamic_cap_smry, 	output=siw.vi_iamic_cap_smry_&st_RptMth.); 

/* get the CVA information */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cva_ac_exp, 	output=siw.vi_iambs_cva_ac_exp_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cva_grp_exp, 	output=siw.vi_iambs_cva_grp_exp_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cva_adj, 		output=siw.vi_iambs_cva_adj_&st_RptMth.); 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iambs_cva_rtg, 		output=siw.vi_iambs_cva_rtg_&st_RptMth.); 

/* get the ICAAP information */
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamic_cap_dtl, 		output=siw.vi_iamic_cap_dtl_&st_RptMth.); 


/* Adhoc base 
%ORA_Extract(date=&dt_Rptmth., input=iw.vi_iamop_cust, output=siw.vi_iamop_cust_&st_RptMth.); 
*/
data siw.vi_iacbs_cust_elim_upd_&st_RptMth.;	set iw.vi_iacbs_cust_elim_upd;		run; 
data siw.vi_iacic_cap_coll_typ_upd_&st_RptMth.;	set iw.vi_iacic_cap_coll_typ_upd;	run;
data siw.vi_iacic_cap_userparm_upd_&st_RptMth.;	set iw.vi_iacic_cap_user_parm_upd;	run;
data siw.vi_iacic_cap_clsundwn_upd_&st_RptMth.;	set iw.vi_iacic_cap_cls_undwn_upd;	run;
data siw.Vi_iambs_cva_result_&st_RptMth.;		set iw.vi_iambs_cva_result;			run;
data siw.Vi_iambs_cva_result_&st_RptMth.;		set iw.vi_iambs_cva_result;			run;


