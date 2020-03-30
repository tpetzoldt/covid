## SIR metapopulation model in R
##
## author: tpetzoldt, license GPL2, 2013, 2020
##
## first version:
##   https://stat.ethz.ch/pipermail/r-sig-dynamic-models/2013q2/000186.html
## see also: 
##   https://stackoverflow.com/questions/60719860
##   https://github.com/tpetzoldt/covid
## numerical approach:
##   Soetaert, Petzoldt Setzer (2010) https://doi.org/10.18637/jss.v033.i09

library(deSolve)

n <- 7 # number of metapopulations
beta  <- rep(c(-500, 500, 0), each = n)
gamma <- rep(c(0, -365/13, 365/13), each = n)

## case(1) a "fully connected" system
#mig <- 1e-10 # migration rate
#As <- matrix(mig, nrow=n, ncol=n)
#diag(As) <- 0

## case (2) directed move
mig <- 0.0001 # migration rate
As <- matrix(0, nrow=n, ncol=n)
As[1:(n-1), 2:n] <- diag(mig, n-1)
As[2:n, 1:(n-1)] <- As[2:n, 1:(n-1)] + diag(mig, n-1)

## case (3) enter migration matrix manually ...

## expand movement to full matrix, within respective states S, I, R
## assumes that all states move equally; this can of course be changed
A <- matrix(0, nrow = 3 * n, ncol = 3 * n)
A[1:n, 1:n]                     <- As
A[(n+1):(2*n), (n+1):(2*n)]     <- As
A[(2*n+1):(3*n), (2*n+1):(3*n)] <- As

## balance: what moves to other cells needs to be removed from the cell itself
diag(A) <- -rowSums(A)

## migration matrix A
##   - positive values: what moves from the neighbors
##   - negative values: what moves to the neighbors
A

S <- rep(0.99, times=n)
I <-   c(0.01, rep(0, n-1)) # only first sub-population infected
R <- rep(0, times=n)

Y0 <- c(S, I, R)

sirmodel <- function(t, Y, parameters) {
  S <- Y[1:n]
  I <- Y[(n+1):(2*n)]
  #  dS <- -beta*S*I
  #  dI <- beta*S*I-gamma*I
  #  dR <- gamma*I
  dY <- beta * S * I + gamma * I + Y %*% A
  list(dY)
}

times <-seq(from=0, to=0.2, length.out=100)

out <- ode(y = Y0, times = times, func = sirmodel, parms = NULL)
windows(height = 6, width = 2 * n) # create somewhat bigger window
plot(out, xlab = "time", ylab = "-", mfrow=c(3, n))
