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

*calculate quantiles of income change 
global n_centiles_inc = 5
xtile income_change_quintile = delta_log_y if ten_years_data==1, n($n_centiles_inc ) 
tsset

forvalues i = 0(1) $n_centiles_inc {
	matrix income_cons_path`i' = J(10,3 , .)
}
*need to calculate for lags and lead separately
global tick_labels = ""
forvalues t = 0 (1) 4 {
	forvalues i = 0(1) $n_centiles_inc {
		summ L`t'.log_y if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+1, 2] = r(mean)
		summ L`t'.log_c if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+1, 3] = r(mean)
		matrix income_cons_path`i'[`t'+1, 1] = `t'
	}
	global temp_tick = `t'-4
	global tick_labels $tick_labels $temp_tick
}
forvalues t = 1 (1) 5 {
	forvalues i = 0(1) $n_centiles_inc {
		summ F`t'.log_y if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+5, 2] = r(mean)
		summ F`t'.log_c if income_change_quintile==`i', meanonly
		matrix income_cons_path`i'[`t'+5, 3] = r(mean)
		matrix income_cons_path`i'[`t'+5, 1] = `t'
	}
	global tick_labels $tick_labels `t'
}

forvalues i = 0(1) $n_centiles_inc {
	matrix rown income_cons_path`i' = $tick_labels
	matrix list income_cons_path`i'
}

coefplot (matrix(income_cons_path1[.,2])) (matrix(income_cons_path2[.,2]) ), ///
vertical recast(line)   ///
ytitle(Log Income) nooffset xtitle(Time for Habit Formation) title(Habit Formation: Time from Permanent Shock) name(habits3)
graph save ${figures}/${run}_income_cons_path.gph, replace



