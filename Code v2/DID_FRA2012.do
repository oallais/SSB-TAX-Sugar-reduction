clear all
cap log close

*global disk "E:"
*global disk "C:\Users\Olivier Allais"
*global disk "C:\Users\mchampion"
*global disk "C:\Users\Admin\"
global disk "C:\Users\Admin\Inrae EcoPub Dropbox\Olivier Allais"

global data "$disk\BMJ\Data"
global code "$disk\BMJ\Code"
global result "$disk\BMJ\Results"


log using "$result\DID_output_FRANCE2012_GE_IT_SP_UK.txt" , text replace

di "*****************************************"
dis "All database"
di "*****************************************"

local l_dynamic_2=3 
local l_placebo_2=1 /*Drop longdiff_placebo for France*/

local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants typedelancement sugar_price_kilo
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.

gen Nat_Brand=cond(PL==1,1,0)
bys country year categorie: egen share_Nat_Brand=mean(Nat_Brand) 		/* Share of national brands */


/****************************************/
** 	DID_L estimation for France 2012   **
/****************************************/

drop if (categorie==3 & Country==4) /*Remove flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/

foreach i_country in 2 {

	di "*****************************************"
	if `i_country'==2 di "FRANCE"  
	di "*****************************************"

	local control_2 Country==3|Country==4|Country==5|Country==6
	*	local control_2 Country==4|Country==6


************
*** On all beverages
************

preserve	

keep if (Country==`i_country'|`control_`i_country'')
tab Country

g treated=0
replace treated=cond(Country==2 & year>=2012,1,0) if `i_country'==2 

set seed 1
	
	**Beverage categorie specific linear trend +  shareofoutofpocket + sugar_price_kilo + share_Nat_Brand
	di "*********************"
	di "********Beverage categorie specific linear trend + shareofoutofpocket + sugar_price_kilo + share_Nat_Brand****"
	di "*********************"
	di ""
	did_multiplegt sucres Country year treated, trends_lin(categorie) controls(shareofoutofpocket sugar_price_kilo share_Nat_Brand) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country)
	// t-stat of each first difference placebo test
	di "The t-stat for the 1st placebo is "  e(placebo_1)/e(se_placebo_1)


restore


*** On each beverages


	
	local control_2_categ_1 Country==3|Country==4|Country==5|Country==6
	local control_2_categ_2 Country==3|Country==4|Country==5|Country==6
	
		
	foreach i_categorie in 1 2 {
	preserve
	
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )
	tab year if Country==2 & categorie==`i_categorie' & year<=2013

	g treated=0
	replace treated=cond(Country==2 & year>=2012,1,0) if `i_country'==2 
	
	set seed 1

	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	di "*****************************************"

	tab Country categorie
				
		dis "***********************************"
		dis "** No Fixed Effect + Controls: outofpocket + sugar_price_kilo + share_Nat_Brand **"
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sugar_price_kilo share_Nat_Brand) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
		di ""								

	restore
		}
	}
	
log close _all


