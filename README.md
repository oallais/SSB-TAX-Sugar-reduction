# SSB-TAX-Sugar-reduction
This is the replication directory for "Comparison of the impact of UK and French taxes on the sugar content of new sugar sweetened beverages launched in the UK and French markets: controlled-interrupted time series design"


Comments:
* Replication requires access to the MINTEL GNPD data. More information is available here: https://www.mintel.com


Replication instructions:
1. Create two subfolders "Results" and "Data"
2. Add data to the Data subfolders "Data". In our code the file is called BRSA2019.dta. It must contains the varaibles: Country ProduitNuméro year sucres Country PL categorie effectif shareofoutofpocket presence_edulcorants
	*   The variable "sucre" is SSB sugar content;
	**  The variable "effectif" is the number of product launched in the market for the given year and given country;
 	*** The variabl "presence_edulcorants" takes the value one if the SSB contains artificial sweeteners.
3. Add appropriate directory paths to DID-XX.do as instructed on line 3. Change "global disk "C:\Users\Admin\" "
4. Set local variables
	*    l_dynamic_6 stands for the number of dynamics effects, including instanteneous effect, to estimate;
	**   l_placebo_6 stands for the number of placebo estimators;
	***  nreps stands for the number of block bootstrap replication used to calculate estimators’ standard errors;
	***  sweetener_out takes the value one if you want to limit the analysis to SSB without artificial sweetener.
4. Do 
	* DID_Uk.do to simulate SDIL effects; 
	** DID_FRA2012 to simulate the 2012 French tax effects;
	** DID_FRA2012 to simulate the 2018 French tax effects;
	** DID_DU to simulate Dutch PPP policy on SSBs.
