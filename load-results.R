library(rgcam)
library(ggplot2)
library(dplyr)
library(tidyr)
library(forcats)

qf <- "custom-query.xml"
projfile <- "master.dat"
suppressWarnings(file.remove(projfile))

conn <- localDBConn("local/output/", "database_basexdb")
scenarios <- listScenariosInDB(conn) %>%
  filter(grepl("2019", name))
master <- scenarios %>%
  filter(grepl("master", name)) %>%
  arrange(desc(date)) %>%
  slice(1) %>%
  pull(name)
branch <- scenarios %>%
  filter(grepl("hector-update", name)) %>%
  arrange(desc(date)) %>%
  slice(1) %>%
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
dat <- bind_rows(dmaster, dhector) %>%
  mutate(scenario = fct_inorder(scenario) %>%
           fct_relabel(~gsub("-[[:digit:]]+$", "", .)))

ggplot(dat) +
  aes(x = year, y = value, color = scenario) +
  geom_line() +
  facet_wrap(vars(variable), scales = "free_y") +
  theme_bw()

ggsave("~/Desktop/version-compare.png")

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
