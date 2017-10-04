******************************************************************************
*
*	Children under 18
*
*	This do file generates a new dataset where we can find the number of
*	children for each parent
*	
******************************************************************************

clear
cap log close
macro drop _all
est clear
graph drop _all
set more off, permanently

// PATHS
*  ==========================================================================

global rawdata = "/ssb/stamme01/wealth5/wk48/raw"
global savedirectory = "/ssb/stamme01/wealth5/wk48/hon"	
global logfile = "/ssb/stamme01/wealth5/dok/hon"
global dofiles = "/ssb/stamme01/wealth5/prog/hon"

// LOG
*  ==========================================================================

log using ${logfile}/children_new_variable.log, replace

// READ DATA
*  ==========================================================================

* fix some stuff in the spousal variable first
u ${rawdata}/marital_cohabit_93_14.dta

* get rid of low numbers, they should be missing
replace spousal_lnr = . if spousal_lnr <= 99999

	
* see when a persn gets a new spouse
bysort lnr (year): g newspouse = spousal_lnr != spousal_lnr[_n-1]
bysort lnr (year): g count = year
replace count = 0 if count > 1
bysort lnr (year): g spousecount = sum(newspouse)
replace spousecount = spousecount - count
drop count

* make a married dummy
g newmarital = (marital != 2 | marital != 6) // both hetero and gay couples

* identify periods of single or hitched
egen p = group(newmarital spousal_lnr spousecount), m
bysort lnr (year): replace newspouse = 1 if (spousal_lnr == spousal_lnr[_n+1] & ///
						newmarital == 0 & ///
						newmarital[_n+1] == 1)
bysort p: egen p2 = total(newspouse)

*choose when to use the person in spousal lnr as actual spouse
g double s_lnr = spousal_lnr
format s_lnr %15.0g
replace s_lnr = . if p2 == 0 & newmarital == 0
replace s_lnr = spousal_lnr if marital == 0 & spousal_lnr != .

keep lnr year s_lnr

save ${savedirectory}/spouses.dta, replace
clear


* make a dataset with parents and kids

u ${rawdata}/lnr_mlnr_flnr_updated2013, clear
merge 1:1 lnr using ${rawdata}/constant_traits.dta, ///
	keepusing(b_year) keep (match master) nogenerate
drop if b_year < 1973
save ${savedirectory}/mothers.dta, replace
rename lnr kid
rename flnr lnr
save ${savedirectory}/fathers.dta, replace
u ${savedirectory}/mothers.dta, clear
rename lnr kid
rename mlnr lnr
append using ${savedirectory}/fathers.dta 
duplicates drop
forv i = 1991/2014 {
	local j = `i'-1990
	g year`j' = `i'
}
reshape long year, i(lnr kid b_year flnr mlnr) j(count)
drop count	
merge m:1 lnr year using ${savedirectory}/spouses.dta, ///
	keep(match) nogenerate 


// CREATE THE VARIABLE
*  ==========================================================================

g under18 = year-b_year < 18
drop if under18 == 0
drop if year < b_year
drop under18

g parents_together = (mlnr == s_lnr & mlnr != .) | ///
		     (flnr == s_lnr & flnr != .)
g kids_to_be_counted = 1 - parents_together 
replace kids_to_be_counted = 1 if lnr == mlnr
bysort lnr year: egen children_u18 = total(kids_to_be_counted)
la var children_u18 "has the right number of children under 18 only if you sum over the household"

bysort lnr year: g children_u18_i = _N
la var children_u18_i "the number of children belonging to a parent"

keep lnr year chidren_*
duplicates drop

// SAVE AND CLOSE
*  ==========================================================================
save ${savedirectory}/children.dta, replace
log close

erase ${savedirectory}/fathers.dta
erase ${savedirectory}/mothers.dta
erase ${savedirectory}/spouses.dta

clear
