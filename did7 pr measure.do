********************************************************************************
** 			File 7: Probability of eligibility for performance measures
********************************************************************************

clear all
capture log close

log using "$log/did7 pr measure 100pct", replace

use "$data/star_cohort1", clear
rename Patid patid
loc x ma $x
foreach x in `x' {
	drop if `x'==.
}
mdesc

keep year ma patid breast a1c statins rasa diabetes dmard
gen byte none = 1
foreach i in breast a1c statins rasa diabetes dmard {
	replace none = 0 if `i' == 1
}
gen byte n = 1
gcollapse (sum) n none breast a1c statins rasa diabetes dmard, by(year ma)
foreach i in none breast a1c statins rasa diabetes dmard {
	replace `i' = `i'/n
}
save "$mat/pr_measure_100pct", replace

log close
