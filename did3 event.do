********************************************************************************
** 			File 3: event-study of quality for MA and commercial enrollees
********************************************************************************

clear all
capture log close

log using "$log/did3 event 100pct", replace

global m0 "Overall Quality Performance" 
global m1 "Diabetic A1c Monitoring" 
global m2 "Diabetic LDL Screening" 
global m3 "Diabetic Retinopathy Screening" 
global m4 "Diabetic Nephropathy Management" 
global m5 "Breast Cancer Screening" 
global m6 "Rheumatoid Arthritis Management" 
global m7 "Adherence to Statins" 
global m8 "Adherence to RAS Inhibitors" 
global m9 "Adherence to Diabetes Medication"

use "$data/did_detrend_100pct", clear

keep dum y0 ma year $x fips 

forvalues d=1/9 {
	preserve
	di "dum `d'"
	keep if dum==`d'
	count
	reg y0 i.ma##ib2012.year $x, vce(cluster fips)
	margins, dydx(ma) at(year=(2009(1)2018)) noestimcheck force ///
	saving("$mat/event_dum`d'_detrend_100pct", replace)
	marginsplot, ///
	ylab(-30(10)30) ///
	yline(0, lcolor(red) lwidth(thin) lpattern(solid)) ///
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	ytitle("") xtitle("") ///
	title( ///
	"Difference in ${m`d'}" "for MA vs. Commercial Enrollees (pp)", just(left) size(*.85) place(11) span color(black)) ///
	legend(off)
	graph export "$fig/event_dum`d'_detrend_100pct.png", replace height(1000)
	restore
}

loc d=0
reg y0 i.ma##ib2012.year $x i.dum, vce(cluster fips)
margins, dydx(ma) at(year=(2009(1)2018)) noestimcheck force ///
saving("$mat/event_dum`d'_detrend_100pct", replace)
marginsplot, ///
ylab(-30(10)30) ///
yline(0, lcolor(red) lwidth(thin) lpattern(solid)) ///
xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
ytitle("") xtitle("") ///
title( ///
"Difference in ${m`d'}" "for MA vs. Commercial Enrollees (pp)", just(left) size(*.85) place(11) span color(black)) ///
legend(off)
graph export "$fig/event_dum`d'_detrend_100pct.png", replace height(1000)

log close
