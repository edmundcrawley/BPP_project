*****************************************************************************
*
* Simulate data and looks at income and consumption paths
*
*
*****************************************************************************

gen perm_shock = rnormal()
gen tran_shock = rnormal()
tsset
gen sim_delta_log_y = perm_shock+tran_shock-L.tran_shock
by hh_id: gen sim_log_y = sum(sim_delta_log_y)

gen sim_delta_log_c = 0.8*perm_shock+0.2*tran_shock
by hh_id: gen sim_log_c = sum(sim_delta_log_c)

*calculate quantiles of income change 
cap drop income_change_quintile
xtile income_change_quintile = sim_delta_log_y, n($n_centiles_inc ) 
tsset

forvalues i = 1(1) $n_centiles_inc {
	matrix income_cons_path`i' = J(10,3 , .)
}
*need to calculate for lags and lead separately
global tick_labels = ""
forvalues t = 0 (1) 4 {
	summ L`t'.sim_log_y, meanonly
	scalar this_log_y_mean = r(mean)
	summ L`t'.sim_log_c, meanonly
	scalar this_log_c_mean = r(mean)
	forvalues i = 1(1) $n_centiles_inc {
		summ L`t'.sim_log_y if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[5-`t', 2] = r(mean) - this_log_y_mean
		summ L`t'.sim_log_c if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[5-`t', 3] = r(mean) - this_log_c_mean
		matrix income_cons_path`i'[5-`t', 1] = `t'
	}
	global temp_tick = `t'-4
	global tick_labels $tick_labels $temp_tick
}
forvalues t = 1 (1) 5 {
	summ F`t'.sim_log_y , meanonly
	scalar this_log_y_mean = r(mean)
	summ F`t'.sim_log_c , meanonly
	scalar this_log_c_mean = r(mean)
	forvalues i = 1(1) $n_centiles_inc {
		summ F`t'.sim_log_y if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+5, 2] = r(mean)- this_log_y_mean
		summ F`t'.sim_log_c if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+5, 3] = r(mean)- this_log_c_mean
		matrix income_cons_path`i'[`t'+5, 1] = `t'
	}
	global tick_labels $tick_labels `t'
}
*check MPC out of transitory shocks for this sample
ivreg2 L.sim_delta_log_c (L.sim_delta_log_y = sim_delta_log_y) , robust 
*check MPC out of permanent shocks for this sample
cap drop sim_instrument
gen sim_instrument = F.sim_log_y - L2.sim_log_y
ivreg2 sim_delta_log_c (sim_delta_log_y = sim_instrument) , robust 

forvalues i = 1(1) $n_centiles_inc {
	matrix rown income_cons_path`i' = $tick_labels
	matrix list income_cons_path`i'
}
* plot income paths
coefplot (matrix(income_cons_path1[.,2])) (matrix(income_cons_path2[.,2])) (matrix(income_cons_path3[.,2])) (matrix(income_cons_path4[.,2])) (matrix(income_cons_path5[.,2]) ), ///
vertical recast(line)   ///
ytitle(Log Income) nooffset xtitle(Time) title(Income Path by Shock Quintile) name(income_path_sim)
graph save ${figures}/${run}_income_path_sim.gph, replace
*plot consumption paths
coefplot (matrix(income_cons_path1[.,3])) (matrix(income_cons_path2[.,3])) (matrix(income_cons_path3[.,3])) (matrix(income_cons_path4[.,3])) (matrix(income_cons_path5[.,3]) ), ///
vertical recast(line)   ///
ytitle(Log Consumption) nooffset xtitle(Time) title(Consumption Path by Shock Quintile) name(consumption_path_sim)
graph save ${figures}/${run}_consumption_path_sim.gph, replace
