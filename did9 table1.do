********************************************************************************
** 			File 9: Descriptive Tables
********************************************************************************

clear all
capture log close

log using "$log/did9 table1 100pct", replace

******************************************************************************		
** eTable: MA vs Commercial Enrollees, pre vs post-period
******************************************************************************		

* standardized differences (2009-2011 vs 2012-2018)
loc p0 pre
loc p1 post
forvalues i=0/1 {
	use  "$data/did_100pct", clear
	gen post = (year>=2012)
	keep if post==`i'
	keep y $x year ma patid
	
	* tab
	tab ma, matcell(c)
	mat c = c[2,1],c[1,1],0
	
	* unique
	unique patid if ma == 1
	sca b = r(unique)
	unique patid if ma == 0
	mat b = b, r(unique), 0

	* std diff
	covbal ma $x 
	mat a = r(table)
	mat a = c \ b \ a[1..8,1], a[1..8,4], a[1..8,7]
	clear
	svmat double a
	rename a1 ma1
	rename a2 ma0
	rename a3 std

	save "$mat/table1_`p`i''_100pct", replace
}

********************************************************************************
** 	etable_levels1_100pct
************************************

use "$data/did_100pct", replace
count
keep y year ma $x dum
keep if year<=2011
reg y i.ma##i.dum $x i.year

margins
mat a = r(table)
mat b = a[1,1]
margins, at(ma=(1 0))
mat a = r(table)
mat a0 = b, a[1,1], a[1,2]

margins, at(dum=(1(1)9))
mat a = r(table)'
mat b = a[1..9,1]
margins, at(ma=(1 0) dum=(1(1)9))
mat a = r(table)'
mat a1 = a[1..9,1]
mat a2 = a[10..18,1]
mat a = (a0) \ (b, a1, a2)
mat li a

clear
svmat double a

save "$mat/table_quality_levels_100pct", replace

*****************************************************
** 	Comparisons of levels to published MA data
***********************

use "$data/did_100pct", clear
count
keep if ma==1 & age>=65
count
keep if lis==0
count

keep y dum year

* year by year mean
mat m = J(11,7,0)
loc m = 1
forvalues j = 2010/2016 {
	preserve
	keep if year==`j'
	
	loc n = 1
	sum y
	mat m[`n',`m'] = r(mean)
	putexcel set "$mat/table_quality_year_levels_100pct", replace
	putexcel a1 = mat(m)
	loc n = `n' + 2
	forvalues i=1/9 {
		sum y if dum == `i'
		mat m[`n',`m'] = r(mean)
		putexcel set "$mat/table_quality_year_levels_100pct", replace
		putexcel a1 = mat(m)
		loc n = `n' + 1
	}
	mat li m
	loc m = `m' + 1
	restore
}

log close
