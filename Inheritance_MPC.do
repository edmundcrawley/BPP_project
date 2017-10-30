*******************************************************************************
* Can we get anything from the inheritance data?
*******************************************************************************

if $production_run == 1 {
	use ${savedirectory_edmund}/all_children_k2k_4yearsalary.dta, clear
}
else {
	use ${savedirectory}/all_children_k2k_dummy.dta, clear
}
tsset
gen year_of_death_1 = year if death_indicator==1
by lnr: egen year_of_death = mean(year_of_death_1)
gen year_since_last_death = year - year_of_death
drop year_of_death year_of_death_1

* get log changes in income and consumption

merge 1:1 lnr year using ${savedirectory}/datacreation_everyone.dta, ///
	keep(match master) nogenerate keepusing(delta_log_y2 delta_log_c log_y2 log_c)
	
g log_y = log_y2
g delta_log_y = delta_log_y2

* Define instrument
gen instrument = F.log_y -  L2.log_y


* very simple regressions of change from year 2-3 after parents death

* transitory shocks
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year_since_last_death==3, robust


* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if year_since_last_death==3, robust


* compare with those who are about to lose their parents

* transitory shocks
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year_since_last_death==-1, robust


* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if year_since_last_death==-1, robust

* who are these people?
capture drop homeowner
g homeowner = realestate_h > 0

*summary statistics of those who have just lost their parents
tabstat age inc_at_h edlevel deposoits_h debt_h homeowner ///
	if year_since_last_death == 3, ///
	s(mean sd) //
	c(s)

* summary statistics of those who are about to loose their parents
tabstat age inc_at_h edlevel deposoits_h debt_h homeowner ///
	if year_since_last_death == 1, ///
	s(mean sd) //
	c(s)
	

	

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
