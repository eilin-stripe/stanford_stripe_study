program define SynthData
version 10.1
syntax , obs(int) alive(real) p(real) r(real)
    qui {
        clear

        set obs `obs'

        gen FirmType = rgamma(1, 1)
        gen Alive = rbinomial(1, `alive')
        gen Customers = rpoisson(FirmType)
        gen Customers2 = Customers * Alive
        gen Customers3 = rnbinomial(`r', `p')
        gen Customers4 = rnbinomial(`r', `p') * Alive


    }
end
