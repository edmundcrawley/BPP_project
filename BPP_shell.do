*****************************************************************************
*
* Shell do file runs all the relevant files for BPP project
*
*
*****************************************************************************

set more off, permanently
macro drop _all

clear
graph drop _all
estimates drop _all
set more off, permanently

global production_run = 0
*global production_run = 1

*change the name depending on which run/version you're running
global run = "firstrun"

* PATHS
if $production_run == 1 {
	global rawdata = "/ssb/stamme01/wealth5/wk48/raw"
	global savedirectory_edmund = "/ssb/stamme01/wealth5/wk48/ecr"
	global savedirectory = "/ssb/stamme01/wealth5/wk48/hon"	
	global figures = "/ssb/stamme01/wealth5/dok/hon/figures"
	global logfile = "/ssb/stamme01/wealth5/dok/hon"
	global dofiles = "/ssb/stamme01/wealth5/prog/hon"
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

*********Now run the codes

* First load data and create unexpected changes to income and consumption
do ${dofiles}/datacreation
* asdf


log close












