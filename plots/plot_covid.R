################################################################################
### R functions to plot the Covid 19 data
###
### Author: tpetzoldt, License: GPL-2
###
### Note: this code is only for my personal understanding and may contain errors
################################################################################

## Johns Hopkins data:
## https://github.com/CSSEGISandData/COVID-19
##
## Paper:
##
## Dong, E., Du, H., & Gardner, L. (2020).
## An interactive web-based dashboard to track COVID-19 in real time.
## The Lancet Infectious Diseases, S1473309920301201.
## https://doi.org/10.1016/S1473-3099(20)30120-1


library("dplyr")
library("readr")
library("ggplot2")
library("reshape2")

## locally dowloaded file (cloned Git repository)
#file <- "COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"

## direct download
file <- "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"

dat <- read_delim(file, delim=",",
                  escape_double = FALSE,
                  trim_ws = TRUE)

names(dat)[1:2] <- c("Province_State", "Country_Region")

## summarize Country/Region duplicates
dat2 <-
  dat %>%
  group_by(Country_Region) %>% summarise_at(vars(-(1:4)), sum) %>%
  melt(id.vars = "Country_Region", variable.name = "time") %>%
  mutate(time = as.POSIXct(time, format="%m/%e/%y"))


## exponential graph
dat2 %>%
  filter(Country_Region %in% c("Italy", "Spain","France", "Germany", "US")) %>%
  ggplot(aes(time, value, color=Country_Region)) +
  geom_line()


## log-transformed
##    use only values > 100
dat2 %>%
  filter(value > 100) %>%
  filter(Country_Region %in% c("China", "Iran", "Italy", "Spain","France", "Germany", "US", "Korea, South")) %>%
  ggplot(aes(time, value, color=Country_Region)) +
  geom_line() + scale_y_log10()


## 1st derivative of log to estimate the growth rate
dat2 %>%
  filter(value > 100, time < last(time)) %>%
  #filter(value > 100, time < last(time)) %>% # optional: omit last value, that may be less reliable
  filter(Country_Region %in% c("China", "Italy", "Germany", "France", "US", "Korea, South")) %>%
  mutate(log=log(value)) %>%
  group_by(Country_Region) %>%
  mutate(growthrate = c(NA, diff(log)/diff(as.numeric(format(time, "%j"))))) %>%
  filter(!is.na(growthrate)) %>%
  ggplot(aes(time, growthrate, color=Country_Region)) +
  geom_point() + geom_smooth() +
  labs(y = "rate (1/d)")

## 1st derivative, delayed
lag <- 7
dat2 %>%
  filter(value > 100) %>%
  #filter(value > 100, time < last(time)) %>%
  filter(Country_Region %in% c("China", "Italy", "Germany", "France", "US", "Korea, South")) %>%
  mutate(log = log(value)) %>%
  group_by(Country_Region) %>%
  mutate(growthrate = c(rep(NA, lag), diff(log, lag = lag) / diff(as.numeric(format(time, "%j")), lag=lag))) %>%
  filter(!is.na(growthrate)) %>%
  ggplot(aes(time, growthrate, color=Country_Region)) +
  geom_point() + geom_smooth() +
  labs(y = "rate (1/d)")


## doubling time with differens smoothers
## rlm: a robust polynomial linear model (assigns less influence to outliers)
lag <- 7 # larger values dampen influence of day by day variation
dat2 %>%
  filter(value > 100) %>%
  #filter(time < last(time)) %>% # optional: omit last value, that may be less reliable
  filter(Country_Region %in% c("Italy", "Germany", "France", "US")) %>%
  mutate(log=log(value)) %>%
  group_by(Country_Region) %>%
  mutate(growthrate = c(rep(NA, lag), diff(log, lag = lag) / diff(as.numeric(format(time, "%j")), lag=lag))) %>%
  filter(!is.na(growthrate)) %>%
  mutate(doubling = log(2) / growthrate) %>%
  ggplot(aes(time, doubling, color=Country_Region)) +
  geom_point() +
  ## enable only one of the following smoothers
  #geom_smooth() +
  #geom_smooth(method="gam" ,formula=y ~ s(x, bs = "cs"), se=FALSE) +
  geom_smooth(method= MASS::rlm, formula=y ~ poly(x, 3), se=FALSE) +
  coord_cartesian(ylim = c(-2, 10)) +
  labs(y = "doubling time (d)")
