*******************************************************************************
* See if we can replicate Kaplan Violante Wealthy-Hand-to-Mouth
*******************************************************************************
* Identify hand-to-mouth households
* Hand-to-mouth defined as less than half on one month's income as bank deposits

gen hand_to_mouth = 0
replace hand_to_mouth = 1 if deposits_h<0.5*inc_at_h/12.0
gen wealthy_illiquid = 0
replace wealthy_illiquid = 1 if real_estate_h>0 | bonds_h>0 | stocks_h>0 | mfund_h>0 | stocks_nonreg_h>0
gen poor_hand_to_mouth = hand_to_mouth & (wealthy_illiquid==0)
gen wealthy_hand_to_mouth = hand_to_mouth & (wealthy_illiquid==1)
gen hand_to_mouth_status = 0
replace hand_to_mouth_status = 1 if poor_hand_to_mouth==1
replace hand_to_mouth_status = 2 if wealthy_hand_to_mouth==1

* also distinguish between wealthy HtM homeowners and non-homeowners and 
* unconstrained homeowners and non-homeowners:
g htm_status_detailed = 1
replace htm_status_detailed = 2 if hand_to_mouth_status == 0 & real_estate_h > 0
replace htm_status_detailed = 3 if poor_hand_to_mouth == 1
replace htm_status_detailed = 4 if wealthy_hand_to_mouth == 1
replace htm_status_detailed = 5 if wealthy_hand_to_mouth == 1 & real_estate_h > 0
la var htm_status_detailed "1: nHtM nohome; 2: nHtM home; 3: pHtM; 4: wHtM nohome; 5: wHtM home"

* how many are in each group?
tab hand_to_mouth_status
tab htm_status_detailed

*make sure code runs on dummy data
if $production_run != 1 {
	replace random_noise = uniform()
	replace hand_to_mouth_status = 0 if random_noise<0.3
	replace hand_to_mouth_status = 1 if random_noise>=0.3
	replace hand_to_mouth_status = 2 if random_noise>0.7
}

*Caculate MPC out of transitory shocks for the different groups
*Print results in a matrix that includes numerator, denominator and standard
*deviation of income
matrix MPC_transitory = J(3,5,.)
matrix coln MPC_transitory = Coeff Numerator Denominator yStdDev cStdDev
matrix rown MPC_transitory = NonHtm PoorHtm WealthHtm
*Non hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==0, robust  
matrix MPC_transitory[1,1] = _b[delta_log_y]
correlate delta_log_c F.delta_log_y if hand_to_mouth_status==0, covariance
matrix MPC_transitory[1,2] = r(cov_12)
correlate delta_log_y F.delta_log_y if hand_to_mouth_status==0, covariance
matrix MPC_transitory[1,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==0, covariance
matrix MPC_transitory[1,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==0, covariance
matrix MPC_transitory[1,5] = sqrt(r(Var_1))
*Poor hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==1, robust  
matrix MPC_transitory[2,1] = _b[delta_log_y]
correlate delta_log_c F.delta_log_y if hand_to_mouth_status==1, covariance
matrix MPC_transitory[2,2] = r(cov_12)
correlate delta_log_y F.delta_log_y if hand_to_mouth_status==1, covariance
matrix MPC_transitory[2,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==1, covariance
matrix MPC_transitory[2,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==1, covariance
matrix MPC_transitory[1,5] = sqrt(r(Var_1))
*Wealthy hand to mouth
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==2, robust  
matrix MPC_transitory[3,1] = _b[delta_log_y]
correlate delta_log_c F.delta_log_y if hand_to_mouth_status==2, covariance
matrix MPC_transitory[3,2] = r(cov_12)
correlate delta_log_y F.delta_log_y if hand_to_mouth_status==2, covariance
matrix MPC_transitory[3,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==2, covariance
matrix MPC_transitory[3,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==2, covariance
matrix MPC_transitory[1,5] = sqrt(r(Var_1))

matrix list MPC_transitory


*Caculate MPC out of permanent shocks for the different groups
matrix MPC_permanent = J(3,5,.)
matrix coln MPC_permanent = Coeff Numerator Denominator yStdDev cStdDev
matrix rown MPC_permanent = NonHtm PoorHtm WealthHtm
*Non hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==0, robust 
matrix MPC_permanent[1,1] = _b[delta_log_y]
correlate delta_log_c instrument if hand_to_mouth_status==0, covariance
matrix MPC_permanent[1,2] = r(cov_12)
correlate delta_log_y instrument if hand_to_mouth_status==0, covariance
matrix MPC_permanent[1,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==0, covariance 
matrix MPC_permanent[1,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==0, covariance 
matrix MPC_permanent[1,5] = sqrt(r(Var_1))
*Poor hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==1, robust 
matrix MPC_permanent[2,1] = _b[delta_log_y]
correlate delta_log_c instrument if hand_to_mouth_status==1, covariance
matrix MPC_permanent[2,2] = r(cov_12)
correlate delta_log_y instrument if hand_to_mouth_status==1, covariance
matrix MPC_permanent[2,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==1, covariance 
matrix MPC_permanent[2,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==1, covariance 
matrix MPC_permanent[2,5] = sqrt(r(Var_1))
*Wealthy hand to mouth
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==2, robust  
matrix MPC_permanent[3,1] = _b[delta_log_y]
correlate delta_log_c instrument if hand_to_mouth_status==2, covariance
matrix MPC_permanent[3,2] = r(cov_12)
correlate delta_log_y instrument if hand_to_mouth_status==2, covariance
matrix MPC_permanent[3,3] = r(cov_12)
correlate delta_log_y delta_log_y if hand_to_mouth_status==2, covariance
matrix MPC_permanent[3,4] = sqrt(r(Var_1))
correlate delta_log_c delta_log_c if hand_to_mouth_status==2, covariance
matrix MPC_permanent[3,5] = sqrt(r(Var_1))

matrix list MPC_permanent

* Also distinguish between homeowners and non-homeowners for the wealthy HtM and
* the unconstrained
*Caculate MPC out of transitory shocks for the different groups
*Non hand to mouth homeowners
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==0 & real_estate_h > 0, robust  
*Non hand to mouth non-homeowners
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==0 & real_estate_h == 0, robust   
*Wealthy hand to mouth homeowners
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==2 & real_estate_h > 0, robust  
*Wealthy hand to mouth non-homeowners
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==2 & real_estate_h == 0, robust 

*Caculate MPC out of permanent shocks for the different groups
*Non hand to mouth homeowners
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==0 & real_estate_h > 0, robust  
*Non hand to mouth non-homeowners
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==0 & real_estate_h == 0, robust  
*Wealthy hand to mouth homeowners
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==2 & real_estate_h > 0, robust  
*Wealthy hand to mouth non-homeowners
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==2 & real_estate_h == 0, robust  

********************************************************************************
/*
		*Ignore HtM status: only look at homeowners vs. non-homeowner
		*Transitory shock
		*non-homeowner
		ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if real_estate == 0, robust 
		*homeowner 
		ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if real_estate > 0, robust  
		*Permanent shock
		*non-homeowner
		ivreg2 delta_log_c  (delta_log_y = instrument) if real_estate == 0, robust  
		*homeowner 
		ivreg2 delta_log_c  (delta_log_y = instrument) if real_estate > 0, robust  
*/
********************************************************************************
* Are the poor HtM households saving up to buy a house? Almost everyone in 
* Norway does at some point in their life. Let's see if they react differently
* to positive and negative shocks

g positive_shock = delta_log_y > 0
g negative_shock = delta_log_y < 0

* positive transitory shocks
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==1 & positive_shock == 1, robust 
*negative transitory shocks
ivreg2 delta_log_c  (delta_log_y = F.delta_log_y) if hand_to_mouth_status==1 & negative_shock == 1, robust 
* positive permanent shocks 
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==1 & positive_shock == 1, robust  
* negative permanent shocks
ivreg2 delta_log_c  (delta_log_y = instrument) if hand_to_mouth_status==1 & negative_shock == 1, robust  





