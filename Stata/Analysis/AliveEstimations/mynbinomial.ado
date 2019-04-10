program define mynbinomial

    args todo b lnf g H

    tempvar r p
    mleval `r' = `b', eq(1)
    mleval `p' = `b', eq(2)

    local k "$ML_y1"

    mlsum `lnf' = lngamma(`k'+`r') - lnfactorial(`k') ///
        - lngamma(`r') + `k' * log(`p') + `r' *  log(1-`p')

    if (`todo'==0 | `lnf'>=.) exit

*******************************************************************************
** Gradient Calculations
*******************************************************************************
    tempname d1 d2
    mlvecsum `lnf' `d1' =  digamma(`k'+`r') - digamma(`r') + log(1-`p'), eq(1)
    mlvecsum `lnf' `d2' =  (`k'/`p') - (`r'/(1- `p')), eq(2)
    matrix `g' = (`d1', `d2')
    if (`todo'==1 | `lnf'>=.) exit

*******************************************************************************
** Hessian Calculations
*******************************************************************************

    tempname d11 d12 d22
    mlmatsum `lnf' `d11' = trigamma(`k'+`r') - trigamma(`r') , eq(1)
    mlmatsum `lnf' `d12' = - (1/(1- `p')) , eq(1,2)
    mlmatsum `lnf' `d22' = -(`k'/(`p'^2)) - (`r'/((1- `p')^2)) , eq(2)
    matrix `H' = (`d11',`d12' \ `d12',`d22')

end
