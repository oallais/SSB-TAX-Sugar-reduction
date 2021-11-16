clear all
cap log close

*global disk "E:"
*global disk "C:\Users\mchampion"
global disk "C:\Users\Admin\"
global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"

local sweetener_out=0
if `sweetener_out'==1 {
	log using "$result\DID_output_UK_Sanssweetener.txt", text replace
	}
else {
	log using "$result\DID_output_UK.txt", text replace
}

local l_dynamic_6=3
local l_placebo_6=3
local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.


/****************************************/
** 	DID_L estimation for UK           **
/****************************************/

drop if (categorie==3 & Country==4) /*Remove Flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/
drop if sweetener==1 & `sweetener_out'==1


foreach i_country in 6 {

	di "*****************************************"
	if `i_country'==6 di "THE UNITED KINGDOM"  	
	di "*****************************************"

if `sweetener_out'==1 {
	local control_6 Country==3|Country==4|Country==5
	}
else {
	local control_6 Country==3|Country==4|Country==5
}	


preserve	
*** On all beverages
keep if (Country==`i_country'|`control_`i_country'')
tab Country

g treated=0
replace treated=cond(Country==6 & year>=2016,1,0) if `i_country'==6 

set seed 1
**No beverage categorie specific linear trend
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Categorie; No control ****"
di "# obse and The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is "  e(placebo_3)/e(se_placebo_3)
di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

**Beverage categorie fixed effects 
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) trends_lin(categorie) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Categorie; No control ****"
di "# obse and The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is "  e(placebo_3)/e(se_placebo_3)
di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

**Beverage Country specific linear trend
did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) trends_lin(Country) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
// t-stat of each first difference placebo test
di "********Fixed effect : Categorie; No control ****"
di "# obse and The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is "  e(placebo_3)/e(se_placebo_3)
di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

restore


************
*** On each beverage
************

	if `sweetener_out'==1 {
	local control_6_categ_1 Country==3|Country==4|Country==5
	local control_6_categ_2 Country==3|Country==4|Country==5
	local control_6_categ_3 Country==3|Country==4|Country==5
	local control_6_categ_4 Country==3|Country==4|Country==5
	}
	else {
	local control_6_categ_1 Country==3|Country==4|Country==5
	local control_6_categ_2 Country==3|Country==4|Country==5
	local control_6_categ_3 Country==3|Country==4|Country==5
	local control_6_categ_4 Country==3|Country==4|Country==5	
	}	
		
	foreach i_categorie in 1 2 3 {

	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	if `i_categorie'==3 di "Categorie Flavoured waters"
	if `i_categorie'==4 di "Categorie Iced tea"
	di "*****************************************"	
	
	preserve
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )
	tab Country categorie
		
	g treated=0
	replace treated=cond(Country==6 & year>=2016,1,0) if `i_country'==6 	
	
	set seed 1
	if `i_categorie'!=3 {
		** No Country specific linear trend
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 
	
	** Country fixed effects
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sweetener) trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo  covariances jointtestplacebo breps(`nreps') cluster(Country) 
		di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo)
		}	
	else {
		** No Country specific linear trend
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

		** Country fixed effects
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket) trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo)
		}
		
	restore
		}
	}
	
log close _all



