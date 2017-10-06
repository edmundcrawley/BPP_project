*****************************************************************************
*
* Explicitly look at the paths of income and consumption conditional
* on high or low unexplained income growth
*
*
*****************************************************************************

* data should already be loaded

gen ten_years_data = 0
replace ten_years_data = 1 if L4.log_y!=. & F5.log_y!=.

*deposit_ratio_quintile should have already been calculated in Hand_to_mouth.do
gen top_deposit_only = 0
replace top_deposit_only = 1 if L4.deposit_ratio_quintile==5

gen include_these = ten_years_data

forvalue this_run = 1 (1) 4 {
	if `this_run'==1 {
		global this_label = "all"
	}
	if `this_run'==2 {
		global this_label = "tdo"
		replace include_these = ten_years_data==1 & top_deposit_only==1
	}
	if `this_run'==3 {
		global this_label = "all_3y"
	}
	if `this_run'==4 {
		global this_label = "tdo_3y"
		replace include_these = ten_years_data==1 & top_deposit_only==1
	}

	*calculate quantiles of income change 
	global n_centiles_inc = 5
	cap drop income_change_quintile
	if `this_run'==1 | `this_run'==2 {
		xtile income_change_quintile = delta_log_y if include_these==1, n($n_centiles_inc ) 
	}
	if `this_run'==3 | `this_run'==4 {
		xtile income_change_quintile = log_y - L3.log_y if include_these==1, n($n_centiles_inc ) 
	}
	tsset

	forvalues i = 1(1) $n_centiles_inc {
		matrix income_cons_path`i' = J(10,3 , .)
	}
	*need to calculate for lags and lead separately
	global tick_labels = ""
	forvalues t = 0 (1) 4 {
		summ L`t'.log_y if include_these, meanonly
		scalar this_log_y_mean = r(mean)
		summ L`t'.log_c if include_these, meanonly
		scalar this_log_c_mean = r(mean)
		forvalues i = 1(1) $n_centiles_inc {
			summ L`t'.log_y if income_change_quintile==`i', meanonly
			matrix income_cons_path`i'[5-`t', 2] = r(mean) - this_log_y_mean
			summ L`t'.log_c if income_change_quintile==`i', meanonly
			matrix income_cons_path`i'[5-`t', 3] = r(mean) - this_log_c_mean
			matrix income_cons_path`i'[5-`t', 1] = `t'
		}
		global temp_tick = `t'-4
		global tick_labels $tick_labels $temp_tick
	}
	forvalues t = 1 (1) 5 {
		summ F`t'.log_y if include_these, meanonly
		scalar this_log_y_mean = r(mean)
		summ F`t'.log_c if include_these, meanonly
		scalar this_log_c_mean = r(mean)
		forvalues i = 1(1) $n_centiles_inc {
			summ F`t'.log_y if income_change_quintile==`i', meanonly
			matrix income_cons_path`i'[`t'+5, 2] = r(mean)- this_log_y_mean
			summ F`t'.log_c if income_change_quintile==`i', meanonly
			matrix income_cons_path`i'[`t'+5, 3] = r(mean)- this_log_c_mean
			matrix income_cons_path`i'[`t'+5, 1] = `t'
		}
		global tick_labels $tick_labels `t'
	}
	*check MPC out of transitory shocks for this sample
	ivreg2 L.delta_log_c (L.delta_log_y = delta_log_y) if include_these, robust 
	*see what is going on with different instruments
	gen F2 = F2.log_y-log_y
	gen F3 = F3.log_y-log_y
	gen F4 = F4.log_y-log_y
	ivreg2 L.delta_log_c (L.delta_log_y = delta_log_y) if include_these, robust 
	correlate L.delta_log_c delta_log_y if include_these, covariance
	correlate L.delta_log_y delta_log_y if include_these, covariance
	ivreg2 L.delta_log_c (L.delta_log_y = L.F2) if include_these, robust 
	correlate L.delta_log_c L.F2 if include_these, covariance
	correlate L.delta_log_y L.F2 if include_these, covariance
	ivreg2 L.delta_log_c (L.delta_log_y = L.F3) if include_these, robust 
	correlate L.delta_log_c L.F3 if include_these, covariance
	correlate L.delta_log_y L.F3 if include_these, covariance
	ivreg2 L.delta_log_c (L.delta_log_y = L.F4) if include_these, robust 
	correlate L.delta_log_c L.F4 if include_these, covariance
	correlate L.delta_log_y L.F4 if include_these, covariance
	drop F2 F3 F4
	
	*check MPC out of permanent shocks for this sample
	ivreg2 delta_log_c (delta_log_y = instrument) if include_these, robust 

	forvalues i = 1(1) $n_centiles_inc {
		matrix rown income_cons_path`i' = $tick_labels
		matrix list income_cons_path`i'
	}
	* plot income paths
	coefplot (matrix(income_cons_path1[.,2])) (matrix(income_cons_path2[.,2])) (matrix(income_cons_path3[.,2])) (matrix(income_cons_path4[.,2])) (matrix(income_cons_path5[.,2]) ), ///
	vertical recast(line)   ///
	ytitle(Log Income) nooffset xtitle(Time) title(Income Path by Shock Quintile) name(income_path_${this_label})
	graph save ${figures}/${run}_income_path_${this_label}.gph, replace
	*plot consumption paths
	coefplot (matrix(income_cons_path1[.,3])) (matrix(income_cons_path2[.,3])) (matrix(income_cons_path3[.,3])) (matrix(income_cons_path4[.,3])) (matrix(income_cons_path5[.,3]) ), ///
	vertical recast(line)   ///
	ytitle(Log Consumption) nooffset xtitle(Time) title(Consumption Path by Shock Quintile) name(consumption_path_${this_label})
	graph save ${figures}/${run}_consumption_path_${this_label}.gph, replace	
}



