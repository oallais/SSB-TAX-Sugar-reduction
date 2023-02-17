clear all
cap log close

*global disk "E:"
*global disk "C:\Users\Admin\"
global disk "C:\Users\Olivier ALLAIS"
global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"
 
log using "$result\DID_output_DU.txt", text replace

local l_dynamic_1=5 
local l_placebo_1=3

local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants typedelancement sugar_price_kilo
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.

gen Nat_Brand=cond(PL==1,1,0)
bys country year categorie: egen share_Nat_Brand=mean(Nat_Brand) 		/* Share of national brands */


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

	**No beverage categorie specific linear trend + No controls
	di "*********************"
	di "********No beverage categorie specific linear trend + No controls ****"
	di "*********************"
	di ""
	did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
	// t-stat of each first difference placebo test
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 



	**Beverage categorie specific linear trend +  shareofoutofpocket + sugar_price_kilo + share_Nat_Brand
	di "*********************"
	di "********Beverage categorie specific linear trend + shareofoutofpocket + sugar_price_kilo + share_Nat_Brand ****"
	di "*********************"
	di ""
	did_multiplegt sucres Country year treated, trends_lin(categorie) controls(shareofoutofpocket sugar_price_kilo share_Nat_Brand)  robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
	// t-stat of each first difference placebo test		
	di "The t-stat for the 1st placebo is " e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3)/e(se_placebo_3)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 
	
restore



*** On each beverage

	local control_1_categ_1 Country==3|Country==4|Country==5
	local control_1_categ_2 Country==3|Country==4|Country==5  
	
	foreach i_categorie in 2  {
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
	di "*****************************************"

		dis "***********************************"
		dis "** No Fixed Effect + Controls: outofpocket **"
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3), e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)-1.96*e(se_placebo_4), e(placebo_4)+1.96*e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 	
		di ""		


		dis "***********************************"
		dis "** No Fixed Effect + Controls: outofpocket + sugar_price_kilo + share_Nat_Brand **"
		did_multiplegt sucres Country year treated, controls(shareofoutofpocket sugar_price_kilo share_Nat_Brand) robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
		// t-stat of each first difference placebo test
		di "The t-stat for the 1st placebo is " e(placebo_1), e(placebo_1)/e(se_placebo_1)
		di "The t-stat for the 2nd placebo is " e(placebo_2), e(placebo_2)/e(se_placebo_2)
		di "The t-stat for the 3rd placebo is " e(placebo_3), e(placebo_3)/e(se_placebo_3)
		di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)-1.96*e(se_placebo_4), e(placebo_4)+1.96*e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
		// P_value of test that all placebos are equal to 0,
		di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 	
		di ""				
		
	restore
		}
	}
	
log close _all

