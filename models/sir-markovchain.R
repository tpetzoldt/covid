## model found at:
## https://www.r-bloggers.com/a-discrete-time-markov-chain-dtmc-sir-model-in-r/

library(markovchain)
mcSIR <- new("markovchain", states=c("S","I","R"),
    transitionMatrix=matrix(data=c(0.9,0.1,0,0,0.8,0.2,0,0,1),
    byrow=TRUE, nrow=3), name="SIR")
initialState <- c(99,0,1)

> show(mcSIR)
SIR
 A  3 - dimensional discrete Markov Chain with following states
 S I R 
 The transition matrix   (by rows)  is defined as follows
    S   I   R
S 0.9 0.1 0.0
I 0.0 0.8 0.2
R 0.0 0.0 1.0

You can also plot your transition probabilities:

plot(mcSIR,package="diagram")

dtmc-sir-transitionnetwork

imesteps <- 100
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


 &g; absorbingStates(mcSIR)
[1] "R"
> transientStates(mcSIR)
[1] "S" "I"
> steadyStates(mcSIR)
     S I R
[1,] 0 0 1

And you can calculate the first timestep that your Markov Chain reaches its steady state (the “time to absorption”), which your plot should corroborate:

> ab.state  occurs.at  (sir.df[row,]$timestep)+1
[1] 58


 