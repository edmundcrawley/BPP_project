*****************************************************************************
* MPC out of transitory and permanen shocks by deposits
*****************************************************************************


* DEPOSITS

*Divide into quintiles of deposits as a percentage of income
gen deposits_ratio = deposits_h/inc_at_h
global n_centiles = 5
xtile deposit_ratio_quintile = deposits_ratio if deposits_ratio>0, n($n_centiles )
replace deposit_ratio_quintile = 0 if deposits_ratio==0

* see average deposits in each quintile
tabstat deposits_h, by(deposit_ratio_quintile) s(mean)

*make sure code runs on dummy data
if $production_run != 1 {
	replace random_noise = uniform()
	replace deposit_ratio_quintile = 0 if random_noise<0.2
}

*Transitory shocks by deposit
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if deposit_ratio_quintile== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Deposit Quintile) title(MPC out of Transitory Shocks by Deposits) name(deposit_quintiles_transitory)
graph save ${figures}/${run}_deposit_quintiles_transitory.gph, replace

*Permanent shocks by deposit
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if deposit_ratio_quintile== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Deposit Quintile) ///
	title(MPC out of Permanent Shocks by Deposits) ///
	name(deposit_quintiles_permanent)
graph save ${figures}/${run}_deposit_quintiles_permanent.gph, replace

*Let's see if the MPC to permanent shocks for the top quintile increases over time
*May need to use the full sample to see this clearly
matrix MPC_habit = J(9,3,.)
global tick_labels = ""
forvalues j = 2/10 {
	global jminus1 = `j'-1
	cap drop instrument`j'
	gen instrument`j' = F.log_y  - L`j'.log_y
	quietly ivreg2 delta_log_c (delta_log_y = instrument`j') if deposit_ratio_quintile== 5 & real_estate_h > 0, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_habit[`j'-1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `j'
	disp e(N)
}
matrix coln MPC_habit = MPC lcb ucb
matrix rown MPC_habit = $tick_labels
coefplot (matrix(MPC_habit[.,1]), ci((MPC_habit[.,2] MPC_habit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Time for Habit Formation) ///
	title(Habit Formation: Time from Permanent Shock) ///
	name(top_quintile_habits)
graph save ${figures}/${run}_top_quintile_habits.gph, replace

*do the same but only for households who actually remain in the sample
gen final_sample = e(sample)
matrix MPC_habit = J(9,3,.)
global tick_labels = ""
forvalues j = 2/10 {
	global jminus1 = `j'-1
	cap drop instrument`j'
	gen instrument`j' = F.log_y  - L`j'.log_y
	quietly ivreg2 delta_log_c (delta_log_y = instrument`j') if final_sample==1, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_habit[`j'-1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `j'
	disp e(N)
}
matrix coln MPC_habit = MPC lcb ucb
matrix rown MPC_habit = $tick_labels
coefplot (matrix(MPC_habit[.,1]), ci((MPC_habit[.,2] MPC_habit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Time for Habit Formation) ///
	title(Habit Formation: Time from Permanent Shock) ///
	name(top_quintile_habits2)
graph save ${figures}/${run}_top_quintile_habits2.gph, replace


*lets see if there is a difference between homeowners and non-homeowners

xtile deposit_ratio_quintile_ho = deposits_ratio if deposits_ratio>0 & real_estate_h > 0, n($n_centiles )
replace deposit_ratio_quintile_ho = 0 if deposits_ratio==0
xtile deposit_ratio_quintile_nohome = deposits_ratio if deposits_ratio>0 & real_estate_h == 0, n($n_centiles )
replace deposit_ratio_quintile_nohome = 0 if deposits_ratio==0

*Transitory shocks by deposit - HOMEOWNERS
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if deposit_ratio_quintile_ho == `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Deposit Quintile) ///
	title(MPC out of Transitory Shocks by Deposits (Homeowners)) ///
	name(deposits_transitory_ho)
graph save ${figures}/${run}_deposit_quintiles_transitory_ho.gph, replace

*Permanent shocks by deposit - HOMEOWNERS
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if deposit_ratio_quintile_ho == `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Deposit Quintile) ///
	title(MPC out of Permanent Shocks by Deposits (Homeowners)) ///
	name(deposits_permanent_ho)
graph save ${figures}/${run}_deposit_quintiles_permanent_ho.gph, replace

*Transitory shocks by deposit - NON-HOMEOWNERS
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if deposit_ratio_quintile_nohome == `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Deposit Quintile) ///
	title(MPC out of Transitory Shocks by Deposits (Non-homeowners)) ///
	name(deposits_transitory_nohome)
graph save ${figures}/${run}_deposit_quintiles_transitory_nohome.gph, replace

*Permanent shocks by deposit - NON-HOMEOWNERS
matrix MPC_by_deposit = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 0(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if deposit_ratio_quintile_nohome == `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_deposit[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_deposit = MPC lcb ucb
matrix rown MPC_by_deposit = $tick_labels
coefplot (matrix(MPC_by_deposit[.,1]), ci((MPC_by_deposit[.,2] MPC_by_deposit[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Deposit Quintile) ///
	title(MPC out of Permanent Shocks by Deposits (Non-homeowners)) ///
	name(deposits_permanent_nohome)
graph save ${figures}/${run}_deposit_quintiles_permanent_nohome.gph, replace
