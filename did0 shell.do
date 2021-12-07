cls
clear all
set maxvar 120000, perm
set max_memory ., perm
set more off, perm
capture log close

* Great Lakes:
global stars "/nfs/turbo/amryan-turbo/stars"
global data "$stars/data"
global code "$stars/code"
global rate "$stars/data/cms/ratebook"
global out "$stars/out"
global log "$out/log"
global mat "$out/mat"
global fig "$out/figure"

set scheme s2color
grstyle init
grstyle graphsize x 5.5
grstyle graphsize y 4.5
grstyle color background white
grstyle anglestyle vertical_tick horizontal
grstyle yesno draw_major_hgrid yes
grstyle color major_grid gs8
grstyle linewidth major_grid thin
grstyle linepattern major_grid dot
grstyle linewidth plineplot medthick
grstyle yesno grid_draw_min yes
grstyle yesno grid_draw_max yes

global x age female ccw black educ pov unemp income
global z c.age i.female c.ccw c.black c.educ c.pov c.unemp c.income
global dum d2 d3 d4 d5 d6 d7 d8 d9
global time 1.time 2.time 3.time 4.time 6.time 7.time 8.time

global p0 "Overall Quality" 
global p1 "Diabetic A1c Monitoring" 
global p2 "Diabetic LDL Screening" 
global p3 "Diabetic Retinopathy Screening" 
global p4 "Diabetic Nephropathy Management" 
global p5 "Breast Cancer Screening" 
global p6 "Rheumatoid Arthritis Management" 
global p7 "Adherence to Statins" 
global p8 "Adherence to RAS Inhibitors" 
global p9 "Adherence to Diabetes Medication"

do "$code/did1 clean"
do "$code/did2 detrend"
do "$code/did3 event"
do "$code/did4 did"
do "$code/did5 trend"
do "$code/did6 trend cov"
do "$code/did7 pr measure"
do "$code/did8 misc"
do "$code/did9 table1"
do "$code/did10 consort"
