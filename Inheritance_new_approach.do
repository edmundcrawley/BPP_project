****************************************************************************
*
*	Inheritance - new approach
*
****************************************************************************

merge 1:1 lnr year using ${savedirectory_edmund}/all_children_with_income_2.dta, ///
	keep(match master) ///
	keepusing(death_indicator n_parents_alive tot_inh_*) ///
	nogenerate

bysort lnr: egen temp2 = total(death_indicator)
replace death_indicator = 0 if temp2 > 1

g temp = year if death_indicator == 1
bysort lnr: egen year_of_death = total(temp)
drop temp*
g years_since_death = year-year_of_death


tsset
capture drop instrument
gen instrument = F.log_y +  L2.delta_log_y


* very simple regressions of change from year 2-3 after parents death

* transitory shocks
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if years_since_death==3, robust


* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if years_since_death==3, robust


* compare with those who are about to lose their parents

* transitory shocks
ivreg2 delta_log_c (delta_log_y = F.delta_log_y) if years_since_death==-1, robust


* permanent shocks
ivreg2 delta_log_c (delta_log_y = instrument) if years_since_death==-1, robust
