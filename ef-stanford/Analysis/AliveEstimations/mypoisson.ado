program mypoisson
    version 13

    args todo b lnf g H

    tempvar lambda
    mleval `lambda' = `b', eq(1)

    local y "$ML_y1"

    mlsum `lnf' = `y' * log(`lambda')- `lambda' - lnfactorial(`y')
    if (`todo'==0 | `lnf'>=.) exit

    tempname d1
    mlvecsum `lnf' `d1' = (`y'/`lambda') -1 , eq(1)
    matrix `g' = (`d1')
    if (`todo'==1 | `lnf'>=.) exit

    tempname d11
    mlmatsum `lnf' `d11' = - (`y'/(`lambda'^2)) , eq(1)
    matrix `H' = (`d11')
end
