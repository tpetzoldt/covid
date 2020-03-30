# covid

The Covid-19 pandemic is currently changing our lives. This repository will contain code snippets and data analyses that help me to understand its development. The tools needed are similar to what we typically use in ecological modelling. However, I am not an epidemiologist, so my view is very naive and everything may be wrong.

## Epidemiological data, models and model-related research

* Data Source from Johns Hopkins University https://github.com/CSSEGISandData/COVID-19
* R Shiny App from Ben Phillips, University of Melbourne https://benflips.shinyapps.io/nCovForecast/
* Basic SEIR model from Christian Hubbs, that inspired my model https://towardsdatascience.com/social-distancing-to-slow-the-coronavirus-768292f04296
* Extended SEIR model from Alison Hill, Harvard University https://github.com/alsnhll/SEIR_COVID19
* Complex SEIR model with seasonal forcing and intervention from Richard Neher's work group at University Basel https://neherlab.org/covid19/
* SIR-X model from Ben Meier and Dirk Brockmann, Robert Koch Institute and Humboldt University Berlin, Germany [webpage](http://rocs.hu-berlin.de/corona/docs/forecast/results_by_country/ ), [paper](https://doi.org/10.1101/2020.02.18.20024414), [sourcecode + data](https://github.com/benmaier/COVID19CaseNumberModel)
* Reports and models from the [Imperial College London](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis/news--wuhan-coronavirus/), Ferguson et al. (2020) [preprint](https://www.imperial.ac.uk/media/imperial-college/medicine/sph/ide/gida-fellowships/Imperial-College-COVID19-NPI-modelling-16-03-2020.pdf) of an individual-based model
* [Surveillance, Outbreak Response Management and Analysis System (SORMAS)](https://path.org/articles/open-source-software-tool-helps-governments-monitor-covid-19/) of the Helmholtz Centre for Infection Research
* **More:** "[Top 15 R resources on Novel COVID-19 Coronavirus](https://towardsdatascience.com/top-5-r-resources-on-covid-19-coronavirus-1d4c8df6d85f)" from Antoine Soetewey 

## Some R code snippets to plot the JHU data

* [**Plots**](https://tpetzoldt.github.io/covid/plot_covid.html) showing the development of raw data, rates of increase and doubling times for some countries (Data source: 2019 Novel Coronavirus COVID-19 (2019-nCoV) [Data Repository by Johns Hopkins CSSE](https://github.com/CSSEGISandData/COVID-19))


## A very basic SEIR model in R

* The [**live demo**](https://weblab.hydro.tu-dresden.de/models/seir/) uses packages **shiny**, **deSolve** and **dygraphs**.
* The model is a standard SEIR model in R, using equations and parametrization from Christian Hubbs. It is a qualitative and technical demonstration, and **not** intended for quantitative forcasts or timing.
* additional basic approaches can be found in the "models" folder.

### The core model in R

This is of course much too primitive for real-world forecasts, but demonstrates the core principle. 
Please consult the papers and models from the epidemiological work groups.

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

## References


Dong, E., Du, H., & Gardner, L. (2020). An interactive web-based dashboard to track COVID-19 in real time. The Lancet Infectious Diseases, S1473309920301201. https://doi.org/10.1016/S1473-3099(20)30120-1

Ferguson, N. M., Laydon, D., Nedjati-Gilani, G., Imai, N., Ainslie, K., Baguelin, M., ... & Dighe, A. (2020). Impact of non-pharmaceutical interventions (NPIs) to reduce COVID-19 mortality and healthcare demand. Imperial College, London. DOI: https://doi. org/10.25561/77482.

Maier, B. F., & Brockmann, D. (2020). Effective containment explains sub-exponential growth in confirmed cases of recent COVID-19 outbreak in Mainland China [Preprint]. Epidemiology. https://doi.org/10.1101/2020.02.18.20024414

Soetaert, K., Petzoldt, T., & Setzer, R. W. (2010). Solving Differential Equations in R: Package deSolve. Journal of Statistical Software, 33(9). https://doi.org/10.18637/jss.v033.i09





----

2020-04-30 [tpetzoldt](https://github.com/tpetzoldt)
