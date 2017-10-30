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
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year_since_last_death==3 & L3.cem_matched==1, robust
* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if year_since_last_death==3 & L3.cem_matched==1, robust


* compare with those who are about to lose their parents
* transitory shocks
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if year_since_last_death==-1 & L3.cem_matched==1, robust
* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if year_since_last_death==-1 & L3.cem_matched==1, robust

* who are these people?
capture drop homeowner
g homeowner = realestate_h > 0

*summary statistics of those who have just lost their parents
tabstat age inc_at_h edlevel deposits_h debt_h homeowner ///
	if year_since_last_death == 3 & L3.cem_matched==1, ///
	s(mean sd) //
	c(s)

* summary statistics of those who are about to loose their parents
tabstat age inc_at_h edlevel deposits_h debt_h homeowner ///
	if year_since_last_death == -1 & L3.cem_matched==1, ///
	s(mean sd) //
	c(s)

* Do regression that compares the two groups statistically
gen treatment = year_since_last_death==3 & L3.cem_matched==1
gen delta_log_y_treatment = treatment*delta_log_y
gen Fdelta_log_y_treatment = treatment*F.delta_log_y
gen instrument_treatment = treatment*instrument
* transitory shocks
ivreg2 delta_log_c treatment (delta_log_y delta_log_y_treatment = F.delta_log_y Fdelta_log_y_treatment) if L3.cem_matched==1, robust
* permanent shocks
ivreg2 delta_log_c treatment (delta_log_y delta_log_y_treatment = instrument instrument_treatment) if L3.cem_matched==1, robust

* Look at numerator and denominator
*transitory numerator
correlate delta_log_c F.delta_log_y  if L3.cem_matched==1 & treatment==1, covariance
correlate delta_log_c F.delta_log_y  if L3.cem_matched==1 & treatment==0, covariance
*transitory denominator
correlate delta_log_y F.delta_log_y  if L3.cem_matched==1 & treatment==1, covariance
correlate delta_log_y F.delta_log_y  if L3.cem_matched==1 & treatment==0, covariance

*permanent numerator
correlate delta_log_c instrument  if L3.cem_matched==1 & treatment==1, covariance
correlate delta_log_c instrument  if L3.cem_matched==1 & treatment==0, covariance
*permanent denominator
correlate delta_log_y instrument  if L3.cem_matched==1 & treatment==1, covariance
correlate delta_log_y instrument  if L3.cem_matched==1 & treatment==0, covariance




