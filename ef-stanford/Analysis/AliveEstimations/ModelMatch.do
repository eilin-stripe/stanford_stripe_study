*******************************************************************************
** OVERVIEW
**
*******************************************************************************

*******************************************************************************
** SETUP
*******************************************************************************
qui {
    set more off
    clear

    ** Setup Paths
    local base = "../../../.."
    include `base'/Code/Stata/file_header.do

    local data_vars = "firm_id month first_month customers gpv transactions " + ///
        "total_customer mcc act_age"

    ** Load in the Stripe Panel data
    use `data_vars' using "`main_panel'", clear

    ** Only keep activated firms
    drop if total_customers < 3

    * Only keep the Computer Software Stores industry (Apps)
    keep if mcc == 5734
    /*
    keep if act_age == 2

    ml model d2 mypoisson_lognormal3 (mu: customers= ) (sigma: customers= )
    ml search
    ml maximize
    */
    * twoway__histogram_gen x, gen(y1 y2) frequency

    * pretty hist customers , xlogbase(1.3) ylogbase(1.2) zeros(1) fraction

    * SynthData, obs(10000) alive(1) p(.5) r(2)
}
*******************************************************************************
** Search for best parameters
*******************************************************************************
qui {
    /*
    local p = "{pr}"
    local r = "{r}"

    local rp = "(`r'*`p')"

    local q = "(1-`p')"
    local q2 = "(`q'^2)"
    local q3 = "(`q'^3)"

    local rp_q = "(`rp'/`q')"
    local rp_q2 = "(`rp'/`q2')"

    local m1 = "(`rp_q')"
    local m2 = "(`rp_q2')"

    local xvar = "customers"
    local dif = "(`xvar'-`m1')"

    local gmm1 = "(eq1: `dif')"
    local gmm2 = "(eq2: `dif'^2 - `m2')"

    local m1_p = "(`r'/`q2')"
    local m1_r = "(`p'/`q')"

    local eq1_p = "(-`m1_p')"
    local eq1_r = "(-`m1_r')"

    local m2_p = "((`r' + `rp')/`q3')"
    local m2_r = "(`p'/`q2')"

    local eq2_p = "(-`m2_p')"
    local eq2_r = "(-`m2_r')"

    disp "`eq1_p'"
    disp "`eq1_r'"
    disp "`eq2_p'"
    disp "`eq2_r'"
    */
}

qui {
    /*
    qui count
    local num_obs = r(N)

    qui count if `xvar' == 0
    local num_zero = r(N)

    local max_D = `num_zero'/`num_obs'

    gen zero = 0
    replace zero = 1 if `xvar' == 0
    gen zero_drop = 0
    */
}
/*
foreach n of numlist 0/100 {
    local D = `n' / 100
    local to_drop = floor(`D' * `num_obs')
    if `D' <= `max_D' {

        qui {
            replace zero_drop = runiform() * zero
            sort `xvar' zero_drop

            zipffit customers if _n >= `to_drop'
            ereturn list
            local test_val = e(ll)

            qui {
                /*
                moments `xvar' if _n >= `to_drop'
                local m1_est = r(mean)
                local m2_est = r(Var)

                local p = 1 - sqrt(`m1_est' / `m2_est')
                local r = ((1 - `p') * `m1_est')/`p'

                disp "`r' `p'"
                qui ksmirnov `xvar' = nbinomial(`r', `xvar', `p')
                qui return list
                */
            }

        }


        disp "`test_val'"
    }
    else {

    }

}
*/
