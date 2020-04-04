## Model from "Nicole Radziwill" found at:
## https://www.r-bloggers.com/a-discrete-time-markov-chain-dtmc-sir-model-in-r/
## and
## https://qualityandinnovation.com/2015/12/08/a-discrete-time-markov-chain-dtmc-sir-model-in-r/
##
## Kermack, W. O., & McKendrick, A. G. (1932). Contributions to the mathematical
## theory of epidemics. II.—The problem of endemicity. Proceedings of the Royal
## Society of London. Series A, containing papers of a mathematical and physical
## character, 138(834), 55-83.

library(markovchain)
mcSIR <- new("markovchain", states=c("S","I","R"),
             transitionMatrix=matrix(data=c(0.9,0.1,0,0,0.8,0.2,0,0,1),
                                     byrow=TRUE, nrow=3), name="SIR")
initialState <- c(99,0,1)

show(mcSIR)

plot(mcSIR,package="diagram")


timesteps <- 100

sir.df <- data.frame( "timestep" = numeric(),
                      "S" = numeric(), "I" = numeric(),
                      "R" = numeric(), stringsAsFactors=FALSE)

for (i in 0:timesteps) {
    newrow <- as.list(c(i,round(as.numeric(initialState * mcSIR ^ i),0)))
    sir.df[nrow(sir.df) + 1, ] <- newrow
}

plot(sir.df$timestep,sir.df$S)
points(sir.df$timestep,sir.df$I, col="red")
points(sir.df$timestep,sir.df$R, col="green")


absorbingStates(mcSIR)
transientStates(mcSIR)
steadyStates(mcSIR)

ab.state <- absorbingStates(mcSIR)
occurs.at <- min(which(sir.df[,ab.state]==max(sir.df[,ab.state])))

#(sir.df[row,]$timestep) + 1

## thpe: maybe:

(sir.df[occurs.at,]$timestep) + 1
