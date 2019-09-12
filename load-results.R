library(rgcam)
library(ggplot2)
library(dplyr)
library(tidyr)

qf <- "custom-query.xml"

conn <- localDBConn("local/output/", "database_basexdb")
proj <- addScenario(conn, "master.dat", "master-branch", queryFile = qf)
proj <- addScenario(conn, "master.dat", "hector-update", queryFile = qf)

vars <- c(
  "CO2 concentrations",
  "N2O concentrations",
  "Climate forcing",
  "Global mean temperature"
)

master <- bind_rows(
  proj[["master-branch"]][vars],
  .id = "variable"
)

hector <- bind_rows(
  proj[["hector-update"]][vars],
  .id = "variable"
)

dat <- bind_rows(master, hector)

ggplot(dat) +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable), scales = "free_y")

dat_wide <- spread(dat, scenario, value)
ggplot(dat_wide) +
  aes(x = `hector-update`, y = `master-branch`) +
  geom_point() +
  geom_abline() +
  facet_wrap(vars(variable), scales = "free")
