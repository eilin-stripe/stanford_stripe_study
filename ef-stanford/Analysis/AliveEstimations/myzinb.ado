program define myzinb
    args todo b lnf g H

    tempvar l p_pre p A_pre A
    mleval `l' = `b', eq(1)
    mleval `p_pre' = `b' , eq(2)
    mleval `A_pre' = `b' , eq(3)

    gen `p' = `p_pre'
    gen `A' = `A_pre'

    local k "$ML_y1"

    tempvar lnfj q e_l mid
    local q = "1 - `p'"
    local B = "1 - `A'"
    local kr = "`k' + `r'"
    gen `mid' = `A' + (`B')*(`q')^`r'

    qui gen `lnfj' = lngamma(`kr') - lnfactorial(`k') - lngamma(`r') ///
        + `k' * log(`p') + `r' *  log(`q') + ln(`B') if `k' >= 1

    qui replace `lnfj' = log(`mid') if `k' == 0

    mlsum `lnf' = `lnfj'
    if (`todo'==0 | `lnf'>=.) exit

    *******************************************************************************
    ** Gradient Calculations
    *******************************************************************************
    tempname d1_mid d2_mid d3_mid d1 d2 d3

    qui gen `d1_mid' =  digamma(`k'+`r') - digamma(`r') + log(1-`p') if `k' >= 1
    qui gen `d2_mid' =  (`k'/`p') - (`r'/(1- `p')) if `k' >= 1
    qui gen `d3_mid' =   - (1/(1- `A')) if `k' >= 1

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
