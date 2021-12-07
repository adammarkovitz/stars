********************************************************************************
** 			File 4: difference-in-differences models
********************************************************************************

clear all
capture log close

log using "$log/did4 did 100pct", replace

use "$data/did_detrend_100pct", clear
keep y* ma year $x dum bal* fips iptw0 post
mat m = J(40,7,0)
loc n=1
* overall
forvalues t=0/2 {
	preserve
	keep if bal`t'==1
	qui reg y`t' i.ma##i.year $x i.dum if year<=2011, vce(cluster fips)
	qui margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]

	reg y`t' i.ma##i.post $x i.dum, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], e(N)
	loc n=`n'+1
	restore
}
forvalues t=3/3 {
	preserve
	keep if bal`t'==1
	qui reg y`t' i.ma##i.year $x i.dum if year<=2011 [pw=iptw0], vce(cluster fips)
	qui margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]
	reg y`t' i.ma##i.post $x i.dum, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], e(N)
	loc n=`n'+1
	restore
}

* 9 measures
forvalues d=1/9 {
forvalues t=0/2 {
	preserve
	keep if bal`t'==1 & dum==`d'
	qui reg y`t' i.ma##i.year $x if year<=2011, vce(cluster fips)
	qui margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]

	reg y`t' i.ma##i.post $x, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], e(N)
	loc n=`n'+1
	restore
}
forvalues t=3/3 {
	preserve
	keep if bal`t'==1 & dum==`d'
	qui reg y`t' i.ma##i.year $x if year<=2011 [pw=iptw0], vce(cluster fips)
	qui margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]

	reg y`t' i.ma##i.post $x, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], e(N)
	loc n=`n'+1
	restore
}
}

mat li m
clear
svmat double m
save "$mat/did_detrend_robust_100pct", replace

* keep main specification (full sample) for main exhibit
gen keep=.
forvalues i=1(4)40 {
	replace keep=1 in `i'
}
keep if keep==1
drop keep
save "$mat/did_detrend_100pct", replace

log close
