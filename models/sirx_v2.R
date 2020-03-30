## model implemented by tpetzoldt
## inspired by the python code of:
## http://rocs.hu-berlin.de/corona/docs/forecast/results_by_country/
## http://rocs.hu-berlin.de/corona/docs/forecast/model/
## https://github.com/benmaier/COVID19CaseNumberModel

library(deSolve)


sirx <- function(t, y, p) {
  with(as.list(c(y, p)), {
    dS <- -alpha * S * I - kappa0 * S
    dI <-  alpha * S * I - beta * I - kappa0 * I - kappa * I
    dX <- (kappa0 + kappa) * I
    dR <- kappa0 * S + beta * I

    list(c(dS, dI, dX, dR))
  })
}

#R0    <- 3.07      # webpage
R0    <- 6.2        # github code
beta  <- 0.38       # webpage
alpha <- R0 * beta  # webpage

kappa  <- beta      # github
kappa0 <- beta/2    # github

I0 <- 1e-4          # assumption
S0 <- 1 - I0
X0 <- 0

parms <- c(alpha, beta, kappa, kappa0)
y0 <- c(S=S0, I=I0, X=X0, R=0)
times <- seq(1, 30, 0.1)
out <- ode(y0, times, sirx, parms, method="bdf", atol=1e-8)

#matplot.0D(out)
plot(out)
