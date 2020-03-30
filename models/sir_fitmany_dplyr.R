## fit SIR model to multiple data using tidyverse pipes
## code and data inspired by: https://stackoverflow.com/questions/60907116/
##
## More about this: https://github.com/tpetzoldt/covid


library(deSolve)
library(tidyverse)

cp <- data.frame(
  date     = c('2020-03-24','2020-03-25','2020-03-26','2020-03-24','2020-03-25','2020-03-26'),
  fips     = c(1001,1001,1001,1002,1002,1002),
  Infected = c(1,2,4,4,7,9),
  day      = c(1,2,3,1,2,3),
  N        = c(55601,55601,55601,2231,2231,2231)
)

SIR <- function(time, state, parameters) {
  par <- as.list(c(state, parameters))
  with(par, {
    N  <- S + I + R
    dS <- -beta/N * I * S
    dI <- beta/N * I * S - gamma * I
    dR <- gamma * I
    list(c(dS, dI, dR))
  })
}

RSS <- function(parameters, init, data) {
  names(parameters) <- c("beta", "gamma")
  out <- ode(y = init,
             times = data$day, func = SIR, parms = parameters)
  fit <- out[ , 3]
  sum((data$Infected - fit)^2)
}

fit_model <- function(data) {
  init <- slice(data, 1) %>% select(S, I, R) %>% unlist()
  opt <- optim(c(0.5, 0.5), RSS,
               init = init,
               data = data,
               method = "L-BFGS-B",
               lower = c(0, 0),
               upper = c(1, 1))

  data.frame(alpha=opt$par[1], beta=opt$par[2], RSS=opt$value,
             conv= opt$convergence, ok = opt$convergence == 0)
}

cp %>%
  group_by(fips) %>%
  mutate(S = N[1]-Infected[1], I = Infected[1], R = 0) %>%
  group_modify( ~ fit_model(.))
