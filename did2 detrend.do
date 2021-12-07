********************************************************************************
** 			File 2: remove pre-period trends
********************************************************************************

clear all
capture log close

log using "$log/did2 detrend 100pct", replace

use "$data/did_robust_100pct", clear
keep y ma year $x dum year bal* fips iptw0
keep if year<=2011
mat m = J(20,6,0)

* estimate pre-period trends for overall quality (pooling 9 performance measures)
loc n=1
loc d=0
loc j=1
sca d=`d'
mat m[`n',`j']=(d\d),(0\1)
loc j=`j'+2
** detrend each of 9 samples
forvalues b=0/2 {
	preserve
	di "OUTCOME `d' bal `b'"
	keep if bal`b'==1
	reg y c.ma##c.year $x i.dum, vce(cluster fips)
	sca b0=_b[year]
	lincom _b[year]+_b[c.ma#c.year]
	mat m[`n',`j']= (b0\r(estimate))
	loc j=`j'+1
	restore
}
preserve
** detrend inverse probability of treatment weight data
di "OUTCOME`d' IPTW"
reg y c.ma##c.year $x i.dum [pw=iptw0], vce(cluster fips)
sca b0=_b[year]
lincom _b[year]+_b[c.ma#c.year]
mat m[`n',`j']= (b0\r(estimate))
loc j=`j'+1
restore
loc n=`n'+2

* estimate pre-period trends for each of the 9 individual performance measures
forvalues d=1/9 {
	loc j=1
	sca d=`d'
	mat m[`n',`j']=(d\d),(0\1)
	loc j=`j'+2
	forvalues b=0/2 {
		preserve
		di "OUTCOME `d' bal `b'"
		keep if dum==`d' & bal`b'==1
		reg y c.ma##c.year $x, vce(cluster fips)
		sca b0=_b[year]
		lincom _b[year]+_b[c.ma#c.year]
		mat m[`n',`j']= (b0\r(estimate))
		loc j=`j'+1
		restore
	}
	preserve
	di "OUTCOME`d' IPTW"
	keep if dum==`d'
	reg y c.ma##c.year $x [pw=iptw0], vce(cluster fips)
	sca b0=_b[year]
	lincom _b[year]+_b[c.ma#c.year]
	mat m[`n',`j']= (b0\r(estimate))
	loc j=`j'+1
	restore
	loc n=`n'+2
}

mat li m
clear
svmat double m

rename m1 dum
rename m2 ma
rename m3 trend0
rename m4 trend1
rename m5 trend2
rename m6 trend3

save "$mat/pretrend_dum_ma_100pct", replace

* merge pre-period estimates with raw data
use "$data/did_robust_100pct", clear
merge m:1 ma dum using "$mat/pretrend_dum_ma_100pct", nogen

* detrend overall quality and each of the 9 individual performance measures
forvalues i=0/3 {
	gen y`i'=y-trend`i'*(year-2009)
}
gen byte bal3=1

loc x dum year ma y* $x year bal0 bal1 bal2 bal3 fips iptw0 r post
order `x'
keep `x'
compress

save "$data/did_detrend_100pct", replace
keep if r<.01
save "$data/did_detrend_01pct", replace

log close
