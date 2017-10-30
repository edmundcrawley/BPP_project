*****************************************************************************
* See if there are differences across education level
*****************************************************************************

* overall

tab edlevel

* are there any differences in the permanent shocks?
matrix MPC_permanent = J(3,4,.)
matrix coln MPC_permanent = Coeff Numerator Denominator yStdDev
matrix rown MPC_permanent = NoHS HS HigherEd
* low education
ivreg2 delta_log_c  (delta_log_y = instrument) if edlevel == 2, robust
matrix MPC_permanent[1,1] = _b[delta_log_y]
correlate delta_log_c instrument if edlevel == 2, covariance
matrix MPC_permanent[1,2] = r(cov_12)
correlate delta_log_y instrument if edlevel == 2, covariance
matrix MPC_permanent[1,3] = r(cov_12)
correlate delta_log_y delta_log_y if edlevel == 2, covariance
matrix MPC_permanent[1,4] = sqrt(r(Var_1))
* high scool educated
ivreg2 delta_log_c  (delta_log_y = instrument) if edlevel == 3, robust
matrix MPC_permanent[2,1] = _b[delta_log_y]
correlate delta_log_c instrument if edlevel == 3, covariance
matrix MPC_permanent[2,2] = r(cov_12)
correlate delta_log_y instrument if edlevel == 3, covariance
matrix MPC_permanent[2,3] = r(cov_12)
correlate delta_log_y delta_log_y if edlevel == 3, covariance
matrix MPC_permanent[2,4] = sqrt(r(Var_1))
* college or higher
ivreg2 delta_log_c  (delta_log_y = instrument) if edlevel == 7, robust
matrix MPC_permanent[3,1] = _b[delta_log_y]
correlate delta_log_c instrument if edlevel == 7, covariance
matrix MPC_permanent[3,2] = r(cov_12)
correlate delta_log_y instrument if edlevel == 7, covariance
matrix MPC_permanent[3,3] = r(cov_12)
correlate delta_log_y delta_log_y if edlevel == 7, covariance
matrix MPC_permanent[3,4] = sqrt(r(Var_1))

matrix list MPC_permanent


* are there any differences in transitory shocks?
* low education
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if edlevel == 2, robust
* high scool educated
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if edlevel == 3, robust
* college or higher
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if edlevel == 7, robust


* See if the age pattern of MPCs are different for the three education level groups



*****************************************************************************
* MPC out of transitory shocks - LOW EDUCATION
*****************************************************************************

global start_age = 30
global age_gap = 5
global num_ages = 7
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if (age <= $this_age & age > $this_age - 5) & (edlevel == 2) , robust
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
	vertical /// 
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Transitory Shocks by Age (Less than high school education)) ///
	name(age_transitory_low_educ)
graph save ${figures}/${run}_age_transitory_low_educ.gph, replace


*****************************************************************************
* MPC out of permanent shocks - LOW EDUCATION
*****************************************************************************

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 7
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if (age <= $this_age & age > $this_age - 5) & (edlevel == 2), robust
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
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Permanent Shocks by Age (Less than high school education)) ///
	name(age_permanent_low_educ)
graph save ${figures}/${run}_age_permanent_low_educ.gph, replace





*****************************************************************************
* MPC out of transitory shocks - HIGH SCHOOL EDUCATION
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
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if (age <= $this_age & age > $this_age - 5) & (edlevel == 3) , robust
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
	vertical /// 
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Transitory Shocks by Age (High school education)) ///
	name(age_transitory_hs_educ)
graph save ${figures}/${run}_age_transitory_hs_educ.gph, replace


*****************************************************************************
* MPC out of permanent shocks - HIGH SCHOOL EDUCATION
*****************************************************************************

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if (age <= $this_age & age > $this_age - 5) & (edlevel == 3), robust
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
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Permanent Shocks by Age (High school education)) ///
	name(age_permanent_hs_educ)
graph save ${figures}/${run}_age_permanent_hs_educ.gph, replace






*****************************************************************************
* MPC out of transitory shocks - HIGHER EDUCATION
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
	quietly ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if (age <= $this_age & age > $this_age - 5) & (edlevel == 7), robust
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
	vertical /// 
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Transitory Shocks by Age (Higher education)) ///
	name(age_transitory_high_educ)
graph save ${figures}/${run}_age_transitory_high_educ.gph, replace


*****************************************************************************
* MPC out of permanent shocks - HIGHER EDUCATION
*****************************************************************************

* Do regression for each age group
global start_age = 30
global age_gap = 5
global num_ages = 10
matrix MPC_by_age = J($num_ages,3,.)
global tick_labels = ""
global this_age = $start_age
forvalues i = 1 (1) $num_ages {
	quietly ivreg2 delta_log_c (delta_log_y = instrument) if (age <= $this_age & age > $this_age - 5) & (edlevel == 7), robust
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
	vertical ///
	recast(line) ///
	ciopts(recast(rline) lpattern(dash)) ///
	ytitle(MPC) ///
	nooffset ///
	xtitle(Age) ///
	title(MPC out of Permanent Shocks by Age (Higher education)) ///
	name(age_permanent_high_educ)
graph save ${figures}/${run}_age_permanent_high_educ.gph, replace


