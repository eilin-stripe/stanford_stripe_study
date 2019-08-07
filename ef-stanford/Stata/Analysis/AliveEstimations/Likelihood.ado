
program define Likelihood
  version 14
  args lnf theta1

  local y "$ML_y1"
  tempvar middle
  * tempname mid_alive mid_a
  * local `mid_a' = 1 / (1 + exp(-`a') )

  qui gen `middle' = nbinomialp($n, `y', `theta1') * $alive

  qui replace `middle' = `middle' + (1-$alive) if `y' == 0

  qui replace `lnf' = log(`middle')

  disp "n: " $n " p: " `theta1'

end
