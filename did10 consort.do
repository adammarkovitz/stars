********************************************************************************
** 			File 10: CONSORT diagram
********************************************************************************

log using "$log/did10 consort 100pct", replace

clear all
capture log close

use "$data/did_100pct", clear
keep patid ma year
duplicates drop patid ma, force
unique patid
unique patid ma

unique patid if ma==1
unique patid if ma==0
loc n=1
bysort patid: egen count=sum(`n')
tab count ma
tab count

gen post=(year>=2012)
count
unique patid
unique patid if ma==1
unique patid if ma==0
forvalues i=0/1 {
	preserve
	keep if post==`i'
	unique patid if ma==1
	unique patid if ma==0
	restore
}

use "$data/star3_100pct", clear

keep if ma!=.

preserve
foreach x in female age ccw {
	drop if `x'==.
}
tempvar miss
gen `miss'=0
foreach x in black educ income pov unemp {
	replace `miss'=1 if `x'==.
}
drop if `miss'==1
mdesc
restore

count
unique patid
foreach x in female age ccw {
	di "re missing `x'"
	count if `x'==.
	unique patid if `x'==.
	drop if `x'==.
	count
	unique patid
}

* ACS data
tempvar miss
gen `miss'=0
foreach x in black educ income pov unemp {
	replace `miss'=1 if `x'==.
}
count if `miss'==1
unique patid if `miss'==1
drop if `miss'==1
count
unique patid

log close
