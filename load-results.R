library(rgcam)
library(ggplot2)
library(dplyr)
library(tidyr)

qf <- "custom-query.xml"
projfile <- "master.dat"
## file.remove(projfile)

conn <- localDBConn("local/output/", "database_basexdb")
scenarios <- listScenariosInDB(conn) %>%
  filter(grepl("2019", name))
master <- scenarios %>%
  filter(grepl("master", name)) %>%
  pull(name)
branch <- scenarios %>%
  filter(grepl("hector-update", name)) %>%
  pull(name)
proj <- addScenario(conn, projfile, master, queryFile = qf)
proj <- addScenario(conn, projfile, branch, queryFile = qf)

vars <- c(
  "CO2 concentrations",
  "N2O concentrations",
  "Climate forcing",
  "Global mean temperature"
)

dmaster <- bind_rows(proj[[master]][vars], .id = "variable")
dhector <- bind_rows(proj[[branch]][vars], .id = "variable")
dat <- bind_rows(dmaster, dhector)

ggplot(dat) +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable), scales = "free_y")

dat_wide <- spread(dat, scenario, value)
# TODO: Fix the column names
ggplot(dat_wide) +
  aes_string(x = master, y = branch) +
  geom_point() +
  geom_abline() +
  facet_wrap(vars(variable), scales = "free")
