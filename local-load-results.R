library(rgcam)
library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)

qf <- "custom-query.xml"
projfile <- "master.dat"
suppressWarnings(file.remove(projfile))

conn_default <- localDBConn("../gcam-core-local/output/", "database_basexdb")
proj <- addScenario(conn_default, projfile, "ref-default", queryFile = qf)
proj <- addScenario(conn_default, projfile, "rcp26-default", queryFile = qf)

conn_hector <- localDBConn("../gcam-core-hector/output", "database_basexdb")
proj <- addScenario(conn_hector, projfile, "ref-hector", queryFile = qf)
proj <- addScenario(conn_hector, projfile, "rcp26-hector", queryFile = qf)

vars <- c(
  "CO2 concentrations",
  "N2O concentrations",
  "Climate forcing",
  "Global mean temperature"
)

dat <- bind_rows(
  proj[["ref-default"]][vars],
  proj[["rcp26-default"]][vars],
  proj[["ref-hector"]][vars],
  proj[["rcp26-hector"]][vars],
  .id = "variable"
)

dat %>%
  mutate(variable_unit = sprintf("%s (%s)", variable, Units)) %>%
  ggplot() +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable_unit), scales = "free_y") +
  theme_bw()

dir.create("figures", showWarnings = FALSE)

ggsave("figures/version-compare.png")

dat_compare <- dat %>%
  separate(scenario, c("scenario", "version"), sep = "-") %>%
  pivot_wider(names_from = "version", values_from = "value") %>%
  mutate(
    hector_minus_default = hector - default,
    variable_unit = sprintf("%s (%s)", variable, Units)
  )

ggplot(dat_compare) +
  aes(x = year, y = hector_minus_default, color = scenario) +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  facet_wrap(vars(variable_unit), scales = "free") +
  theme_bw()

ggsave("figures/version-diff.png")

dat_wide <- dat %>%
  mutate(scenario = gsub("-.*", "", scenario)) %>%
  spread(scenario, value)

ggplot(dat_wide) +
  aes(x = year, y = hector - master) +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  facet_wrap(vars(variable), scales = "free") +
  theme_bw()
ggsave("~/Desktop/version-diffs.png")
