********************************************************************************
** 			File 5: adjusted quality trends for MA and commercial enrollees
********************************************************************************

clear all
capture log close

log using "$log/did5 trend 01pct", append

global m0 "Full Sample"
global m1 "Quasi-Balanced Panel of Counties"
global m2 "Quaisi-Balanced Panel of Plans"
global m3 "Inverse Probability of Treatment Weights"

* OLS
use "$data/did_detrend_01pct", clear
keep y* ma year $x dum bal* fips iptw0

* overall
loc d 0
forvalues t=0/2 {
	preserve
	keep if bal`t'==1
	qui reg y`t' i.ma##i.year $x i.dum, vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
		saving("$mat/dum`d'_detrend_y`t'_01pct", replace)
		marginsplot, ///
		ylab(0(20)100) ///
		xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ytitle("") xtitle("") ///
		title( ///
		"${p`d'} - ${m`t'} (%)", just(left) size(*.8) place(11) span color(black)) ///
		legend(off)
		graph export "$fig/dum`d'_detrend_y`t'_01pct.png", replace height(1000)
	restore
}
forvalues t=3/3 {
	preserve
	keep if bal`t'==1
	qui reg y`t' i.ma##i.year $x i.dum [pw=iptw0], vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
		saving("$mat/dum`d'_detrend_y`t'_01pct", replace)
		marginsplot, ///
		ylab(0(20)100) ///
		xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ytitle("") xtitle("") ///
		title( ///
		"${p`d'} - ${m`t'} (%)", just(left) size(*.8) place(11) span color(black)) ///
		legend(off)
		graph export "$fig/dum`d'_detrend_y`t'_01pct.png", replace height(1000)
	restore
}

* across 9 measures
forvalues d=1/9 {
forvalues t=0/2 {
	preserve
	keep if bal`t'==1 & dum==`d'
	qui reg y`t' i.ma##i.year $x, vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
		saving("$mat/dum`d'_detrend_y`t'_01pct", replace)
		marginsplot, ///
		ylab(0(20)100) ///
		xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ytitle("") xtitle("") ///
		title( ///
		"${p`d'} - ${m`t'} (%)", just(left) size(*.8) place(11) span color(black)) ///
		legend(off)
		graph export "$fig/dum`d'_detrend_y`t'_01pct.png", replace height(1000)
	restore
}
forvalues t=3/3 {
	preserve
	keep if bal`t'==1 & dum==`d'
	qui reg y`t' i.ma##i.year $x [pw=iptw0], vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
		saving("$mat/dum`d'_detrend_y`t'_01pct", replace)
		marginsplot, ///
		ylab(0(20)100) ///
		xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
		ytitle("") xtitle("") ///
		title( ///
		"${p`d'} - ${m`t'} (%)", just(left) size(*.8) place(11) span color(black)) ///
		legend(off)
		graph export "$fig/dum`d'_detrend_y`t'_01pct.png", replace height(1000)
	restore
}
}

* non-detrended
use "$data/did_detrend_01pct", clear
keep y ma year $x dum fips
* overall
loc d 0
preserve
reg y i.ma##i.year $x i.dum, vce(cluster fips)
margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
	saving("$mat/dum`d'_trend_01pct", replace)
	marginsplot, ///
	ylab(0(20)100) ///
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	ytitle("") xtitle("") ///
	title( ///
	"${p`d'} - Full Sample (%)", just(left) size(*.8) place(11) span color(black)) ///
	legend(off)
	graph export "$fig/dum`d'_trend_01pct.png", replace height(1000)
restore

* across 9 measures
forvalues d=1/9 {
preserve
keep if dum==`d'
reg y i.ma##i.year $x, vce(cluster fips)
margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
	saving("$mat/dum`d'_trend_01pct", replace)
	marginsplot, ///
	ylab(0(20)100) ///
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	ytitle("") xtitle("") ///
	title( ///
	"${p`d'} - Full Sample (%)", just(left) size(*.8) place(11) span color(black)) ///
	legend(off)
	graph export "$fig/dum`d'_trend_01pct.png", replace height(1000)
restore
}

log close
