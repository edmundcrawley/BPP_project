*****************************************************************************
* MPC out of transitory shocks
*****************************************************************************


* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
matrix Numerator_by_age = J($num_ages,1,.)
matrix Denominator_by_age = J($num_ages,1,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if (age <= $this_age & age > $this_age - 5) , robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_age[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	*Also calculate numerator and denominator separately
	quietly correlate delta_log_c F.delta_log_y if (age <= $this_age & age > $this_age - 5), covariance
	matrix Numerator_by_age[`i',1] = r(cov_12)
	quietly correlate delta_log_y F.delta_log_y if (age <= $this_age & age > $this_age - 5), covariance
	matrix Denominator_by_age[`i',1] = r(cov_12)
	global tick_labels $tick_labels $this_age
	global this_age = $this_age + $age_gap
	disp e(N)
	}
matrix coln MPC_by_age = MPC lcb ucb
matrix rown MPC_by_age = $tick_labels

coefplot (matrix(MPC_by_age[.,1]), ci((MPC_by_age[.,2] MPC_by_age[.,3]) )), ///
	vertical /// 
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Transitory Shocks by Age) ///
	name(age_transitory)
graph save ${figures}/${run}_age_transitory.gph, replace
*Also plot numerator and denominator by age
coefplot (matrix(Numerator_by_age[.,1])) (matrix(Denominator_by_age[.,1])) , ///
vertical recast(line)   ///
ytitle(Covariance) nooffset xtitle(Age) title(MPC Transitory by Age: Numerator and Denominator) name(age_transitory_num_den)
graph save ${figures}/${run}_age_transitory_num_den.gph, replace




*****************************************************************************
* MPC out of permanent shocks
*****************************************************************************

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
matrix Numerator_by_age = J($num_ages,1,.)
matrix Denominator_by_age = J($num_ages,1,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if (age <= $this_age & age > $this_age - 5), robust
	matrix b = e(b)
	matrix V = e(V)
	matrix MPC_by_age[`i',1] = b[1,1], ///
	b[1,1]-1.96*sqrt(V[1,1]), ///
	b[1,1]+1.96*sqrt(V[1,1])
	*Also calculate numerator and denominator separately
	quietly correlate delta_log_c instrument if (age <= $this_age & age > $this_age - 5), covariance
	matrix Numerator_by_age[`i',1] = r(cov_12)
	quietly correlate delta_log_y instrument if (age <= $this_age & age > $this_age - 5), covariance
	matrix Denominator_by_age[`i',1] = r(cov_12)
	global tick_labels $tick_labels $this_age
	global this_age = $this_age + $age_gap
	disp e(N)
	}
matrix coln MPC_by_age = MPC lcb ucb
matrix rown MPC_by_age = $tick_labels

coefplot (matrix(MPC_by_age[.,1]), ci((MPC_by_age[.,2] MPC_by_age[.,3]) )), ///
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Permanent Shocks by Age) ///
	name(age_permanent)
graph save ${figures}/${run}_age_permanent.gph, replace
*Also plot numerator and denominator by age
coefplot (matrix(Numerator_by_age[.,1])) (matrix(Denominator_by_age[.,1])) , ///
vertical recast(line)   ///
ytitle(Covariance) nooffset xtitle(Age) title(MPC Permanent by Age: Numerator and Denominator) name(age_permanent_num_den)
graph save ${figures}/${run}_age_permanent_num_den.gph, replace





