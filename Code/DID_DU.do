clear all
cap log close

*global disk "E:"
*global disk "C:\Users\mchampion"
global disk "C:\Users\Admin\"
global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"
 
log using "$result\DID_output_DU.txt", text replace

local l_dynamic_1=5 
local l_placebo_1=3

local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.


/****************************************/
** 	DID_L estimation for the Netherland          **
/****************************************/

drop if (categorie==3 & Country==4) /*Remove Flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/


foreach i_country in 1 {

	di "*****************************************"
	if `i_country'==1 di "THE NETHERLAND"  
	di "*****************************************"


local control_1 Country==3|Country==4|Country==5


preserve	
*** On all beverages
keep if (Country==`i_country'|`control_`i_country'')
tab Country

g id_prod=_n
g treated=0
replace treated=cond(Country==1 & year>=2014,1,0) if `i_country'==1 

set seed 1

**No beverage categorie specific linear trend 
did_multiplegt sucres Country year treated, controls(shareofoutofpocket) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)

// t-stat of each first difference placebo test
di "********Fixed effect : Categorie; No control ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 


**Beverage categorie fixed effects 
did_multiplegt sucres Country year treated, controls(shareofoutofpocket) trends_lin(categorie) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)

// t-stat of each first difference placebo test
di "********Fixed effect : Categorie; No control ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

**Country fixed effects 
did_multiplegt sucres Country year treated, controls(shareofoutofpocket) trends_lin(Country) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)

// t-stat of each first difference placebo test
di "********Fixed effect : Country; No control ****"
di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
// P_value of test that all placebos are equal to 0,
di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

restore


*** On each beverage

	local control_1_categ_1 Country==3|Country==4|Country==5
	local control_1_categ_2 Country==3|Country==4|Country==5  
	local control_1_categ_3 Country==3|Country==4|Country==5
	local control_1_categ_4 Country==3|Country==4|Country==5
	
	foreach i_categorie in 1 2 3 4  {
	preserve
	
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )

	tab Country categorie
	
	g id_prod=_n
	g treated=0
	replace treated=cond(Country==1 & year>=2014,1,0) if `i_country'==1 
	
	set seed 1

	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	if `i_categorie'==3 di "Categorie Flavoured waters"
	if `i_categorie'==4 di "Categorie Iced tea"
	di "*****************************************"

** No specific linear trend	
	did_multiplegt sucres Country year treated, controls(shareofoutofpocket) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 

	// t-stat of each first difference placebo test
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 

** Country fixed effect
	did_multiplegt sucres Country year treated, controls(shareofoutofpocket) trends_lin(Country) count_switchers_contr robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 

	di "number of first-time switchers (accounting for the requested controls) " e(N_switchers_effect_0_contr) 
	// t-stat of each first difference placebo test
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 	
	
	restore
		}
	}
	
log close _all

