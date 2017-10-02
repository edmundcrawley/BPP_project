********************************************************************************
* 
* DATACREATION AND SAMPLE SELECTION
*
********************************************************************************

* generates the variables we're interested in: unexplained income and consumption

* generates different datasets to run the analysis on (for robustness checks)

// READ DATA
*  ============================================================================

if $production_run == 1 {
	use ${savedirectory_edmund}/consumption_ecr_sample.dta, clear

	keep b_year *_h hh_id lnr year

	*merge m:1 lnr using ${rawdata}/constant_traits.dta, keep(match merge) keepusing( b_year male im_cat first_stay_year) nogenerate
	merge m:1 lnr using ${rawdata}/education_nus2000.dta, ///
		keep(match master) keepusing(edlevel) nogenerate
	merge 1:1 lnr year using ${rawdata}/marital_cohabit_93_14.dta, ///
		keep(match master) keepusing(male marital) nogenerate
	merge 1:1 lnr year using ${rawdata}/address_1992_2014.dta, ///
		keep(match master) keepusing(postnr) nogenerate
	merge 1:1 lnr year using ${rawdata}/consumption9411.dta, ///
		keep(match master) keepusing(children) 

	save ${savedirectory}/datacreation_merged.dta, replace
}
else {
	use ${savedirectory_edmund}/consumption_ecr_dummy.dta, clear
	gen random_noise = uniform()
	gen b_year = 1948 if random_noise<0.5
	replace b_year = 1975 if random_noise>=0.5
	keep b_year *_h hh_id lnr year
	gen random_noise = uniform()
	gen edlevel = 10 if random_noise<0.3
	replace edlevel = 15 if random_noise>=0.3
	gen male = 1 if random_noise<0.5
	replace male = 0 if random_noise>=0.5
	gen marital = 2 if random_noise<0.7
	replace marital = 1 if random_noise>=0.7
	gen postnr = 5200 if random_noise<0.6
	replace postnr = 7200 if random_noise>=0.6
	gen children = 0 if random_noise<0.4
	replace children = 1 if random_noise>=0.4
}


// GET HOUSHOUSEHOLD LEVEL VARIABLES
*  ============================================================================

* family size
bysort hh_id year: egen kids = max(children)
bysort hh_id year: g no_of_adults = _N
g family_size = no_of_adults + kids
*NOTE: check in the log file here how many missing data points are created here

/*
* Equivalence scale
* use the square root of the number of family members, I think that is what BGM does.
* also, set the variable male to missing so that we ca get gender dummy for
* one-person households

replace nobs = nobs + kids
g equivalence_scale = sqrt(nobs) 
replace male = . if nobs != 1
drop nobs
*/

* save the income measures that we want to use for the analysis later:

* household total earnings (labor related income)
* household after-tax earnings
* total income (including capital gains (not on housing))

gen earnings_transfers_h = salary_h + transfers_h
gen log_earnings_trans_h = log(earnings_transfers_h)
gen income_after_tax_h = inc_at_h
gen log_income_after_tax_h = log(income_after_tax_h)
gen total_income_h = sainnt_h
gen log_total_income_h = log(total_income_h)

/*
*equivalize
replace earnings_transfers_h = earnings_transfers_h/equivalence_scale
replace income_after_tax_h = income_after_tax_h/equivalence_scale
replace total_income_h = total_income_h/equivalence_scale
*/

* get the age of the oldest adult
g t_age = year-b_year
bysort hh_id year: egen age = max(t_age)
drop t_ 

bysort hh_id year: g nobs = _n
*We should possibly replace edlevel with the education level of the male
*Presently it will be randomly either the education level of the male or female
replace edlevel = edlevel[2] if nobs != 1 & male!=1
drop if nobs != 1
drop nobs




// GET RESIDUAL OF LOG INCOME AND LOG CONSUMPTION
*  ============================================================================

* THE CONTROLS THAT BLUNDELL, GRABER AND MOGSTAD USES
* quadratic polynomial in age
* dummies for 	- marital status
*		- education
*		- region
* 		- family size 

* BPP ALSO HAS
* year dummies
* year of birth dummies
* employment status dummies - Why???
* race dummies
* # of kids dummies
* dummy for income recipient other than husband or wife
* big city dummy
* dummy for kids not in FU (?)
* interactions:
* 	-educ*year
*	-race*year
*	-employment staus*year
* 	-region*year
*	-big city*year


* for now, Im using as controls_
* 	- dummies for marital status
* 	- dummies for education level
* 	- dummies for region
* 	- dummies for year
*	- interaction year*region
* 	- interaction year*education level
* 	- dummies for family size
*	- dummies for birth year


replace marital = 0 if marital == .

g region = 1
replace region = 2 if (postnr>= 4400 & postnr < 5000) // Sørlandet
replace region = 3 if (postnr>= 5000 & postnr < 7000) // Vestlandet
replace region = 4 if (postnr>= 7000 & postnr < 7900) // Trøndelag
replace region = 5 if postnr >= 7900 
drop postnr

xi, pre(D_) noomit 	i.marital i.edlevel*i.year i.region*i.year ///
			i.family_size i.b_year

foreach depvar in log_earnings_trans_h log_income_after_tax_h log_total_income_h {
	cap drop p995
	bysort `depvar': egen p995 = pctile(`depvar' ),p(99.5)
	cap drop p005
	bysort `depvar': egen p005 = pctile(`depvar' ),p(0.5)
	cap drop non_extreme
	gen non_extreme = `depvar'>=p005 & `depvar'<=p995
	qui reg `depvar' D_* male age* if non_extreme, vce(cluster hh_id)
	predict residual_`depvar', residuals
}

gen log_consumption_h = log(consumption_h)
cap drop p995
bysort log_consumption_h: egen p995 = pctile(log_consumption_h),p(99.5)
cap drop p005
bysort log_consumption_h: egen p005 = pctile(log_consumption_h),p(0.5)
cap drop non_extreme
gen non_extreme = log_consumption_h>=p005 & log_consumption_h<=p995
qui reg log_consumption_h D_* male age* if non_extreme, vce(cluster hh_id)
predict residual_log_consumption if e(sample), residuals


* caculate log changes in income
rename residual_log_earnings_trans_h log_y1
la var log_y1 "labor related income (earnings + transfers)"
rename residual_log_income_after_tax_h log_y2
la var log_y2 "income after tax"
rename residual_log_total_income_h log_y3
la var log_y3 "earnings + transfers + capital income"

drop D_* male

* panel var is hh_id, time var is year
tsset hh_id year

* drop large changes (more than 500% increase, or 80% decrease as in Kaplan Violante)
forv i = 1/3 {
	g delta_log_y`i' = D.log_y`i'
	drop if delta_log_y`i' ==.
	drop if delta_log_y`i' > log(change_size_drop)
	drop if delta_log_y`i' < -log(change_size_drop)
}

* calculate log changes in consumption
g delta_log_c = D.residual_log_consumption

* and drop large changes
drop if delta_log_c ==.
drop if delta_log_c > log(change_size_drop)
drop if delta_log_c < -log(change_size_drop)



// SAVE AND CLOSE
*  ============================================================================

save ${savedirectory}/datacreation_full_sample.dta, replace


