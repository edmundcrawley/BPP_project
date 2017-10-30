*****************************************************************************
* MPC out of transitory and permanen shocks by debt
*****************************************************************************

* debt quintiles
g dti = debt_h/inc_at_h
xtile dti_quintile_homeowner = dti if dti > 0 & homeowner == 1, n($n_centiles)
replace dti_quintile_homeowner = 0 if dti == 0
xtile dti_quintile_nohome = dti if dti > 0 & homeowner == 0, n($n_centiles)
replace dti_quintile_nohome = 0 if dti == 0
tsset

tabstat dti, by(dti_quintile_homeowner) s(mean)
tabstat dti, by(dti_quintile_nohome) s(mean)


* HOMEOWNERS

*Transitory shocks by Debt
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if dti_quintile_homeowner== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
	vertical /// 
	recast(line) /// 
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset /// 
	xtitle(DTI ratio quintile) ///
	title(MPC out of Transitory Shocks by DTI ratio (Homeowners)) ///
	name(dti_quintiles_ho_transitory)
graph save ${figures}/${run}_dti_quintiles_ho_transitory.gph, replace


*Permanent shocks by debt
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if dti_quintile_homeowner== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(DTI ratio quintile) ///
	title(MPC out of Permanent Shocks by DTI ratio (Homeowners)) ///
	name(dti_quintiles_ho_permanent)
graph save ${figures}/${run}_dti_quintiles_ho_permanent.gph, replace


* NON-HOMEOWNERS

*Transitory shocks by Debt
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if dti_quintile_nohome== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
	vertical /// 
	recast(line) /// 
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset /// 
	xtitle(DTI ratio quintile) ///
	title(MPC out of Transitory Shocks by DTI ratio (Non-homeowners)) ///
	name(dti_quintiles_nohome_transitory)
graph save ${figures}/${run}_dti_quintiles_nohome_transitory.gph, replace



*Permanent shocks by dti
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if dti_quintile_nohome== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(DTI ratio quintile) ///
	title(MPC out of Permanent Shocks by DTI ratio (Non-homeowners)) ///
	name(dti_quintiles_nohome_permanent)
graph save ${figures}/${run}_dti_quintiles_nohome_permanent.gph, replace

