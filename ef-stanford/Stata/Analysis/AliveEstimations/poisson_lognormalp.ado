program define poisson_lognormalp , rclass
    version 14.0
    syntax varlist , out(string) [mu(real 0) sigma(real 1)]

    mata : poisson_lognormalp2(`mu', `sigma', "`varlist'", "`out'")

end
