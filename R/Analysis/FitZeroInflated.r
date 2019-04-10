# LOAD LIBRARIES
library(fitdistrplus)    # fits distributions using maximum likelihood
# library(gamlss)          # defines pdf, cdf of ZIP
library(data.table)
library(plm)
library(poilog)
# library(VGAM)

base <- "../../../"
Data <- paste0(base, "Data/")
CleanData <- paste0(Data, "Clean/")
RawData <- paste0(Data, "Raw/")
RawStripe <- paste0(RawData, "Stripe/")

main <- paste0(RawStripe, "stripe_us_merchant_sample_panel.csv")

dt <- fread(main)

setnames(dt, old="unique_payers", new="customers")
setnames(dt, old="total_transactions", new="transactions")
setnames(dt, old="gross_processing_volume", new="gpv")

dt$firm_id <- as.numeric(as.factor(dt$token))
dt[,token:=NULL]
dt$time = substr(dt$month, 0, 7)
dt$time <- as.integer(gsub('-','',dt$time))
dt <- dt[order(firm_id, time)]
dt <- make.pconsecutive(dt, banace.type = "fill", index=c("firm_id", "time"))
dt$year = as.integer(substr(dt$time, 0, 4))
dt$month = as.integer(substr(dt$time, 5, 6))
dt[is.na(dt)] <- 0
dt <- as.data.table(dt)
dt[, age := rowid(firm_id)]



head(dt[age==1,"customers",])

# dt_test2 <- pdata.frame(dt, index = c("firm_id", "time"))
# dt2 <- as.data.table(dt_test2)



customers <- dt[age==2,customers,]

( fit_pois = fitdist(customers, 'pois',
    start = list(lambda = 1),
    lower = c(0, 0),  upper=c(Inf, 1) )
)

( fit_nb = fitdist(customers, 'nbinom',
    start = list(size = 10, prob = .1 ),
    lower = c(0, 0),  upper=c(Inf, 1),
    optim.method = "Nelder-Mead",
    control = list(maxit = 100000, reltol = 1e-20) )
)

# plot(fit_nb, xlogscale = TRUE)



(pstr0_init= mean(customers > 0))

( fit_zinb = fitdist(i.vec, 'zinegbin',
    start = list(pstr0 = pstr0_init, prob = .9, size = 3 ),
    lower = c(0, 0, 0),  upper=c(pstr0_init+.00001 , 1, Inf) )
)

plot(fit_zinb)





(fit <- fitdist(vect, "ZIP", start=list(mu=2.4, sigma=0.1), lower = c(0, 0)))
(fit_zip = fitdist(i.vec, 'ZIP', start = list(mu = 2, sigma = 0.5)))

fit <- fitdist(i.vec, "ZIP", start=list(mu=2, sigma=0.5),
      lower=c(-Inf, 0.001), upper=c(Inf, 1))

# VISUALIZE TEST AND COMPUTE GOODNESS OF FIT

gofstat(fit, print.test = TRUE)

data("toxocara")
(ftoxo.P <- fitdist(toxocara$number, "pois", start=list(lambda=8)))
(ftoxo.nb <- fitdist(toxocara$number, "nbinom"))
plot(ftoxo.P)
plot(ftoxo.nb)
