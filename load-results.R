library(rgcam)

conn <- localDBConn("local/output/", "database_basexdb")
proj <- addScenario(conn, "master.dat", "master-branch")
proj <- addScenario(conn, "master.dat", "hector-update")

master <- dplyr::bind_rows(
  proj[["master-branch"]][c(
    "CO2 concentrations",
    "Climate forcing",
    "Global mean temperature"
  )],
  .id = "variable"
)

hector <- dplyr::bind_rows(
  proj[["hector-update"]][c(
    "CO2 concentrations",
    "Climate forcing",
    "Global mean temperature"
  )],
  .id = "variable"
)

dat <- dplyr::bind_rows(master, hector)

library(ggplot2)
ggplot(dat) +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable), scales = "free_y")
