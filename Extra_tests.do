*****************************************************************************
*
* Find MPCs for a multitude of different characteristics
*
*
*****************************************************************************
*Debt
xtile debt_quintile = debt_h , n($n_centiles) 
tsset

*Transitory shocks by Debt
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 1(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if debt_quintile== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(MPC_by_debt Quintile) title(MPC out of Transitory Shocks by Debt) name(debt_quintiles_transitory)
graph save ${figures}/${run}_debt_quintiles_transitory.gph, replace

*Permanent shocks by debt
matrix MPC_by_debt = J($n_centiles +1,3,.)
global tick_labels = ""
forvalues i = 1(1) $n_centiles {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if debt_quintile== `i', robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_debt[`i'+1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `i'
	disp e(N)
	}
matrix coln MPC_by_debt = MPC lcb ucb
matrix rown MPC_by_debt = $tick_labels
coefplot (matrix(MPC_by_debt[.,1]), ci((MPC_by_debt[.,2] MPC_by_debt[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Debt Quintile) title(MPC out of Permanent Shocks by Debt) name(debt_quintiles_permanent)
graph save ${figures}/${run}_debt_quintiles_permanent.gph, replace


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

*Homeowner transitory
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if (real_estate_h>0 & real_estate_h!=.), robust  
*Non-Homeowner transitory
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if real_estate_h==0, robust 

if $production_run !=1 {
	replace real_estate_h = 0 if random_noise>0.94
}

*Homeowner permanent
ivreg2 delta_log_c  (delta_log_y = instrument) if (real_estate_h>0 & real_estate_h!=.), robust  
*Non-Homeowner permanent
ivreg2 delta_log_c  (delta_log_y = instrument) if real_estate_h==0, robust 

**************
*To Add
*Single/couple
*Income (in year t-4?)
*Profession
*Education
*Wealth


