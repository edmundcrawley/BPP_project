*****************************************************************************
*
* Shell do file runs all the relevant files for BPP project
*
*
*****************************************************************************


clear
macro drop _all
graph drop _all
est drop _all
set more off, permanently

set scheme s1color, permanent

*global production_run = 0
global production_run = 1

*change the name depending on which run/version you're running
global run = "after_tax"

* put you're name here when you're the one running the files
global name = "hon"

* PATHS
if $production_run == 1 {
	global rawdata = "/ssb/stamme01/wealth5/wk48/raw"
	global savedirectory_edmund = "/ssb/stamme01/wealth5/wk48/ecr"
	global savedirectory = "/ssb/stamme01/wealth5/wk48/${name}"	
	global figures = "/ssb/stamme01/wealth5/dok/${name}/figures"
	global logfile = "/ssb/stamme01/wealth5/dok/${name}"
	global dofiles = "/ssb/stamme01/wealth5/prog/${name}"
}
else {
	global rawdata = "C:\Users\edmun\OneDrive\Documents\Research\Norway\DummyDataFromSSB"
	global savedirectory_edmund = "C:\Users\edmun\OneDrive\Documents\Research\Norway\DummyDataFromSSB"
	global savedirectory = "C:\Users\edmun\OneDrive\Documents\Research\Norway\BPP_project\data"
	global figures = "C:\Users\edmun\OneDrive\Documents\Research\Norway\BPP_project\figures"
	global logfile = "C:\Users\edmun\OneDrive\Documents\Research\Norway\BPP_project\logs"
	global dofiles = "C:\Users\edmun\OneDrive\Documents\Research\Norway\BPP_project\BPP_project"
}

* log
capture log close
log using ${logfile}/logBPP_${run}.log, replace

di "${run}"


*********Read data and choose variables and instruments************************

* First load data and create unexpected changes to income and consumption
do ${dofiles}/datacreation

* lets run the datacreation and the analysis separately for now 
*u ${savedirectory}/datacreation_everyone_sample.dta, clear
 
* For now let's use after tax income
g log_y = log_y2
g delta_log_y = delta_log_y2

* Define instrument
gen instrument = F.log_y -  L2.log_y



***********Overall regressions*************************************************

do ${dofiles}/MPC_overall


***********Now do the interesting stuff****************************************

* age graphs
do ${dofiles}/MPC_age
* for the rest of the runs we will focus on core working age people
drop if age<25 | age>62
* Look at hand-to-mouth results
do ${dofiles}/Hand_to_mouth
* deposites
do ${dofiles}/MPC_deposits
*debt
do ${dofiles}/MPC_debt
* Look at the slow response of consumption to permanent income shocks
do ${dofiles}/Slow_cons_response
* Draw path of income and consumption of different quartiles of shocks
do ${dofiles}/income_cons_paths

* A bunch of further tests of MPC characteristics
*do ${dofiles}/Extra_tests
*do ${dofiles}/MPC_edlevel
*do ${dofiles}/extra_tests_by_no_of_aduls

* All the extra tests for singles/couples

******************************************************************************

log close


/*
* Other code that might be of interest

* Inheritance MPC - this uses the inheritance data so will clear the dataset

*BPP_method has basically been replace with the individual files run above
*/













