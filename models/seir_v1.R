## Basic SEIR model
## core model and parameters taken from:
##   https://towardsdatascience.com/social-distancing-to-slow-the-coronavirus-768292f04296
##
## re-implemented in R by tpetzoldt
## 
## see also:
##   Soetaert, Petzoldt Setzer (2010) https://doi.org/10.18637/jss.v033.i09

library("deSolve")
SEIR <- function(t, y, parms) {
  with(as.list(c(parms, y)), {
    dS <- -rho * beta * I * S
    dE <-  rho * beta * S * I - alpha * E
    dI <-  alpha * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR), r = dI/I)
  })
}

# state variables: fractions of total population
y0 <- c(S=1 - 5e-4,       # susceptible
        E=4e-4,           # exposed
        I=1e-4,           # infected
        R=0)              # recovered or deceased

parms  <- c(alpha = 0.2,  # inverse of incubation period (5 days)
            beta = 1.75,  # average contact rate
            gamma = 0.5,  # inverse of mean infectious period (2 days)
            rho = 1)      # social distancing factor (0 ... 1)

# time in days
times <- seq(0, 150, 1)

# numerical integration
out <- ode(y0, times, SEIR, parms, method="bdf", atol=1e-8, rtol=1e-8)
plot(out)
