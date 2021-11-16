clear all
cap log close

* Change directory and create subfolder Data and Results
global disk "C:\Users\Admin\"
global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"

local sweetener_out=0
if `sweetener_out'==1 {
	log using "$result\DID_output_FRANCE2012_Sanssweetener.txt", text  replace
	}
else {
	log using "$result\DID_output_FRANCE2012.txt" , text replace
}	


local l_dynamic_2=3 
local l_placebo_2=1 /*Drop longdiff_placebo for France*/

local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country year Id_SSB sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.
drop if (categorie==3 & Country==4) /*Remove flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/
drop if sweetener==1 & `sweetener_out'==1

/****************************************/
** 	DID_L estimation for France 2012   **
/****************************************/

foreach i_country in 2 {

	di "*****************************************"
	if `i_country'==2 di "FRANCE"  
	di "*****************************************"

	if `sweetener_out'==1 {
		local control_2 Country==1|Country==3|Country==4|Country==5|Country==6
		}
	else {
		local control_2 Country==4|Country==6
	}	

************
*** On all beverages
************

preserve	

keep if (Country==`i_country'|`control_`i_country'')
tab Country

g treated=0
replace treated=cond(Country==2 & year>=2012,1,0) if `i_country'==2 

set seed 1
** No beverage categorie specific linear trend 
did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "******** No Fixed effect  ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)

* Control
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "******** No Fixed effect + Control ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)


** Beverage categorie fixed effects 
did_multiplegt sucres Country year treated, trends_lin(categorie) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Categorie ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
* Control
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener ) trends_lin(categorie) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Categorie + Control****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)


** Country fixed effects 
did_multiplegt sucres Country year treated, trends_lin(Country) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Country ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
* Control
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener ) trends_lin(Country) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect + Control : Country ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)

restore

*** On each beverages
	if `sweetener_out'==1 {
		local control_2_categ_1 Country==1|Country==3|Country==4
		local control_2_categ_2 Country==3|Country==4
		local control_2_categ_3 Country==1|Country==3|Country==5
		local control_2_categ_4 Country==1|Country==3
		}
	else {
		local control_2_categ_1 Country==3|Country==6
		local control_2_categ_2 Country==4|Country==6
		local control_2_categ_3 Country==4|Country==6
		local control_2_categ_4 Country==1|Country==3|Country==4
	}	  
	
	foreach i_categorie in 1 2 {
	preserve
	
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )
	tab year if Country==2 & categorie==`i_categorie' & year<=2013


	g id_prod=_n
	g treated=0
	replace treated=cond(Country==2 & year>=2012,1,0) if `i_country'==2 
	
	set seed 1

	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	if `i_categorie'==3 di "Categorie Flavoured waters"
	if `i_categorie'==4 di "Categorie Iced tea"
	di "*****************************************"

	tab Country categorie
	
** No country linear trend	
	did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country) 
	
	// t-stat of each first difference placebo test
	di "********Fixed effect : Categorie; No control ****"
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	
** Country fixed effect
	did_multiplegt sucres Country year treated, trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country) 
	
	di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
	// t-stat of each first difference placebo test
	di "********Fixed effect : Categorie; No control ****"
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	
	restore
		}
	}
	
log close _all


