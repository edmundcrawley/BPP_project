**************************************************************************
*
*Looks at the long term response to permanent shocks
*
*
**************************************************************************


*Let's see if the MPC to permanent shocks increases over time
*May need to use the full sample to see this clearly
matrix MPC_habit = J(9,3,.)
global tick_labels = ""
cap drop instrument1
gen instrument1 = F.delta_log_y + delta_log_y
forvalues j = 2/10 {
	global jminus1 = `j'-1
	cap drop instrument`j'
	gen instrument`j' = instrument${jminus1} + L${jminus1}.delta_log_y
	quietly ivreg2 delta_log_c (delta_log_y = instrument`j') , robust
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
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Time for Habit Formation) title(Habit Formation: Time from Permanent Shock) name(habits1)
graph save ${figures}/habits1_${run}.gph, replace

*repeat but with only those that are in the final sample
gen long_sample = e(sample)
matrix MPC_habit = J(9,3,.)
matrix cov_dc_djy = J(9,1,.)
matrix cov_dy_djy = J(9,1,.)
global tick_labels = ""
cap drop instrument1
gen instrument1 = F.delta_log_y + delta_log_y
forvalues j = 2/10 {
	global jminus1 = `j'-1
	cap drop instrument`j'
	gen instrument`j' = instrument${jminus1} + L${jminus1}.delta_log_y
	quietly ivreg2 delta_log_c (delta_log_y = instrument`j') if long_sample==1, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_habit[`j'-1,1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels `j'
	disp e(N)
* Also calulate numerator and denominator separately
	quietly correlate delta_log_c instrument`j' if e(sample)==1, covariance
	matrix cov_dc_djy[`j'-1,1] = r(cov_12)
	quietly  correlate delta_log_y instrument`j' if e(sample)==1, covariance
	matrix cov_dy_djy[`j'-1,1] = r(cov_12)
}
matrix coln MPC_habit = MPC lcb ucb
matrix rown MPC_habit = $tick_labels
coefplot (matrix(MPC_habit[.,1]), ci((MPC_habit[.,2] MPC_habit[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Time for Habit Formation) title(Habit Formation: Time from Permanent Shock) name(habits2)
graph save ${figures}/habits2_${run}.gph, replace

* The number we are calculating is cov(delta_log_c, F.log_y - L`j'.log_y)/cov(delta_log_y, F.log_y - L`j'.log_y)
* It would be useful to look at those the numerator and denominator separately
* If the restrictions are correct, the numerator should increase while the denominator stays the same
matrix rown cov_dc_djy = $tick_labels
matrix rown cov_dy_djy = $tick_labels
coefplot (matrix(cov_dc_djy[.,1])) (matrix(cov_dy_djy[.,1]) ), ///
vertical recast(line)   ///
ytitle(covariance) nooffset xtitle(Time for Habit Formation) title(Habit Formation: Time from Permanent Shock) name(habits3)
graph save ${figures}/habits3_${run}.gph, replace

