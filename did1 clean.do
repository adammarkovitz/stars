********************************************************************************
** 			File 1: clean analytic data set
********************************************************************************

* clean FIPS-ZIP HUD file
use "$data/fips/hud_fips_zip", clear
keep zip fips year TOT_RATIO
unique zip year
destring fips, replace
destring zip, replace
gsort zip year -TOT_RATIO 
bysort zip year: keep if _n==1	// keep unique ZIP-FIPS pair
keep fips zip year
compress
sort zip year
save "$data/fips/star1_hud_fips_zip", replace

use "$data/star1", clear
tab dum year
destring zip, replace
compress

merge m:1 zip year using "$data/fips/star1_hud_fips_zip"
drop if _merge==2
drop _merge

rename Patid patid
gen r=runiform()

replace fips=0 if fips==.
replace lis=2 if ma==0

loc x patid year fips y ma $x dum r lis 
order `x'
compress

save "$data/star2", replace

*use "$data/star2", clear
keep if year>=2009 & year<=2018
loc x hrr Product
drop `x'

replace female=female*100

egen plan=group(Group_Nbr)
tempvar n count
bysort plan year: gen `n'=1 if _n==1
bysort plan: egen `count'=sum(`n')
tab `count'
gen byte bal=(`count'==10)
drop `n' `count'

loc x patid year fips y ma $x dum r plan bal lis
order `x'

drop Group_Nbr

compress

mdesc
tab dum year
*use "$data/star3_100pct", clear

save "$data/star3_100pct", replace
keep if r<.01
save "$data/star3_01pct", replace

use "$data/star3_100pct", clear
loc x ma $x
foreach x in `x' {
	drop if `x'==.
}
mdesc

sum
save "$data/did_100pct", replace
keep if r<.01
save "$data/did_01pct", replace

use "$data/did_100pct", clear

* generate IPTW
gen iptw=.
forvalues i=1/9 {

	logit ma if dum==`i'
	predict pn, pr

	logit ma $x i.year if dum==`i'
	predict pd, pr

	replace iptw=pn/pd if ma==1 & dum==`i'
	replace iptw=(1-pn)/(1-pd) if ma==0 & dum==`i'
	
	drop pn pd

}

gen iptw_bal=.
forvalues i=1/9 {

	logit ma if dum==`i' & bal==1
	predict pn, pr

	logit ma $x i.year if dum==`i'& bal==1
	predict pd, pr

	replace iptw_bal=pn/pd if ma==1 & dum==`i' & bal==1
	replace iptw_bal=(1-pn)/(1-pd) if ma==0 & dum==`i' & bal==1
	
	drop pn pd

}

count
keep y year $x dum ma fips year bal plan iptw iptw_bal r
gen byte post=(year>=2012)
gen bal0=1
rename bal bal1
rename iptw iptw0
rename iptw_bal iptw1

tempvar n count
bysort fips ma year: gen `n'=1 if _n==1
bysort fips: egen `count'=sum(`n')
tab `count'
gen byte bal2=(`count'==20)
drop `n' `count'
tab bal2

rename bal1 bal3
rename bal2 bal1
rename bal3 bal2
sum bal0 bal1 bal2

save "$data/did_robust_100pct", replace
keep if r<.01
save "$data/did_robust_01pct", replace
