*****************************************************************************
*
* Find MPCs for a multitude of different characteristics
*
*
*****************************************************************************



* OVER TIME

*Transitory shocks by Year
global first_year = 1997
global last_year = 2011
global num_years = $last_year -$first_year +1
matrix MPC_by_year = J($num_years ,3,.)
global tick_labels = ""
forvalues i = 1(1) $num_years {
	global this_year = $first_year +`i'-1
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year== $this_year, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_year[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels $this_year
	disp e(N)
	}
matrix coln MPC_by_year = MPC lcb ucb
matrix rown MPC_by_year = $tick_labels
coefplot (matrix(MPC_by_year[.,1]), ci((MPC_by_year[.,2] MPC_by_year[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Year) title(MPC out of Transitory Shocks by Year) name(year_transitory)
graph save ${figures}/${run}_year_transitory.gph, replace

/*
*Permanent shocks by Year
matrix MPC_by_year = J($num_years ,3,.)
global tick_labels = ""
forvalues i = 2(1) $num_years {
	global this_year = $first_year +`i'-1
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if year== $this_year, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_year[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels $this_year
	disp e(N)
	}
matrix coln MPC_by_year = MPC lcb ucb
matrix rown MPC_by_year = $tick_labels
coefplot (matrix(MPC_by_year[.,1]), ci((MPC_by_year[.,2] MPC_by_year[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Year) title(MPC out of Permanent Shocks by Year) name(year_permanent)
graph save ${figures}/${run}_year_permanent.gph, replace
*/

if $production_run !=1 {
	replace real_estate_h = 0 if random_noise>0.94
}





* WEALTH
g debt_neg = -debt_h
egen wealth_h = rowtotal(deposits_h mfund_h stocks_h stocks_nonreg_h bonds_h out_claims_h debt_neg)

xtile wealth_quintile = wealth_h, n($n_centiles)
tabstat wealth_h, by(wealth_quintile) s(mean)

matrix MPC_by_wealth = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 1(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if wealth_quintile== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_wealth[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_wealth = MPC lcb ucb
matrix rown MPC_by_wealth = $tick_labels
coefplot (matrix(MPC_by_wealth[.,1]), ci((MPC_by_wealth[.,2] MPC_by_wealth[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Debt Quintile) title(MPC out of Permanent Shocks by Wealth) ///
	name(walth_quintiles_permanent)


* SINGLE/COUPLE
tab no_of_adults
* single
ivreg2 delta_log_c  (delta_log_y = instrument) if no_of_adults == 1, robust
* couples
ivreg2 delta_log_c  (delta_log_y = instrument) if no_of_adults == 2, robust



**************
*To Add:

*Income (in year t-4?)
*Profession



