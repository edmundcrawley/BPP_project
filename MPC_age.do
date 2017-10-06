*****************************************************************************
* MPC out of transitory shocks
*****************************************************************************
* This regression estimates the marginal propensity to consume for everyone
ivreg2 delta_log_c (delta_log_y = F.delta_log_y), robust 

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if age== $this_age, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_age[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels $this_age
	global this_age = $this_age + $age_gap
	disp e(N)
	}
matrix coln MPC_by_age = MPC lcb ucb
matrix rown MPC_by_age = $tick_labels

coefplot (matrix(MPC_by_age[.,1]), ci((MPC_by_age[.,2] MPC_by_age[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Age) title(MPC out of Transitory Shocks by Age) name(age_transitory)
graph save ${figures}/${run}_age_transitory.gph, replace

* Test different instruments for the transitory shock to see robustness of results
* Also calulate numerator and denominator separately
gen F2 = F2.log_y-log_y
gen F3 = F3.log_y-log_y
gen F4 = F4.log_y-log_y
ivreg2 delta_log_c (delta_log_y = F.delta_log_y), robust 
correlate delta_log_c F.delta_log_y, covariance
correlate delta_log_y F.delta_log_y, covariance
ivreg2 delta_log_c (delta_log_y = F2), robust 
correlate delta_log_c F2, covariance
correlate delta_log_y F2, covariance
ivreg2 delta_log_c (delta_log_y = F3), robust 
correlate delta_log_c F3, covariance
correlate delta_log_y F3, covariance
ivreg2 delta_log_c (delta_log_y = F4), robust 
correlate delta_log_c F4, covariance
correlate delta_log_y F4, covariance
drop F2 F3 F4


*****************************************************************************
* MPC out of permanent shocks
*****************************************************************************
* This regression estimates the marginal propensity to consume for everyone
gen instrument = F.log_y +  L2.delta_log_y
ivreg2 delta_log_c (delta_log_y = instrument), robust 

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if age== $this_age, robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_age[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	global tick_labels $tick_labels $this_age
	global this_age = $this_age + $age_gap
	disp e(N)
	}
matrix coln MPC_by_age = MPC lcb ucb
matrix rown MPC_by_age = $tick_labels

coefplot (matrix(MPC_by_age[.,1]), ci((MPC_by_age[.,2] MPC_by_age[.,3]) )), ///
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Age) title(MPC out of Permanent Shocks by Age) name(age_permanent)
graph save ${figures}/${run}_age_permanent.gph, replace
