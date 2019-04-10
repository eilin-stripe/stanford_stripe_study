program xtfe
    version 11
    syntax varlist if, at(name)
    quietly {
        tempvar mu mubar ybar
        generate double `mu' = exp(kids*`at'[1,1] ///
        + cvalue*`at'[1,2] ///
        + tickets*`at'[1,3]) `if'
        egen double `mubar' = mean(`mu') `if', by(id)
        egen double `ybar' = mean(accidents) `if', by(id)
        replace `varlist' = accidents ///
        - `mu'*`ybar'/`mubar' `if'
    }
end
