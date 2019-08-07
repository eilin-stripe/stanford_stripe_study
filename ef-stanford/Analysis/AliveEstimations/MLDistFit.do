/*
sysuse auto, clear

ml model lf mylogit2 (foreign=mpg weight)
ml maximize
*/

SynthData , obs(10000) alive(.5) p(.1) r(1)
gen test = rpoisson(5)

qui count if test == 0
local zero_count = r(N)
qui count if test != .
local obs_count = r(N)
local max_p = `zero_count' / `obs_count'
local max_trans_p = log(`max_p' / (1- `max_p') )

ml model d2 myzip (lambda: test= ) (p: test= )
ml search p: 0 `max_p'
ml check
ml maximize, difficult

matrix params = e(b)

local r = params[1, 1]
local p = params[1, 2]
disp "r:`r' p:`p'"


ml model lf mynbinomial (r: Customers3= ) (p: Customers3= )
ml search p: 0 1
ml check
ml maximize

qui count if Customers4 == 0
local zero_count = r(N)
qui count if Customers4 != .
local obs_count = r(N)
local max_A = `zero_count' / `obs_count'
local max_trans_A = log(`max_A' / (1- `max_A') )


ml model lf myzinb (r: Customers4= ) (p: Customers4= ) (A: Customers4= )
ml search p: 0 1 A: -10 `max_trans_A'
ml check
ml maximize , difficult

matrix params = e(b)

local r = params[1, 1]
local p = params[1, 2]
local A = params[1, 3]
local A = 1 / (1 + exp(-`A'))
disp "`A'"

qui {
    /*
    ml model lf mynbinomial (r: customers= ) (p: customers= )
    ml search p: 0 1
    ml check
    ml maximize

    qui count if customers == 0
    local zero_count = r(N)
    qui count if customers != .
    local obs_count = r(N)
    local max_A = `zero_count' / `obs_count'
    local max_trans_A = log(`max_A' / (1- `max_A') )

    ml model lf myzinb (r: customers= ) (p: customers= ) (A: customers= )
    ml search p: 0 1 A: -10 `max_trans_A'
    ml check
    ml maximize

    matrix params = e(b)

    local r = params[1, 1]
    local p = params[1, 2]
    local A = params[1, 3]
    local A = 1 / (1 + exp(-`A'))
    */
}
