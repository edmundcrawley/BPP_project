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

forvalue this_run = 1 (1) 2 {
	if `this_run'==1 {
		global this_label = "all"
	}
	if `this_run'==2 {
		global this_label = "tdo"
		replace include_these = ten_years_data==1 & top_deposit_only==1
	}

	*calculate quantiles of income change 
	global n_centiles_inc = 5
	cap drop income_change_quintile
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



