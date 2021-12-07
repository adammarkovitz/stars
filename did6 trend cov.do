********************************************************************************
** 			File 6: trends in covariates for MA and commercial enrollees
********************************************************************************

clear all
capture log close

log using "$log/did6 trend cov 100pct", replace

use "$data/did_100pct", clear
gen byte post=(year>=2012)
count
keep $x ma year dum fips post
replace dum=1 if (dum>=1 & dum<=4)

mat m = J(8,7,0)
loc n=1
foreach y in age female black ccw educ pov unemp income {

	reg `y' i.ma##i.year i.dum if year<=2011, vce(cluster fips)
	margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]

	reg `y' i.ma##i.post i.dum, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], (100*a[8,1]/m[`n',1])
	loc n=`n'+1

}

mat li m
clear
svmat double m
save "$mat/did_cov_100pct", replace

use "$data/did_100pct", clear
count
keep y year $x dum ma fips year bal
replace dum=1 if (dum>=1 & dum<=4)

loc x11 "Beneficiary Age"
loc x12 "(Years)"
loc x21 "Beneficiary Probability of Female Sex"
loc x22 "(Percentage Point)"
loc x31 "ZCTA % Black"
loc x32 "(Percentage Point)"
loc x41 "ZCTA % High School Education"
loc x42 "(Percentage Point)"
loc x51 "ZCTA % Living Below Poverty Level"
loc x52 "(Percentage Point)"
loc x61 "ZCTA % Unemployment"
loc x62 "(Percentage Point)"
loc x71 "Beneficiary Number of Chronic Conditions"
loc x72
loc x81 "ZCTA Median Household Income"
loc x82 "($)"
loc r1 "55(5)75"
loc r2 "45(5)65"
loc r3 "5(5)25"
loc r4 "75(5)95"
loc r5 "0(5)20"
loc r6 "0(5)20"
loc r7 "3(0.5)6"
loc r8 "50000(5000)80000"

loc n=1

foreach y in age female black educ pov unemp ccw income {

	preserve
	reg `y' i.ma##i.year i.dum, vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
	saving("$mat/cov_`y'_trend_b0_100pct", replace)
	marginsplot, ///
	ylab(0(20)100) ///
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	title("`x`n'1' `x`n'2' (%)", just(left) size(medsmall) place(11) span color(black)) ///
	legend(off)
	graph export "$fig/cov_`y'_trend_margins_b0_100pct.png", replace height(1000)

	use "$mat/cov_`y'_trend_b0_100pct", clear
	rename _at2 year
	foreach t in 0 1 {
		gen coef`t' =  _margin if _at1==`t'
		gen lb`t' =  _ci_lb if _at1==`t'
		gen ub`t' =  _ci_ub if _at1==`t'
	}
	twoway ///
	(scatter coef0 coef1 year, mcolor(dknavy dkorange) msize(*0.6 ..) msym(O triangle)) ///
	(line coef0 coef1 year, lcolor(dknavy dkorange) lw(*.8 ..)) ///
	(rarea ub0 lb0 year, color(dknavy%12)) ///
	(rarea ub1 lb1 year, color(dkorange%12) ///
	xtitle("") ytitle("") ///
	ylab(`r`n'') ///
	xlab(2009(1)2018, labsize(*.8)) /// /*xsca(range(2008 2019)) ///*/
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	title("`x`n'1' `x`n'2'", just(left) size(medsmall) place(11) span color(black)) ///
	legend(order(2 "Medicare Advantage" 1 "Commercial Insurance") position(10) ring(0) ///
		col(1) region(lstyle(none)) size(*.8) symx(*0.7)))
	graph export "$fig/cov_`y'_trend_b0_100pct.png", replace height(1000)
	graph save "$mat/cov_`y'_trend_b0_100pct", replace
	restore
	
	preserve
	keep if bal==1
	count
	reg `y' i.ma##i.year i.dum, vce(cluster fips)
	margins, at(year=(2009(1)2018) ma=(0 1)) noestimcheck force ///
	saving("$mat/cov_`y'_trend_b1_100pct", replace)
	marginsplot, ///
	ylab(0(20)100) ///
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	title("`x`n'1' `x`n'2' (%)", just(left) size(medsmall) place(11) span color(black)) ///
	legend(off)
	graph export "$fig/cov_`y'_trend_margins_b1_100pct.png", replace height(1000)
	
	use "$mat/cov_`y'_trend_b1_100pct", clear
	rename _at2 year
	foreach t in 0 1 {
		gen coef`t' =  _margin if _at1==`t'
		gen lb`t' =  _ci_lb if _at1==`t'
		gen ub`t' =  _ci_ub if _at1==`t'
	}
	twoway ///
	(scatter coef0 coef1 year, mcolor(dknavy dkorange) msize(*0.6 ..) msym(O triangle)) ///
	(line coef0 coef1 year, lcolor(dknavy dkorange) lw(*.8 ..)) ///
	(rarea ub0 lb0 year, color(dknavy%12)) ///
	(rarea ub1 lb1 year, color(dkorange%12) ///
	xtitle("") ytitle("") ///
	ylab(`r`n'') ///
	xlab(2009(1)2018, labsize(*.8)) /// /*xsca(range(2008 2019)) ///*/
	xline(2011.5, lcolor(black) lwidth(thin) lpattern(dash)) ///
	title("`x`n'1' `x`n'2'", just(left) size(medsmall) place(11) span color(black)) ///
	legend(order(2 "Medicare Advantage" 1 "Commercial Insurance") position(10) ring(0) ///
		col(1) region(lstyle(none)) size(*.8) symx(*0.7)))
	graph export "$fig/cov_`y'_trend_b1_100pct.png", replace height(1000)
	graph save "$mat/cov_`y'_trend_b1_100pct", replace
	
	loc n=`n'+1	

	restore
}

* DiD estimates of changes in covariates
use "$data/did_100pct", clear
gen byte post=(year>=2012)
count
keep $x ma year dum fips post
replace dum=1 if (dum>=1 & dum<=4)

mat m = J(8,7,0)
loc n=1
foreach y in age female ccw black educ pov unemp income {

	reg `y' i.ma##i.year i.dum if year<=2011, vce(cluster fips)
	margins, at(ma=(1 0) year=2011)
	mat b = r(table)
	mat m[`n',1]= b[1,1], b[1,2]

	reg `y' i.ma##i.post i.dum, vce(cluster fips)
	mat a = r(table)'
	mat m[`n',3] = a[8,1], a[8,5..6], a[8,4], (100*a[8,1]/m[`n',1])
	loc n=`n'+1

}

mat li m
clear
svmat double m
save "$mat/did_cov_100pct", replace

log close
