*****************************************************************************
* Overall regressions
*****************************************************************************

* This regression estimates the marginal propensity to consume out of 
* transitory shocks for everyone
ivreg2 delta_log_c (delta_log_y = F.delta_log_y), robust 

* This regression estimates the marginal propensity to consume out of 
* permanent shocks for everyone
ivreg2 delta_log_c (delta_log_y = instrument), robust 

* Test different instruments for the transitory shock to see robustness 
* of results. Also calulate numerator and denominator separately
g F2 = F2.log_y-log_y
g F3 = F3.log_y-log_y
g F4 = F4.log_y-log_y

* main instrument
ivreg2 delta_log_c (delta_log_y = F.delta_log_y), robust 
correlate delta_log_c F.delta_log_y, covariance
correlate delta_log_y F.delta_log_y, covariance

*alternative instrument 1
ivreg2 delta_log_c (delta_log_y = F2), robust 
correlate delta_log_c F2, covariance
correlate delta_log_y F2, covariance

*alternative instrument 2
ivreg2 delta_log_c (delta_log_y = F3), robust 
correlate delta_log_c F3, covariance
correlate delta_log_y F3, covariance

*alternative instrument 3
ivreg2 delta_log_c (delta_log_y = F4), robust 
correlate delta_log_c F4, covariance
correlate delta_log_y F4, covariance
drop F2 F3 F4
