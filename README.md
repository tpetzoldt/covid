# covid

The Covid-19 pandemic is currently changing our lives. This repository will contain code snippets and data analyses that help me to understand its development. The tools needed are similar to what we typically use in ecological modelling. However, I am not an epidemiologist, so my view is very naive and everything may be wrong.

## Resources from other people

* Data Source from Johns Hopkins University https://github.com/CSSEGISandData/COVID-19
* R Shiny App from Ben Phillips, University of Melbourne https://benflips.shinyapps.io/nCovForecast/
* SEIR model from Christian Hubbs, that inspired my model https://towardsdatascience.com/social-distancing-to-slow-the-coronavirus-768292f04296
* More complex SEIR model from Alison Hill, Harvard University https://github.com/alsnhll/SEIR_COVID19
* Complex model with seasonal forcing and intervention from Richard Neher's work group at University Basel https://neherlab.org/covid19/
* **More:** Top 15 R resources on Novel COVID-19 Coronavirus from Antoine Soetewey https://towardsdatascience.com/top-5-r-resources-on-covid-19-coronavirus-1d4c8df6d85f

## SEIR model with R

My own model is a standard SEIR model in R, using equations and parametrization from Christian Hubbs. It is only a qualitative and technical demonstration, and **not** intended for quantitative forcasts or timing.

The [live demo](https://weblab.hydro.tu-dresden.de/models/seir/) uses packages **shiny**, **deSolve** and **dygraphs**.



----

2020-04-23 tpetzoldt
