*! version 1.0.0
version 14.0
mata:
    mata clear
    function poisson_lognormalp(real scalar mu, real scalar sigma, ///
        string k_name, string prob, string d1_var, string d2_var, ///
        string d11_var, string d12_var, string d22_var)
    {
        real matrix K, abs, weight, mult, x2, exponent, lambda, plk
        real matrix f, deriv, d1, d2, d11, d12, d22
        real scalar nodes


        K = st_data(., k_name)

        nodes = 25
        stata("ghquadm 25 abs weight")
        abs = st_matrix("abs")
        weight = st_matrix("weight") * (1/sqrt(pi()))

        expo = abs*sqrt(2)*sigma :+mu
        lambda = exp(expo)

        dif = abs(J(1, nodes, K) - J(st_nobs(), 1, lambda))
        ind = (dif :== rowmin(dif))
        best_lambda = rowmax(J(st_nobs(), 1, lambda) :* ind)
        ind = (J(st_nobs(), 1, lambda) :== best_lambda)
        best_weight = ind * weight'
        best_expo = ind * expo'

        div_w = J(st_nobs(), 1, weight) :* best_weight:^(-1)
        e_dif = J(st_nobs(), 1, expo) :- best_expo
        l_dif = best_lambda :- J(st_nobs(), 1, lambda)
        up = J(1, nodes, K) :* e_dif :+ l_dif
        right = log(rowsum(exp(up) :* div_w))
        left = log(best_weight) :+ K :* best_expo :- best_lambda :- lnfactorial(K)
        ll = right :+ left
        f = exp(ll)'

        mult = (abs*sqrt(2)*sigma :+ mu)
        x2 = J(st_nobs(), 1, abs*sqrt(2))
        exponent = J(st_nobs(), 1, mult)
        lambda = J(st_nobs(), 1, exp(abs*sqrt(2)*sigma :+mu))
        plk = exp( - lambda :+ (J(1, nodes, K) :* exponent) :- J(1, nodes, lnfactorial(K)) )
         // f = weight * plk'

        deriv = (J(1, nodes, K) :- lambda) :* plk
        d1 =  (weight * deriv') :/ f
        d2 =  (weight * (deriv :* x2)') :/ f

        d11 = - d1:^2 - ((weight * (lambda :* plk)') :/ f) + ///
            ((weight * ((J(1, nodes, K) :- lambda):^2 :* plk)') :/ f)

        d12 = - (d1 :* d2)  - ((weight * (lambda :* plk :* x2)') :/ f) + ///
            ((weight * ((J(1, nodes, K) :- lambda):^2 :* plk :* x2)') :/ f) ///


        d22 = - d2:^2  - ((weight * (lambda :* plk :* x2:^2 )') :/ f) + ///
            ((weight * ((J(1, nodes, K) :- lambda):^2 :* plk :* x2:^2)') :/ f)

        /*
        cutoff = 17
        V = sigma^2

        one = (2*pi()*V)^(-.5) * K:^(-1)
        two = exp(-(log(K):-mu):^2*(2*V)^(-1))
        paran = (log(K):-mu):^2*V^(-1) :+ log(K) :- mu :- 1
        three = (1 :+ (2*K*V):^(-1):*(paran))

        g = f'
        g = one:*two:*three :*  (K :>= cutoff) :+ (K :< cutoff) :* g
        */






        a = st_addvar("float", prob)
        st_store(., prob, ll)

        b = st_addvar("float", d1_var)
        st_store(., d1_var, d1')

        c = st_addvar("float", d2_var)
        st_store(., d2_var, d2')

        d = st_addvar("float", d11_var)
        st_store(., d11_var, d11')

        e = st_addvar("float", d12_var)
        st_store(., d12_var, d12')

        f = st_addvar("float", d22_var)
        st_store(., d22_var, d22')

    }

    function poisson_lognormalp2(real scalar mu, real scalar sigma, ///
        string k_name, string prob)
    {
        real matrix K, abs, weight, mult, x2, exponent, lambda, plk, f
        real scalar nodes


        K = st_data(., k_name)

        nodes = 95
        stata("ghquadm 95 abs weight")
        abs = st_matrix("abs")
        weight = st_matrix("weight") * (1/sqrt(pi()))


        mult = (abs*sqrt(2)*sigma :+ mu)
        exponent = J(st_nobs(), 1, mult)
        lambda = J(st_nobs(), 1, exp(abs*sqrt(2)*sigma :+mu))
        plk = exp( - lambda :+ (J(1, nodes, K) :* exponent) :- J(1, nodes, lnfactorial(K)) )
        f = weight * plk'



        cutoff = 17
        V = sigma^2
        top = 2*K*(V^2) :+ (log(K) :- mu):^2 :+ V*log(K) :- mu*V :- V
        one = -.5*log(2*pi()*V)
        two = -log(K)
        three = - (log(K) :- mu):^2*(2*V)^(-1)
        four = -log(2*K*V^2)
        five = log(top)

        g = f'
        g = exp(one:+two:+three:+four:+five) :*  (K :>= cutoff) :+ (K :< cutoff) :* g

        one = (2*pi()*V)^(-.5) * K:^(-1)
        two = exp(-(log(K):-mu):^2*(2*V)^(-1))
        paran = (log(K):-mu):^2*V^(-1) :+ log(K) :- mu :- 1
        three = (1 :+ (2*K*V):^(-1):*(paran))

        g = one:*two:*three :*  (K :>= cutoff) :+ (K :< cutoff) :* g

        a = st_addvar("float", prob)
        st_store(., prob, g)

        /*
        local one = "2*(log(K) - mu)*(2*V)^(-1)"
        local two = "(`top')^(-1) * (-2*log(K) + 2*mu - V)"
        qui replace `d1_mid' =  `one' + `two'  if K >= `cutoff'
        local one = "-5*(`sigma')^(-1)"
        local two = "(log(K) - mu)^2 *(`sigma')^(-3)"
        local three = "(`top')^(-1) * (8*K*`sigma'^3 + 2*`sigma'*log(K) - 2*`sigma'*mu - 2*`sigma')"
        qui replace `d2_mid' = `one' + `two' + `three' if K >= `cutoff'



        local one = "-(V)^(-1)"
        local two = "(`top')^(-2) * (-2*log(K) + 2*mu - V)^2"
        local three = "(`top')^(-1) * 2 "
        qui replace `d11_mid' =  `one' + `two' + `three' if K >= `cutoff'

        local one = "-2*(log(K) - mu)*(`sigma')^(-3)"
        local two = "(`top')^(-2) * (-2*log(K) + 2*mu - V) * (8*K*`sigma'^3 + 2*`sigma'*log(K) - 2*`sigma'*mu - 2*`sigma')"
        local three = "(`top')^(-1) * (-2*`sigma')"
        qui replace `d12_mid' =  `one' + `two' + `three' if K >= `cutoff'

        local one = "5*(`sigma')^(-2)"
        local two = "-3*(log(K) - mu)^2 *(`sigma')^(-4)"
        local three = "(`top')^(-2) * (8*K*`sigma'^3 + 2*`sigma'*log(K) - 2*`sigma'*mu - 2*`sigma')^2"
        local four = "(`top')^(-1) * (24*K*`sigma'^2 + 2*log(K) - 2*mu - 2)"
        qui replace `d22_mid' = `one' + `two' + `three' + `four' if K >= `cutoff'
        */
    }

    mata mosave poisson_lognormalp(), replace
    mata mosave poisson_lognormalp2(), replace

end
