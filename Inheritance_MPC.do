*******************************************************************************
* Can we get anything from the inheritance data?
*******************************************************************************

if $production_run == 1 {
	use ${savedirectory}/all_children_k2k_4yearsalary.dta, clear
}
else {
	use ${savedirectory}/all_children_k2k_dummy.dta, clear
}
tsset
gen year_of_death_1 = year if death_indicator==1
by lnr: egen year_of_death = mean(year_of_death_1)
gen year_since_last_death = year - year_of_death
drop year_of_death year_of_death_1
* caculate log changes in income and consumption
gen log_y = log(inc_at_h)
gen log_c = log(consumption_h)
gen delta_log_y = D.log_y
gen delta_log_c = D.log_c

*drop large changes in income (more than 500% increase, or 80% decrease as in Kaplan Violante)
drop if delta_log_y ==.
drop if delta_log_y > log(change_size_drop)
drop if delta_log_y < -log(change_size_drop)
*similarly for consumption
drop if delta_log_c ==.
drop if delta_log_c > log(change_size_drop)
drop if delta_log_c < -log(change_size_drop)

*Transitory shocks
global lags = 5
global leads = 6
matrix MPC_by_inheritance_year = J($lags + $leads +1,3,.)
global tick_labels = ""
forvalues i= -$lags (1) $leads  {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year_since_last_death==`i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_inheritance_year[`i'+$lags +1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
}
matrix coln MPC_by_inheritance_year = MPC lcb ucb
matrix rown MPC_by_inheritance_year = $tick_labels
coefplot (matrix(MPC_by_inheritance_year[.,1]), ci((MPC_by_inheritance_year[.,2] MPC_by_inheritance_year[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Year Since Death) title(MPC out of Transitory Shocks) name(inheritance_transitory)
graph save ${figures}/inheritance_transitory.gph, replace

*Permanent shocks
gen instrument = F.log_y - L2.log_y
matrix MPC_by_inheritance_year = J($lags + $leads +1,3,.)
global tick_labels = ""
forvalues i= -$lags (1) $leads  {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if year_since_last_death==`i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_inheritance_year[`i'+$lags +1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
}
matrix coln MPC_by_inheritance_year = MPC lcb ucb
matrix rown MPC_by_inheritance_year = $tick_labels
coefplot (matrix(MPC_by_inheritance_year[.,1]), ci((MPC_by_inheritance_year[.,2] MPC_by_inheritance_year[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Year Since Death) title(MPC out of Permanent Shocks) name(inheritance_permanent)
graph save ${figures}/inheritance_permanent.gph, replace
