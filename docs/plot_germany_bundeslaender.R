## Plot data of German Federal States (Bundeslaender)

library("rjson")
library("tidyverse")


file <- "https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.geojson"
data = rjson::fromJSON(file=file)
tmp <- lapply(1:length(data$features), function(x) unlist(data$features[x][[1]]$properties))
table <- as_tibble(t(simplify2array(tmp)))

## try to read only parts of DB over the REST API
# library("httr")
# file <- "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?where=1%3D1&outFields=*&outSR=4326&f=json"
# file <- "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?where=Bundesland%20%3D%20'SACHSEN'&outFields=*&outSR=4326&f=json"
# file <- "https://services7.arcgis.com/mOBPykOjAyBO2ZKk/arcgis/rest/services/RKI_COVID19/FeatureServer/0/query?where=(Bundesland%20%3D%20'SACHSEN'|Bundesland%20%3D%20'SACHSEN-ANHALT'|Bundesland%20%3D%20'TH%C3%9CRINGEN')&outFields=*&outSR=4326&f=json"
# data <- content(GET(url = file), type="application/json")
# feat <- data$features
# table <- as_tibble(t(simplify2array(lapply(feat, function(x) unlist(x$attributes)))))


sums <-
  table %>%
  filter(Bundesland %in% c("Sachsen", "Thüringen", "Sachsen-Anhalt", "Bayern",
                           "Nordrhein-Westfalen", "Baden-Württemberg")) %>%
  group_by(Bundesland, Meldedatum) %>%
  summarize(AnzahlFall = sum(as.numeric(AnzahlFall))) %>%
  mutate(Fallzahl = cumsum(AnzahlFall)) %>%
  mutate(Datum = as.POSIXct(Meldedatum))



ggplot(sums, aes(Datum, Fallzahl, color=Bundesland)) + geom_line()
ggplot(sums, aes(Datum, Fallzahl, color=Bundesland)) + geom_line() + scale_y_log10()

## ... continue with rate of increase and doubling time
