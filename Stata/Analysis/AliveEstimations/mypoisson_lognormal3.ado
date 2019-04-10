program define mypoisson_lognormal3

    args todo b lnf g H

    tempvar mu sigma
    mleval `mu' = `b', eq(1)
    mleval `sigma' = `b', eq(2)

    local k "$ML_y1"

    tempvar lnfj sum d1_mid d2_mid d11_mid d12_mid d22_mid
    local m =  `mu'
    local s = `sigma'
    mata : poisson_lognormalp(`m', `s', "`k'", "`sum'", "`d1_mid'", "`d2_mid'", "`d11_mid'", "`d12_mid'", "`d22_mid'")

    qui gen double `lnfj' = `sum'
    qui replace `lnfj' = `lnfj'
    pause

*******************************************************************************
** DEAL WITH K>= 15
*******************************************************************************
    local cutoff = 15

    local V = "(`sigma'^2)"
    local top = "2*`k'*`V'^2 + (log(`k') - `mu')^2 + `V'*log(`k') - `mu'*`V' - `V'"

    local one = "-.5*log(2*_pi*`V')"
    local two = "-log(`k')"
    local three = "- (log(`k') - `mu')^2*(2*`V')^(-1)"
    local four = "-log(2*`k'*`V'^2)"
    local five = "log(`top')"



    qui replace `lnfj' = `one' + `two' + `three' + `four' + `five' if `k' >= `cutoff'

    local one = "(log(`k') - `mu')*(`V')^(-1)"
    local two = "(`top')^(-1) * (-2*log(`k') + 2*`mu' - `V')"
    qui replace `d1_mid' =  `one' + `two'  if `k' >= `cutoff'
    local one = "-5*(`sigma')^(-1)"
    local two = "(log(`k') - `mu')^2 *(`sigma')^(-3)"
    local three = "(`top')^(-1) * (8*`k'*`sigma'^3 + 2*`sigma'*log(`k') - 2*`sigma'*`mu' - 2*`sigma')"
    qui replace `d2_mid' = `one' + `two' + `three' if `k' >= `cutoff'



    local one = "-(`V')^(-1)"
    local two = "-(`top')^(-2) * (-2*log(`k') + 2*`mu' - `V')^2"
    local three = "(`top')^(-1) * 2 "
    qui replace `d11_mid' =  `one' + `two' + `three' if `k' >= `cutoff'

    local one = "-2*(log(`k') - `mu')*(`sigma')^(-3)"
    local two = "- (`top')^(-2) * (-2*log(`k') + 2*`mu' - `V') * (8*`k'*`sigma'^3 + 2*`sigma'*log(`k') - 2*`sigma'*`mu' - 2*`sigma')"
    local three = "- (`top')^(-1) * (2*`sigma')"
    qui replace `d12_mid' =  `one' + `two' + `three' if `k' >= `cutoff'

    local one = "5*(`sigma')^(-2)"
    local two = "-3*(log(`k') - `mu')^2 *(`sigma')^(-4)"
    local three = "-(`top')^(-2) * (8*`k'*`sigma'^3 + 2*`sigma'*log(`k') - 2*`sigma'*`mu' - 2*`sigma')^2"
    local four = "(`top')^(-1) * (24*`k'*`sigma'^2 + 2*log(`k') - 2*`mu' - 2)"
    qui replace `d22_mid' = `one' + `two' + `three' + `four' if `k' >= `cutoff'

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
