clear all
cap log close

*global disk "E:"
*global disk "C:\Users\mchampion"
global disk "C:\Users\Olivier ALLAIS"
*global disk "C:\Users\Admin\"
global data "$disk\Dropbox\BMJ\Data"
global code "$disk\Dropbox\BMJ\Code"
global result "$disk\Dropbox\BMJ\Results"
global figures "$disk\Dropbox\BMJ\Figures"

local figure=0
log using "$result\DID_output_UK_Placebo_share_ProdPrice.txt", text replace
dis "All database"

local l_dynamic_6=3
local l_placebo_6=3
local nreps= 1000
 
use "$data\BRSA2019.dta", clear 

keep Country ProduitNuméro country codebarre EntrepriseSociété ultimatecompany companycountry marque produit year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants typedelancement sugar_price_kilo
gen sweetener=cond(presence_edulcorants=="oui",1,0)
drop if sucres==.

sort country year categorie
egen Categ_Sweet=group(categorie sweetener)
bys country year categorie: egen share_sweet=mean( sweetener) /* Proportion of beverage with non-caloric sweetener per country, year and category */

bys country year: egen Total_Nber_sweet=total(sweetener)  /*Total nber of beverages with non-caloric sweetener per country and year*/
bys country year: egen Total_Nber=count(ProduitNuméro) /* Total Nber of beverages per country and year*/

bys country year categorie: egen Total_categ_Nber_sweet=total(sweetener)  /*Total nber of beverage with non-caloric sweetener per country year and categorie*/
bys country year categorie: egen Total_categ_Nber=count(ProduitNuméro) /* Total Nber of beverages per country year and categorie */

gen share_sweet_othercateg=(Total_Nber_sweet-Total_categ_Nber_sweet)/(Total_Nber-Total_categ_Nber)

gen Nat_Brand=cond(PL==1,1,0)
bys country year categorie: egen share_Nat_Brand=mean(Nat_Brand) 		/* Share of national brands */

replace typedelancement="Nouveau Produit" if typedelancement=="Nouveau produit"
replace typedelancement="Nouvel Emballage" if typedelancement=="Nouvel emballage"
replace typedelancement="Nouvelle Formulation" if typedelancement=="Nouvelle formulation"
replace typedelancement="Nouvelle Variété/Extension de Gamme" if typedelancement=="Nouvelle variété/Extension de gamme"
encode typedelancement, generate(type_innov)

gen Coca_Cola=cond(ultimatecompany =="The Coca-Cola Company",1,0)
bys country year categorie: egen share_Coca_Brand=mean(Coca_Cola)


	
/****************************************/
** 	DID_L estimation for UK           **
/****************************************/

drop if (categorie==3 & Country==4) /*Remove Flavoured waters for Italy: Only 15 beverages; 1.25% of Italian SSBs*/



foreach i_country in 6 {

	di "*****************************************"
	if `i_country'==6 di "THE UNITED KINGDOM"  	
	di "*****************************************"

	local control_6 Country==3|Country==4|Country==5

	set seed 1

	preserve	
	*** On all beverages
	keep if (Country==`i_country'|`control_`i_country'')
	tab Country

	g treated=0
	replace treated=cond(Country==6 & year>=2016,1,0) if `i_country'==6 


	**No beverage categorie specific linear trend + No controls
	di "*********************"
	di "********No beverage categorie specific linear trend + No controls ****"
	di "*********************"
	di ""
	did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
	// t-stat of each first difference placebo test
	di "The t-stat for the 1st placebo is " e(placebo_1), e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2), e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3), e(placebo_3)/e(se_placebo_3)
	di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)-1.96*e(se_placebo_4), e(placebo_4)+1.96*e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 


	**Beverage categorie specific linear trend +  shareofoutofpocket + sugar_price_kilo + share_Nat_Brand
	di "*********************"
	di "********Beverage categorie specific linear trend + shareofoutofpocket + sugar_price_kilo + share_Nat_Brand ****"
	di "*********************"
	di ""
	did_multiplegt sucres Country year treated, trends_lin(categorie) controls(shareofoutofpocket sugar_price_kilo share_Nat_Brand)  robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country)
	// t-stat of each first difference placebo test

	di "The t-stat for the 1st placebo is " e(placebo_1), e(placebo_1)/e(se_placebo_1)
	di "The t-stat for the 2nd placebo is " e(placebo_2), e(placebo_2)/e(se_placebo_2)
	di "The t-stat for the 3rd placebo is " e(placebo_3), e(placebo_3)/e(se_placebo_3)
	di "The t-stat for the 4th placebo is " e(placebo_4), e(se_placebo_4), e(placebo_4)-1.96*e(se_placebo_4), e(placebo_4)+1.96*e(se_placebo_4), e(placebo_4)/e(se_placebo_4)
	// P_value of test that all placebos are equal to 0,
	di "P_value that all placebos are equal to 0 is " e(p_jointplacebo) 
	
	restore


************
*** On each beverage
************

	local control_6_categ_1 Country==3|Country==4|Country==5
	local control_6_categ_2 Country==3|Country==4|Country==5
	local control_6_categ_3 Country==3|Country==5        		/*We excluded Italian flavoured water #15 bewteen 2010--2019 */
	local control_6_categ_4 Country==3|Country==4|Country==5	
	
	set seed 1		
	
	foreach i_categorie in 1 2 {
	di ""
	di "*****************************************"
	if `i_categorie'==1 di "Categorie Fruit flavoured still drinks"  
	if `i_categorie'==2 di "Categorie Carbonated soft drinks"  
	di "*****************************************"	
	di ""

	preserve
	keep if  categorie==`i_categorie' & (Country==`i_country'|`control_`i_country'_categ_`i_categorie'' )
	tab Country categorie
		
	g treated=0
	replace treated=cond(Country==6 & year>=2016,1,0) if `i_country'==6 	
	

		dis "***********************************"
		dis "** No Fixed Effect + NO Controls**"		
		did_multiplegt sucres Country year treated, robust_dynamic dynamic(`l_dynamic_`i_country'') placebo(`l_placebo_`i_country'') longdiff_placebo covariances jointtestplacebo breps(`nreps') cluster(Country) 
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



