*******************************************************************************
** FITTING MOMENTS DIRECTLY
*******************************************************************************
qui {
    /*
    /*
    local m1 = "{m1}"
    local m2 = "{m2}"
    local m3 = "{m3}"
    */
    local xvar = "customers"
    * local dif = "(`xvar'-`m1')"
    /*
    local gmm1 = "(eq1: `dif')"
    local gmm2 = "(eq2: `dif'^2 - `m2' + `m1'^2)"
    local gmm3 = "(eq3: `dif'^3 - `m3' + (3*`m1'*`m2') - 2*`m1'^3)"

    local eq1_m1 = "eq1/m1 = -1"
    local eq2_m1 = "eq2/m1 = -2 * `xvar' + 4 * `m1'"
    local eq2_m2 = "eq2/m2 = -1"
    local eq3_m1 = "eq3/m1 = -3 * `xvar' + 6 * `xvar' * `m1' - 9 *`m1'^2 + 3*`m2'"
    local eq3_m2 = "eq3/m2 = 3*`m1'"
    local eq3_m3 = "eq3/m3 = -1"


    gmm  `gmm1' `gmm2' `gmm3', instruments( ) winitial(identity) ///
        onestep derivative(`eq1_m1') ///
        derivative(`eq2_m1') derivative(`eq2_m2') ///
        derivative(`eq3_m1') derivative(`eq3_m2') derivative(`eq3_m3')

    matrix moments = r(table)
    local m1_est = moments[1,1]
    local m2_est = moments[1,2]
    local m3_est = moments[1,3]
    matrix list moments
    */
    moments `xvar'
    local m1_est = r(mean)
    local m2_est = r(Var) + `m1_est'^2
    local m3_est = r(skewness)*(r(Var)^(3/2)) + (3*`m1_est'*`m2_est') - 2*`m1_est'^3
    disp "`m1_est' `m2_est' `m3_est'"

    local p = 1 - (`m1_est' * (`m2_est' - `m1_est')) / (`m3_est'*`m1_est' - `m2_est'^2)
    local r = (`m2_est' * (1 - `p'))/(`p' * `m1_est') - (1 / `p')
    local A = (`m1_est' * (1 - `p')) / (`r'* `p')
    disp "`A' `p' `r'"
    */
}
*******************************************************************************
** FITTING FUNDAMENTAL PARAMETERS
*******************************************************************************
qui {
    /*
    local p = "{pr}"
    local r = "{r}"
    local A = "{A}"

    local q = "(1-`p')"
    local q2 = "(`q'^2)"
    local q3 = "(`q'^3)"
    local q4 = "(`q'^4)"

    local rp = "(`r'*`p')"
    local rp_add1 = "(`rp' + 1)"

    local rp_q = "(`rp'/`q')"
    local rp_q2 = "(`rp'/`q2')"
    local rp_q3 = "(`rp'/`q3')"
    local rp_q4 = "(`rp'/`q4')"


    local m3_sum = "(1+`p'+3*`rp'+`rp'^2 )"
    local m3_sum_p = "(1 + 3*`r' + 2*`p'*`r'^2)"
    local m3_sum_r = "(3*`p' + 2*`r'*`p'^2)"

    local m1 = "(`A'*`rp_q')"
    local m2 = "(`A'*`rp_q2'*`rp_add1')"
    local m3 = "(`A'*`rp_q3'*`m3_sum')"

    local xvar = "Customers4"
    local dif = "(`xvar'-`m1')"

    local gmm1 = "(eq1: `dif')"
    local gmm2 = "(eq2: `dif'^2 - `m2' + `m1'^2)"
    local gmm3 = "(eq3: `dif'^3 - `m3' + (3*`m1'*`m2') - 2*`m1'^3)"


    local m1_A = "`rp_q'"
    *local m1_p = "( (`A'*`r'*(2*`p'-1) ) / `q2' )"
    local m1_p = "( (`A'*`r')/`q2')"
    local m1_r = "((`A'*`p')/`q')"

    local eq1_A = "(-`m1_A')"
    local eq1_p = "(-`m1_p')"
    local eq1_r = "(-`m1_r')"

    local m2_A = "(`rp_q2'*`rp_add1')"
    local m2_p = "( ((2*`A'*`p'*`r'^2 + `A'*`r')/`q2') + " + ///
        " (2*`A'*`rp_q3'*`rp_add1') )"
    local m2_r = "( (2*`A'*`r'*`p'^2 + `A'*`p')/`q2' )"

    local eq2_A = "(2*`dif'*`m1_A' - `m2_A' + 2*`m1_A')"
    local eq2_p = "(2*`dif'*`m1_p' - `m2_p' + 2*`m1_p')"
    local eq2_r = "(2*`dif'*`m1_r' - `m2_r' + 2*`m1_r')"


    local m3_A = "(`rp_q3' * `m3_sum' )"
    local m3_p = "( ((`A'*`r'*`m3_sum')/`q3') + (`A'*`rp_q3'*`m3_sum_p') + " + ///
        "(3*`A'*`rp_q4'*`m3_sum') )"
    local m3_r = "( ((`A'*`p'*`m3_sum')/`q3') + (`A'*`rp_q3'*`m3_sum_r') )"


    local eq3_A = "(3*`dif'^2*`m1_A' - `m3_A' + 3*`m1'*`m2_A' + 3*`m2'*`m1_A' - 6*`m1'^2*`m1_A')"
    local eq3_p = "(3*`dif'^2*`m1_p' - `m3_p' + 3*`m1'*`m2_p' + 3*`m2'*`m1_p' - 6*`m1'^2*`m1_p')"
    local eq3_r = "(3*`dif'^2*`m1_r' - `m3_r' + 3*`m1'*`m2_r' + 3*`m2'*`m1_r' - 6*`m1'^2*`m1_r')"

    /*
    local gmm2_alt = "(eq2: `p' - .7)"

    gmm  `gmm1' `gmm2_alt' `gmm3', igmm conv_maxiter(200) ///
        instruments( ) winitial(identity) from(A 0.601 r 2 pr 0.7 ) ///
        derivative(eq1/A = `eq1_A')  derivative(eq1/pr = `eq1_p') ///
        derivative(eq1/r = `eq1_r') ///
        derivative(eq3/A = `eq3_A')   ///
        derivative(eq3/r = `eq3_r') derivative(eq3/pr = `eq3_p') ///
        derivative(eq2/pr = 1)
    */

    gmm  `gmm1' `gmm2' `gmm3', onestep  ///
        instruments( ) winitial(identity) from(A 0.5 r 2 pr 0.5 ) ///
        derivative(eq1/A = `eq1_A')  derivative(eq1/pr = `eq1_p') ///
        derivative(eq1/r = `eq1_r') ///
        derivative(eq2/A = `eq2_A')  derivative(eq2/pr = `eq2_p') ///
        derivative(eq2/r = `eq2_r') ///
        derivative(eq3/A = `eq3_A')   ///
        derivative(eq3/r = `eq3_r') derivative(eq3/pr = `eq3_p')
    */
}



/*qui*/ {
    local p = "{pr}"
    local r = "{r}"
    local A = "1"

    local q = "(1-`p')"
    local q2 = "(`q'^2)"
    local q3 = "(`q'^3)"
    local q4 = "(`q'^4)"

    local rp = "(`r'*`p')"
    local rp_add1 = "(`rp' + 1)"

    local rp_q = "(`rp'/`q')"
    local rp_q2 = "(`rp'/`q2')"
    local rp_q3 = "(`rp'/`q3')"
    local rp_q4 = "(`rp'/`q4')"


    local m3_sum = "(1+`p'+3*`rp'+`rp'^2 )"
    local m3_sum_p = "(1 + 3*`r' + 2*`p'*`r'^2)"
    local m3_sum_r = "(3*`p' + 2*`r'*`p'^2)"

    local m1 = "(`A'*`rp_q')"
    local m2 = "(`A'*`rp_q2'*`rp_add1')"
    local m3 = "(`A'*`rp_q3'*`m3_sum')"

    local xvar = "customers"
    local dif = "(`xvar'-`m1')"

    local gmm1 = "(eq1: `dif')"
    local gmm2 = "(eq2: `dif'^2 - `m2' + `m1'^2)"
    * local gmm3 = "(eq3: `dif'^3 - `m3' + (3*`m1'*`m2') - 2*`m1'^3)"


    local m1_A = "`rp_q'"
    *local m1_p = "( (`A'*`r'*(2*`p'-1) ) / `q2' )"
    local m1_p = "( (`A'*`r')/`q2')"
    local m1_r = "((`A'*`p')/`q')"

    local eq1_A = "(-`m1_A')"
    local eq1_p = "(-`m1_p')"
    local eq1_r = "(-`m1_r')"

    local m2_A = "(`rp_q2'*`rp_add1')"
    local m2_p = "( ((2*`A'*`p'*`r'^2 + `A'*`r')/`q2') + " + ///
        " (2*`A'*`rp_q3'*`rp_add1') )"
    local m2_r = "( (2*`A'*`r'*`p'^2 + `A'*`p')/`q2' )"

    local eq2_A = "(2*`dif'*`m1_A' - `m2_A' + 2*`m1_A')"
    local eq2_p = "(2*`dif'*`m1_p' - `m2_p' + 2*`m1_p')"
    local eq2_r = "(2*`dif'*`m1_r' - `m2_r' + 2*`m1_r')"


    local m3_A = "(`rp_q3' * `m3_sum' )"
    local m3_p = "( ((`A'*`r'*`m3_sum')/`q3') + (`A'*`rp_q3'*`m3_sum_p') + " + ///
        "(3*`A'*`rp_q4'*`m3_sum') )"
    local m3_r = "( ((`A'*`p'*`m3_sum')/`q3') + (`A'*`rp_q3'*`m3_sum_r') )"


    local eq3_A = "(3*`dif'^2*`m1_A' - `m3_A' + 3*`m1'*`m2_A' + 3*`m2'*`m1_A' - 6*`m1'^2*`m1_A')"
    local eq3_p = "(3*`dif'^2*`m1_p' - `m3_p' + 3*`m1'*`m2_p' + 3*`m2'*`m1_p' - 6*`m1'^2*`m1_p')"
    local eq3_r = "(3*`dif'^2*`m1_r' - `m3_r' + 3*`m1'*`m2_r' + 3*`m2'*`m1_r' - 6*`m1'^2*`m1_r')"

    /*
    local gmm2_alt = "(eq2: `p' - .7)"

    gmm  `gmm1' `gmm2_alt' `gmm3', igmm conv_maxiter(200) ///
        instruments( ) winitial(identity) from(A 0.601 r 2 pr 0.7 ) ///
        derivative(eq1/A = `eq1_A')  derivative(eq1/pr = `eq1_p') ///
        derivative(eq1/r = `eq1_r') ///
        derivative(eq3/A = `eq3_A')   ///
        derivative(eq3/r = `eq3_r') derivative(eq3/pr = `eq3_p') ///
        derivative(eq2/pr = 1)
    */


    gmm  `gmm1' `gmm2', onestep  ///
        instruments( ) winitial(identity) from( r 2 pr 0.5 ) ///
        derivative(eq1/pr = `eq1_p') derivative(eq1/r = `eq1_r')  ///
        derivative(eq2/pr = `eq2_p') derivative(eq2/r = `eq2_r')

    }
