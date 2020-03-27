# covid

The Covid-19 pandemic is currently changing our lives. This repository will contain code snippets and data analyses that help me to understand its development. The tools needed are similar to what we typically use in ecological modelling. However, I am not an epidemiologist, so my view is very naive and everything may be wrong.

## Resources from other people

* Data Source from Johns Hopkins University https://github.com/CSSEGISandData/COVID-19
* R Shiny App from Ben Phillips, University of Melbourne https://benflips.shinyapps.io/nCovForecast/
* Basic SEIR model from Christian Hubbs, that inspired my model https://towardsdatascience.com/social-distancing-to-slow-the-coronavirus-768292f04296
* Extended SEIR model from Alison Hill, Harvard University https://github.com/alsnhll/SEIR_COVID19
* Complex SEIR model with seasonal forcing and intervention from Richard Neher's work group at University Basel https://neherlab.org/covid19/
* SIR-X model from Dirk Brockmann, Robert Koch Institute and Humboldt university Berlin, Germany [webpage](http://rocs.hu-berlin.de/corona/docs/forecast/results_by_country/ ), [paper](https://doi.org/10.1101/2020.02.18.20024414), [sourcecode + data](https://github.com/benmaier/COVID19CaseNumberModel)
* Reports and models from the [Imperial College London](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/news--wuhan-coronavirus/)
* **More:** "[Top 15 R resources on Novel COVID-19 Coronavirus](https://towardsdatascience.com/top-5-r-resources-on-covid-19-coronavirus-1d4c8df6d85f)" from Antoine Soetewey 

## Some R code snippets to plot the JHU data

* [**Plots**](https://tpetzoldt.github.io/covid/plot_covid.html) showing the development of raw data, rates of increase and doubling times for some countries (Data source: 2019 Novel Coronavirus COVID-19 (2019-nCoV) [Data Repository by Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19))


## A very basic SEIR model in R

My own model is a standard SEIR model in R, using equations and parametrization from Christian Hubbs and the **deSolve** package for numerical integration. It is a qualitative and technical demonstration, and **not** intended for quantitative forcasts or timing.

### Live demo

The [**live demo**](https://weblab.hydro.tu-dresden.de/models/seir/) uses packages **shiny**, **deSolve** and **dygraphs**.

### The core model in R

```
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
```

As said, this is much too primitive for real-world forecasts, but demonstrates the core principle.

----

2020-04-27 [tpetzoldt](https://github.com/tpetzoldt)
