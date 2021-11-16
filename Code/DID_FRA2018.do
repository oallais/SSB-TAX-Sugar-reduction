clear all
cap log close

*global disk "E:"
*global disk "C:\Users\Olivier Allais"
*global disk "C:\Users\mchampion"
global disk "C:\Users\Admin\"

global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"

local sweetener_out=0
if `sweetener_out'==1 {
	log using "$result\DID_output_FRANCE2018_Sanssweetener.txt", text  replace
	}
else {
	log using "$result\DID_output_FRANCE2018.txt" , text replace
}	


local l_dynamic_2=2 
local l_placebo_2=2 /*Drop longdiff_placebo for France*/
local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.

/****************************************/
** 	DID_L estimation for France  	   **
/****************************************/

keep if year>=2013 /*FRANCE 2018 */

drop if (categorie==3 & Country==4) /*Remove Flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/
drop if sweetener==1 & `sweetener_out'==1

foreach i_country in 2 {

	di "*****************************************"
	if `i_country'==2 di "FRANCE"  	
	di "*****************************************"

if `sweetener_out'==1 {
	local control_2 Country==3|Country==4|Country==5
	}
else {
	local control_2 Country==3|Country==4|Country==5
}	

************
*** On all beverages
************

preserve	
keep if (Country==`i_country'|`control_`i_country'')
tab Country

g treated=0
replace treated=cond(Country==2 & year>=2018,1,0) if `i_country'==2 


set seed 1
**No beverage categorie an Country specific linear trend
did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)

// t-stat of each first difference placebo test
di "******** No fixed effect **************"
di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

**Beverage categorie fixed effects 
did_multiplegt sucres Country year treated,  trends_lin(categorie) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Category ****"
di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

**Country fixed effects 
did_multiplegt sucres Country year treated, trends_lin(Country) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Country; No control ****"
di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

restore

************
*** On each beverage
************
	if `sweetener_out'==1 {
		local control_2_categ_1 Country==3|Country==4|Country==5
		local control_2_categ_2 Country==3|Country==4|Country==5
		local control_2_categ_3 Country==3|Country==4|Country==5
		local control_2_categ_4 Country==3|Country==4|Country==5
		}
	else {
		local control_2_categ_1 Country==3|Country==4|Country==5
		local control_2_categ_2 Country==3|Country==4|Country==5
		local control_2_categ_3 Country==3|Country==4|Country==5
		local control_2_categ_4 Country==3|Country==4|Country==5
	}	
    	
	
	foreach i_categorie in 1 2 4 {
	preserve
	
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )

	tab Country categorie
	
	g treated=0
	replace treated=cond(Country==2 & year>=2018,1,0) if `i_country'==2 
	
	set seed 1

	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	if `i_categorie'==3 di "Categorie Flavoured waters"
	if `i_categorie'==4 di "Categorie Iced tea"
	di "*****************************************"
	
	if `i_categorie'!=4 {
		** No Country specific linear trend
		did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 
	
	/*	** Country fixed effects
		did_multiplegt sucres Country year treated, trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo)*/
		}	
	else {
		** No Country specific linear trend
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 
	
	/*	** Country fixed effects
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(se_placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(se_placebo_2), e(placebo_2)/e(se_placebo_2)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) */
		}
	
	restore
		}
	}
	
log close _all


