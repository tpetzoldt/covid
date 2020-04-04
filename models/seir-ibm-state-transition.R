## Stochastic SEIR model with explicit individuals and state transition matrix
## The individuals are identical, so the same could also be done with an
## aggregated Markov model -- but this implementation allows extensions
## towards an individual-based model (IBM) with demography and movement.
##
## thpe, 2020-04-04

library("dplyr")
library("reshape2")
library("ggplot2")

## ==== functions ==============================================================

## just for testing
update_state_v0 <- function(state, tmat) {
  newstate <- numeric(length(state))
  for (i in 1:length(state)) {
    newstate[i] <- sample(1:4, 1, prob = tmat[state[i], ])
  }
  newstate
}

## same result, but much faster
update_state  <- function(state, tmat) {
  newstate  <- numeric(length(state))
  states    <- unique(state)
  for (i in 1:length(states)) {
    ndx <- which(state == states[i])
    n   <- length(ndx)
    if (n > 0)
      newstate[ndx] <- sample(1:4, n, replace=TRUE, prob = tmat[states[i],])
  }
  newstate
}


gen_tmat <- function(state, A, alpha=0.5) {
  # A <- matrix(
  #   #  1,   2,  3,  4
  #   c( NA, NA,  0,  0,
  #      .0, .9, .1,  0,
  #      0,  0,  9,  .1,
  #      0,  0,  0,  1
  #   ),
  #   ncol = 4,
  #   byrow=TRUE
  # )
  N <- length(state)
  S <- sum(state == 1) / N
  I <- sum(state == 3) / N
  p <- alpha * S * I
  A[1, 1:2] <- c(1-p, p)
  A
}

## define constants of states, L makes sure that it is integer
## Note different counting, SCP == 1
SCP <- 1L
EXP <- 2L
INF <- 3L
REC <- 4L


## ==== simulation =============================================================

## ---- setup ------------------------------------------------------------------

## matrix with transition probabilities between states
## transition S --> E is calculated as: alpha * S/N * I/N
## row:    x_t   ('from state')
## column: x_t+1 ('to state')
## row sums must be 1.0
A <- matrix(
  #  S,   E,  I,  R
  c( NA, NA,  0,  0,
     .0, .9, .1,  0,
      0,  0, .9, .1,
      0,  0,  0,  1
  ),
  ncol  = 4,
  byrow = TRUE
)

N     <- 1000
Ninf  <- 10
time  <- 1:150
alpha <- 0.5

## initial state vector, can be extended to a data frame with additional states
state <- c(rep(INF, Ninf), rep(SCP, N - Ninf))

## ---- run --------------------------------------------------------------------

## the following will become a function
X <- matrix(nrow=length(time), ncol=length(state))
X[1, ] <- state
for (i in time[-1]) {
  state <- X[i-1,]
  tmat <- gen_tmat(state, A, alpha)
  X[i, ] <- update_state(state, tmat)
}

out <- as.data.frame(cbind(time, X))
tmp <- melt(out, id.vars="time", variable.name="ID", value.name="state")
tmp$state <- factor(tmp$state, labels=c("S", "E", "I", "R"))
tmp$ID    <- as.numeric(tmp$ID) # numeric IDs

tmp %>%
  group_by(time, state) %>%
  summarize(N=n()) %>%
  ggplot(aes(time, N, color=state)) + geom_line()
