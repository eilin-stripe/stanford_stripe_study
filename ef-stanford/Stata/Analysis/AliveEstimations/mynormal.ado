program define mynormal
        args lnf mu sigma
        replace `lnf' = -0.5*log(2*_pi) - log(`sigma')
        replace `lnf' = `lnf' - (1/(2*`sigma'^2))*($ML_y1 - `mu')^2
end
