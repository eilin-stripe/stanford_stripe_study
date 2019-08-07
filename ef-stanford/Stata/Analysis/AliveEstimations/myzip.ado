program define myzip
    version 13.0

    args todo b lnf g H

    tempvar l p_pre p
    mleval `l' = `b', eq(1)
    mleval `p_pre' = `b' , eq(2)

    gen `p' = `p_pre'
    * gen `p' = 1 / (1 + exp(-`p_pre'))

    local y "$ML_y1"

    tempvar lnfj q e_l mid
    gen `q' = 1 - `p'
    gen `e_l' = exp(-`l')
    gen `mid' = `p' + (1 - `p') * `e_l'

    qui gen `lnfj' = log(`q') + `y' * log(`l') - `l' ///
        - lnfactorial(`y') if `y' >= 1

    qui replace `lnfj' = log(`mid') if `y' == 0

    mlsum `lnf' = `lnfj'
    if (`todo'==0 | `lnf'>=.) exit

*******************************************************************************
** Gradient Calculations
*******************************************************************************
    tempname d1_mid d2_mid d1 d2

    qui gen `d1_mid' = (`y'/`l') - 1  if `y' >= 1
    qui replace `d1_mid' = - (`q' * `e_l') / (`mid') if `y' == 0
    mlvecsum `lnf' `d1' = `d1_mid' , eq(1)

    qui gen `d2_mid' = - 1 / `q'  if `y' >= 1
    qui replace `d2_mid' = (1 -  `e_l') / (`mid') if `y' == 0
    mlvecsum `lnf' `d2' = `d2_mid' , eq(2)

    matrix `g' = (`d1', `d2')

    if (`todo'==1 | `lnf'>=.) exit

*******************************************************************************
** Hessian Calculations
*******************************************************************************
    tempname d11_mid d12_mid d22_mid d11 d12 d22

    qui gen `d11_mid' = - (`y'/(`l'^2))  if `y' >= 1
    qui replace `d11_mid' = (`q' * `e_l')^2 / (`mid')  + (`q' * `e_l') / (`mid') if `y' == 0
    mlmatsum `lnf' `d11' = `d11_mid' , eq(1)

    qui gen `d12_mid' = 0  if `y' >= 1
    qui replace `d12_mid' = ((1 -  `e_l') * `q' * `e_l') / (`mid'^2) + `e_l' / `mid' if `y' == 0
    mlmatsum `lnf' `d12' = `d12_mid' , eq(1,2)

    qui gen `d22_mid' = 1 / (`q'^2)  if `y' >= 1
    qui replace `d22_mid' = - ((1 -  `e_l') / (`mid'))^2 if `y' == 0
    mlmatsum `lnf' `d22' = `d22_mid' , eq(2)

    matrix `H' = (`d11',`d12' \ `d12',`d22')

end
