/*
Anna Bardits
CEU, 2019, The effect of daily gym classes on student outcomes
getting a clean dataset for students
*/

*append data together

cd "C:\Users\bardi\OneDrive\Asztali gép\ongoing\ceu\research\gym classes"


*I don't have the 2016 adta
*use "data\raw\2016\2016tanuloi6.dta", clear
*replace ev=2016 if missing(ev)

use "data\raw\2015\2015tanuloi6.dta", clear
replace ev=2015 if missing(ev)
append using "data\raw\2014\2014tanuloi6.dta"
replace ev=2014 if missing(ev)
append using "data\raw\2013\2013tanuloi6.dta"
replace ev=2013 if missing(ev)
append using "data\raw\2012\2012tanuloi6.dta"
replace ev=2012 if missing(ev)
append using "data\raw\2011\2011tanuloi6.dta"
replace ev=2011 if missing(ev)
append using "data\raw\2010\2010tanuloi6.dta"
replace ev=2010 if missing(ev)
append using "data\raw\2009\2009tanuloi6.dta"
replace ev=2009 if missing(ev)
append using "data\raw\2008\2008tanuloi6.dta"
replace ev=2008 if missing(ev)

gen class=6

*append using "data\raw\2016\2016tanuloi8.dta"
*replace ev=2016 if missing(ev)
append using "data\raw\2015\2015tanuloi8.dta"
replace ev=2015 if missing(ev)
append using "data\raw\2014\2014tanuloi8.dta"
replace ev=2014 if missing(ev)
append using "data\raw\2013\2013tanuloi8.dta"
replace ev=2013 if missing(ev)
append using "data\raw\2012\2012tanuloi8.dta"
replace ev=2012 if missing(ev)
append using "data\raw\2011\2011tanuloi8.dta"
replace ev=2011 if missing(ev)
append using "data\raw\2010\2010tanuloi8.dta"
replace ev=2010 if missing(ev)
append using "data\raw\2009\2009tanuloi8.dta"
replace ev=2009 if missing(ev)
append using "data\raw\2008\2008tanuloi8.dta"
replace ev=2008 if missing(ev)

replace class=8 if missing(class)

save "data\derived\gym_classes_school_outcomes.dta", replace

/*


sort azon ev






*keep important variables
keep azon ft_csop ft_tip treatment th_kod m_zpsc o_zpsc osztid kist174_tan sex sni /*
*/ kist174_isk teltip7_isk teltip7_tan mkod_isk rkod_isk csh_index m_szint o_szint /*
*/ t20 t18a t18b t18c class ev


sort azon
gen sorszam=_n
bysort azon: egen studid=max(sorszam)

keep if !missing(treatment)

*az erdekel h 6. es 8. kozott mennyit fejlodott, nem szamit ha bukik.
*megtartom az elso 6.os es az elso 8.os eredmenyet mindenkinek

sort studid class ev
by studid class: gen classobs=_n
order azon studid class ev classobs
keep if classobs==1

by studid: gen obsyear=_N
tab obsyear
keep if obsyear==2
drop obsyear

*csak azokat tartom meg, akiknek van 6.-bol es 8.-bol is megfigyelesuk
by studid: gen classdiff=class[2]-class[1]
tab classdiff
drop classdiff

*es akiknek 2 vagy 3 ev eltelt a ket megfigyelesuk kozott
sort studid class
by studid: gen evdiff=ev[2]-ev[1]
tab evdiff
keep if evdiff==2 | evdiff==3

cap drop obsyear
bysort studid: gen obsyear=_n
gen sni_01=0
replace sni_01=1 if !missing(sni)


*testpoints need to be standardized
cap drop mat_std
gen mat_std=.
*for 6th graders
forvalues i=2008(1)2014{
sum m_zpsc if ev==`i' & class==6
replace mat_std=(m_zpsc-r(mean))/r(sd) if ev==`i' & class==6
}


*for 8th graders
forvalues i=2008(1)2016{
sum m_zpsc if ev==`i' & class==8
replace mat_std=(m_zpsc-r(mean))/r(sd) if ev==`i' & class==8
}

*reading
cap drop olv_std
gen olv_std=.
*for 6th graders
forvalues i=2008(1)2014{
sum o_zpsc if ev==`i' & class==6
replace olv_std=(o_zpsc-r(mean))/r(sd) if ev==`i' & class==6
}


*for 8th graders
forvalues i=2008(1)2016{
sum o_zpsc if ev==`i' & class==8
replace olv_std=(o_zpsc-r(mean))/r(sd) if ev==`i' & class==8
}

*replace m_zpsc=m_zpsc*3 if ev<2010
*replace o_zpsc=o_zpsc*3 if ev<2010

by studid: gen matdiff=mat_std[2]-mat_std[1]
by studid: gen olvdiff=olv_std[2]-olv_std[1]


by studid: gen mat_szintdiff=m_szint[2]-m_szint[1]
by studid: gen olv_szintdiff=o_szint[2]-o_szint[1]

order th_kod studid ev matdiff olvdiff o_zpsc olv_std m_zpsc mat_std 


save DATA_0303, replace

*hist matdiff if obsyear==2

cap drop locgovt_school
gen locgovt_school=.
replace locgovt_school=0 if ft_csop==4
*gen locgovt_school=0
replace locgovt_school=1 if /*
*/(ft_tip==10 | ft_tip==11 | ft_tip==12 | ft_tip==13 | ft_tip==14 | ft_tip==15 |/*
*/ ft_tip==120 | ft_tip==122 | ft_tip==202 | ft_tip==203 | ft_tip==24 | ft_tip==24) 


save data_student, replace

/*analyze*/
use data_student, clear

cap drop obsyear
bysort studid: gen obsyear=_n
keep if obsyear==2

*hogy alakult a novekedes
statsby means=r(mean) ub=r(ub) lb=r(lb), saving(vmi, replace) by(locgovt_school ev): ci olvdiff

use vmi, clear

keep if ev>2009
twoway (connected means ev if locgovt_school==1, color(blue)) ///
(line ub ev if locgovt_school==1, color(blue) lpattern(dash)) ///
(line lb ev if locgovt_school==1, color(blue) lpattern(dash)) ///
(connected means ev if locgovt_school==0, color(red)) ///
(line ub ev if locgovt_school==0, color(red) lpattern(dash)) ///
(line lb ev if locgovt_school==0, color(red) lpattern(dash))






*did
use data_student, clear

tab m_szint ev




cap drop obsyear
bysort studid: gen obsyear=_n
keep if obsyear==2

gen after=0
replace after=1 if ev>2013

keep if ev>2009

reg matdiff after##locgovt_school, robust
reg matdiff ib2013.ev##locgovt_school, robust

reg matdiff ib2013.ev##locgovt_school t2 t18* t19b i.mkod_tan, robust
 

 

/*

keep studid ev m_zpsc o_zpsc ft_csop th_kod
reshape wide m_zpsc o_zpsc ft_csop th_kod, i(studid) j(ev)

gen diff=.

order studid diff ev* m_zpsc* o_zpsc* ft_csop* th_kod*

replace diff=m_zpsc2016-mzpsc




xtset studid ev
xtreg m_zpsc i.ev klik
