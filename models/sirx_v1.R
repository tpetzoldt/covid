## SIRX-model 
## from from Ben Meier and Dirk Brockmann, 
## Robert Koch Institute and Humboldt University Berlin, Germany
##
## inspired by the python code of:
## http://rocs.hu-berlin.de/corona/docs/forecast/results_by_country/
## http://rocs.hu-berlin.de/corona/docs/forecast/model/
## https://github.com/benmaier/COVID19CaseNumberModel
##
## (still incomplete) re-implementation in R by tpetzoldt


library(deSolve)


sirx_confirmed <- function(t, y, p) {
  with(as.list(c(y, p)), {
    dS <- -eta * S * I - kappa0 * S
    dI <-  eta * S * I - rho * I - kappa * I - kappa0 * I
    dX <- kappa * I + kappa0 * I
    dH <- kappa0 * S

    list(c(dS, dI, dX, dH))
  })
}

## thpe
y0 <- 100 # relative

## from SIRX
R0 <- 6.2
rho <- 1/8
eta <- R0 * rho
I0_factor <- 10

N <- 1e7

kappa <- rho
kappa0 <- rho/2

X0 <- y0 / N
I0 <- X0 * I0_factor
S0 <- 1 - X0-I0

parms <- c(eta, rho, kappa, kappa0)
y0 <- c(S=S0, I=I0, X=X0, H=0)
times <- seq(1, 100)
out <- ode(y0, times, sirx_confirmed, parms)

matplot.0D(out)

plot(out)
