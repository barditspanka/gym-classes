cd "C:\Users\bardi\OneDrive\Asztali gép\ongoing\ceu\research\gym classes"
use "data\derived\gym_classes_school_outcomes.dta", clear

keep if class==6
tab ev
*now concentrate on primary schools
keep if tipus==1

*covariates
foreach var of varlist sex t13 sni letszam6_th{
	oneway `var' ev, tab
}


*outcomes
foreach var of varlist t16 hianyzas_th_6 t54c t55d{
	oneway `var' ev, tab
}


forvalues year = 2008(1)2015{
	oneway t55d teltip7_tan if ev==`year', tab
}	
oneway elozomat ev if ev>2013, tab
oneway t14 ev if ev>2013, tab
oneway t16 ev if ev>2013, tab
oneway hianyzas_th_8 ev if ev>2013, tab
