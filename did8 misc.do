********************************************************************************
** 			File 8: Miscellaneous descriptive statistics
********************************************************************************

log using "$log/did8 misc 100pct", append

use "$data/did_100pct", clear
count
keep patid ma y year
unique patid if ma==1
unique patid if ma==0

unique patid
di r(sum)/r(unique)

di 47859930/7637152
log close

bys ma: sum y
keep if year>=2012
count if ma==1
count if ma==0
unique patid
unique patid if ma==1
unique patid if ma==0

log close

use "$data/did_01pct", clear
tempvar n
gen `n'=1
bysort patid year: egen count_measure=sum(`n')
order patid 
