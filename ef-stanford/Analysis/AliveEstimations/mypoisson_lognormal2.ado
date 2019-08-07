program define mypoisson_lognormal2

    args todo b lnf g H

    tempvar mu sigma
    mleval `mu' = `b', eq(1)
    mleval `sigma' = `b', eq(2)

    local k "$ML_y1"

    tempvar lnfj sum d1_mid d2_mid
    tempvar d11_mid d11_mid1 d11_mid2
    tempvar d12_mid d12_mid1 d12_mid2
    tempvar d22_mid d22_mid1 d22_mid2
    qui gen double `sum' = 0
    qui gen double `d1_mid' = 0
    qui gen double `d2_mid' = 0

    /*
    qui gen double `d11_mid' = 0
    qui gen double `d11_mid1' = 0
    qui gen double `d11_mid2' = 0

    qui gen double `d12_mid' = 0
    qui gen double `d12_mid1' = 0
    qui gen double `d12_mid2' = 0

    qui gen double `d22_mid' = 0
    qui gen double `d22_mid1' = 0
    qui gen double `d22_mid2' = 0
    */

    local node_num = 45
    tempname abs weight
    ghquadm `node_num' `abs' `weight'

    foreach ii of numlist 1/`node_num' {
        local x = `abs'[1,`ii']
        local w = `weight'[1,`ii']

        local x2 = "`x' * sqrt(2)"
        local exponent = "`x2' * `sigma' + `mu'"
        local lambda = "exp(`exponent')"
        local log_p_lk = "-`lambda' + `k' * log(`lambda') - lnfactorial(`k')"
        local p_lk = "exp(`log_p_lk')"

        local term = "`w' * (1/sqrt(_pi)) * `p_lk'"
        qui replace `sum' = `sum' + `term'

        local deriv = "`w' * (1/sqrt(_pi)) * (`k'-`lambda') * `p_lk'"
        qui replace `d1_mid' = `d1_mid' + (`deriv')
        qui replace `d2_mid' = `d2_mid' + (`deriv')*`x2'
        /*
        qui replace `d11_mid1' = `d11_mid1' + (`deriv')^2
        qui replace `d11_mid2' = `d11_mid2' + (`deriv') * (`k'-`lambda')
        qui replace `d11_mid2' = `d11_mid2' - `w' * (1/sqrt(_pi)) * `lambda' * `p_lk'

        qui replace `d12_mid1' = `d12_mid1' + (`deriv')^2*`x2'
        qui replace `d12_mid2' = `d12_mid2' + (`deriv') * (`k'-`lambda') * `x2'
        qui replace `d12_mid2' = `d12_mid2' - `w' * (1/sqrt(_pi)) * `lambda' * `p_lk' *  `x2'

        qui replace `d22_mid1' = `d22_mid1' + (`deriv'*`x2')^2
        qui replace `d22_mid2' = `d22_mid2' + (`deriv') * (`k'-`lambda') * (`x2')^2
        qui replace `d22_mid2' = `d22_mid2' - `w' * (1/sqrt(_pi)) * `lambda' *  `p_lk' * (`x2')^2
        */
    }


    qui replace `d1_mid' = `d1_mid' / (`sum')
    qui replace `d2_mid' = `d2_mid' / (`sum')

    /*
    qui replace `d11_mid1' = - `d11_mid1' / ((`sum')^2)
    qui replace `d11_mid2' = `d11_mid2' / (`sum')
    qui replace `d11_mid' = `d11_mid1' + `d11_mid2'

    qui replace `d12_mid1' = - `d12_mid1' / ((`sum')^2)
    qui replace `d12_mid2' = `d12_mid2' / (`sum')
    qui replace `d12_mid' = `d12_mid1' + `d12_mid2'

    qui replace `d22_mid1' = - `d22_mid1' / ((`sum')^2)
    qui replace `d22_mid2' = `d22_mid2' / (`sum')
    qui replace `d22_mid' = `d22_mid1' + `d22_mid2'
    */

    qui gen double `lnfj' = log(`sum')
    qui replace `lnfj' = `lnfj'
    pause

    mlsum `lnf' = `lnfj'
    if (`todo'==0 | `lnf'>=.) exit

*******************************************************************************
** Gradient Calculations
*******************************************************************************
    tempname d1 d2
    mlvecsum `lnf' `d1' = `d1_mid' , eq(1)
    mlvecsum `lnf' `d2' = `d2_mid' , eq(2)
    matrix `g' = (`d1', `d2')
    if (`todo'==1 | `lnf'>=.) exit

*******************************************************************************
** Hessian Calculations
*******************************************************************************

    tempname d11 d12 d22
    mlmatsum `lnf' `d11' = `d11_mid' , eq(1)
    mlmatsum `lnf' `d12' = `d12_mid' , eq(1,2)
    mlmatsum `lnf' `d22' = `d22_mid' , eq(2)
    matrix `H' = (`d11',`d12' \ `d12',`d22')

    * ml model d2 mypoisson_lognormal2 (mu: test7= )  (sigma: test7= )
    * ml search mu: .5 1 sigma: 2 2.5
end
