****************************************************************************
*	BPP methodology estimates 
*
*
****************************************************************************
set more off, permanently

global production_run = 0
*global production_run = 1

scalar change_size_drop = 5.0
*scalar change_size_drop = 2.0

* Get the data
if $production_run == 1 {
	global rawdata = "/ssb/stamme01/wealth5/wk48/raw"
	global savedirectory = "/ssb/stamme01/wealth5/wk48/ecr"
	global figures = "/ssb/stamme01/wealth5/dok/ecr/figures"
	use ${savedirectory}/consumption_ecr_sample.dta, clear
	* I think you may need to merge in b_year. Possibly worth saving this in the data so 
	* you don't have to repeatedly do this merge
	merge m:1 lnr using ${rawdata}/constant_traits.dta, keepusing(b_year)
}
else {
	* This loads dummy data for testing
	global savedirectory = "C:\Users\edmun\OneDrive\Documents\Research\Norway\DummyDataFromSSB"
	global figures = "C:\Users\edmun\OneDrive\Documents\Research\Norway\DummyDataFromSSB"
	*use ${savedirectory}/consumption_ecr_dummy.dta, clear
	use ${savedirectory}/all_children_k2k_dummy.dta, clear
}

log using ${figures}/log_BPP.log, replace
tsset

* caculate log changes in income and consumption
gen log_y = log(inc_at_h)
gen log_c = log(consumption_h)
gen delta_log_y = D.log_y
gen delta_log_c = D.log_c
*also calculate age
gen age = year-b_year

*drop large changes in income (more than 500% increase, or 80% decrease as in Kaplan Violante)
drop if delta_log_y ==.
drop if delta_log_y > log(change_size_drop)
drop if delta_log_y < -log(change_size_drop)
*similarly for consumption
drop if delta_log_c ==.
drop if delta_log_c > log(change_size_drop)
drop if delta_log_c < -log(change_size_drop)

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
graph save ${figures}/age_transitory.gph, replace


*****************************************************************************
* MPC out of permanent shocks
*****************************************************************************
* This regression estimates the marginal propensity to consume for everyone
gen instrument = F.log_y - L2.log_y
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
graph save ${figures}/age_permanent.gph, replace


*******************************************************************************
* See if we can replicate Kaplan Violante Wealthy-Hand-to-Mouth
*******************************************************************************
* Identify hand-to-mouth households
* Hand-to-mouth defined as less than half on one month's income as bank deposits

drop if age<25 | age>60

gen hand_to_mouth = 0
replace hand_to_mouth = 1 if deposits_h<0.5*inc_at_h/12.0
gen wealthy_illiquid = 0
replace wealthy_illiquid = 1 if real_estate_h>0 | bonds_h>0 | stocks_h>0 | mfund_h>0 | stocks_nonreg_h>0
gen poor_hand_to_mouth = hand_to_mouth & (wealthy_illiquid==0)
gen wealthy_hand_to_mouth = hand_to_mouth & (wealthy_illiquid==1)
gen hand_to_mouth_status = 0
replace hand_to_mouth_status = 1 if poor_hand_to_mouth==1
replace hand_to_mouth_status = 2 if wealthy_hand_to_mouth==1

*Caculate MPC out of transitory shocks for the different groups
*Non hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==0, robust  
*Poor hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==1, robust  
*Wealthy hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==2, robust  

*Caculate MPC out of permanent shocks for the different groups
*Non hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==0, robust  
*Poor hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==1, robust  
*Wealthy hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==2, robust  

*Divide into quintiles of deposits as a percentage of income
gen deposits_ratio = deposits_h/inc_at_h
global n_centiles = 5
xtile deposit_ratio_quintile = deposits_ratio if deposits_ratio>0, n($n_centiles )
replace deposit_ratio_quintile = 0 if deposits_ratio==0

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
graph save ${figures}/deposit_quintiles_transitory.gph, replace

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
vertical recast(line) ciopts(recast(rline) lpattern(dash)) ///
ytitle(MPC) nooffset xtitle(Deposit Quintile) title(MPC out of Permanent Shocks by Deposits) name(deposit_quintiles_permanent)
graph save ${figures}/deposit_quintiles_permanent.gph, replace

*Let's see if the MPC to permanent shocks for the top quintile increases over time
*May need to use the full sample to see this clearly
matrix MPC_habit = J(9,3,.)
global tick_labels = ""
forvalues j = 2/10 {
gen instrument`j' = F.log_y - L`j'.log_y
	quietly ivreg2 delta_log_c (delta_log_y = instrument`j') if deposit_ratio_quintile== 5, robust
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
ytitle(MPC) nooffset xtitle(Time for Habit Formation) title(Habit Formation: Time from Permanent Shock) name(habits)
graph save ${figures}/habits.gph, replace


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

log close




